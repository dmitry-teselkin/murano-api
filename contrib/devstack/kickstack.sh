#!/bin/bash

# To execute this script without cloning the entire repository, use the command below:
# wget https://raw.githubusercontent.com/dmitry-teselkin/murano-api/murano-devbox-guide/contrib/devstack/kickstack.sh -O - | bash

set -o errexit
set -o xtrace

MURANO_GIT_URL='https://github.com/stackforge/murano-api'
MURANO_BRANCH='release-0.5'

DEVSTACK_GIT_URL='https://github.com/openstack-dev/devstack'
DEVSTACK_BRANCH='stable/icehouse'

STACK_USER='stack'
STACK_GROUP='stack'
STACK_PASSWORD='swordfish'

function git_clone() {
    local git_url=${1}
    local git_branch=${2:-'master'}
    local git_dir=${3}

    if [[ -z "$git_dir" ]]; then
        git_dir=${git_url##*/}
    fi

    if [[ ! -d "${git_dir}" ]]; then
        git clone "${git_url}" "${git_dir}"
    fi
    pushd "${git_dir}"
    git reset --hard
    git clean -fdx
    git remote update
    git checkout "${git_branch}"
    popd
}

git_clone "$DEVSTACK_GIT_URL" "$DEVSTACK_BRANCH"

git_clone "$MURANO_GIT_URL" "$MURANO_BRANCH"

cp -r murano-api/contrib/devstack/{extras.d,files,lib} ./devstack

cat << 'EOF' > ./devstack/local.conf
[[local|localrc]]

# IP address of OpenStack node
HOST_IP=                                         # <-- CONFIGURE THIS

# Passwords and tokens
#---------------------
# DO NOT COMMENT ANY VARIABLE IN THE SECTION BELOW!
# These vars must be defined anyway, do you install OpenStack or not.
# Password for 'admin' user on the OpenStack node.
# In our type of installation it is not used, but it MUST be defined.
ADMIN_PASSWORD=.
# Password for 'root' user to connect to MySQL.
MYSQL_PASSWORD=                                  # <-- CONFIGURE THIS
# Password for 'murano' service user.
SERVICE_PASSWORD=                                # <-- CONFIGURE THIS
# Not used but MUST be defined. Any value counts.
SERVICE_TOKEN=.
#---------------------


# Explicitely point rabbitmq to OpenStack node
#  and provide password (even if it's equal to default!).
# NOTE: Both variables must be defined.
RABBIT_HOST=$HOST_IP
RABBIT_PASSWORD=guest                            # <-- CONFIGURE THIS

# Enable this to be able to switch between branches later
RECLONE=True

# Logging
SCREEN_LOGDIR=/opt/stack/log/
LOGFILE=$SCREEN_LOGDIR/stack.sh.log


# Configure local services
#-------------------------
# Disable all services by assigning an empty string value.
ENABLED_SERVICES=

# Enable MySQL (required by Murano).
enable_service mysql

# Enable dashboard.
enable_service horizon
#-------------------------


# MURANO SETTINGS BLOCK start
#----------------------------

# Enable Murano services
enable_service murano
enable_service murano-api
enable_service murano-engine
enable_service murano-dashboard

# Murano configuration variables

#MURANO_BRANCH=master
MURANO_RABBIT_VHOST=/                            # <- CONFIGURE THIS

#----------------------------
# MURANO SETTINGS BLOCK end
EOF

sudo ./devstack/tools/create-stack-user.sh
echo "${STACK_USER}:${STACK_PASSWORD}" | sudo chpasswd
sudo cp -r devstack /opt/stack
sudo chown -R ${STACK_USER}:${STACK_GROUP} /opt/stack



cat << EOF
--------------------------------------------------------------------------------
Now you can logout from this session and login back 
as user '${STACK_USER}' with password '${STACK_PASSWORD}'.

This system IP addresses are:
$(ip a | awk '/ inet /{print "* " $2}')

Hint: setting ssh option '-oPubkeyAuthentication=no' might be useful.

When logged in, configure file 'local.conf' in 'devstack' folder and then
start installation with command 'stack.sh'
--------------------------------------------------------------------------------
EOF
