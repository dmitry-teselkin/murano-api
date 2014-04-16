###################################
Murano Devbox installed by devstack
###################################

Summary
#######

Murano devstack scripts is an easy way to get started with Murano and OpenStack. The only disatvantage of such approach is that you have to deploy the entire OpenStack on your host. This is quite time-consuming and resource-intensive task. Hopefully, there is a way to install Murano as a standalone devbox, without OpenStack services on your host. Of course, you still have to have OpenStack lab installed somewhere in your network, but you don't need to install it on your host anymore. You even could install devstack + Murano on a virtual machine! And you can share one OpenStack lab between multiply developers.

So, let's assume that you have an OpenStack lab somewhere in your network. The way the lab was deployed doesn't matter - it could be another devstack-made lab, or be installed by hand using packages, or by using some automation scripts / tools. What really matter is the ability to establish connection from your host to the lab and correct credentials / endpoints.

OpenStack Lab Preparation
#########################

For Murano to work with OpenStack lab the following conditions must be met:
   * RabbitMQ account 'guest' with administrator privileges must exist.
   * OpenStack tenant 'service' must exist.
   * OpenStack user 'murano' with administrator role must exists and be a member of 'service' tenant.

The following data is required to setup Murano devbox:
   * OpenStack Lab IP address (let's name it **%openstack_host_ip%**)
   * OpenStack Lab 'murano' account password (let's name it **%murano_admin_password%**)
   * RabbitMQ 'guest' account password (let's name it **%rabbit_guest_password%**)

Check OpenStack Lab
*******************

Check RabbitMQ
==============

1. Open web browser and navigate to the link http://%openstack_host_ip%:55672
2. Try to log in as user 'guest' with password 'guest' (or using password which was changed to for that user).
3. Click on **Users** and check if user 'guest' has tag named 'administrator'.

If you managed to do all the steps above and the tag exists - RabbitMQ is configured correctly.

Check OpenStack users and tenants
=================================

1. Open your openstack dashboard and login as user with 'admin' priveleges.
2. Navigate to 'Admin' -> 'Projects' and check if a project with name 'service' exists. If not - create it:
    * Click the button button '+ Create Project'.
    * Set new project's name.
    * Click 'Create Project'.
3. Navigate to 'Admin' -> 'Users' and check if a user with name 'murano' exists. If not - create it:
    * Click the button '+ Create User'.
    * Set 'User name' = 'murano'.
    * Set 'Email' = 'murano@example.com'.
    * Set 'Password' and 'Confirm Password' fields.
    * Select 'Primary Project' - 'service'.
    * Select 'Role' - 'admin'.
    * Click 'Create User'.

Murano Devbox Installation
**************************

.. note::

    In this guide it is assumed that you already have a box prepared for devstack.

..

Clone **murano-api** from https://github.com/stackforge/murano-api.git and copy all files from 'contrib/devstack' to your local devstack repository. Then, create a 'local.conf' config file (see example below). Configure all variables marked.

Config file example:

.. code-block:: shell

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
    enable_service murano-dashboard

    # Murano configuration variables

    #MURANO_BRANCH=master

    #----------------------------
    # MURANO SETTINGS BLOCK end

..

Then, run devstack with command './stack.sh'


