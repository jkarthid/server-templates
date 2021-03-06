#! /usr/bin/sudo /bin/bash
# ---
# RightScript Name: Tomcat Application Backend - chef
# Description: 'Attaches the application server to a load balancer '
# Inputs:
#   APPLICATION_NAME:
#     Category: Load Balancer
#     Description: 'The name of the application. This name is used to generate the path
#       of the application code and to determine the backend pool in a load balancer
#       server that the application server will be attached to. Application names can
#       have only alphanumeric characters and underscores. Example: hello_world'
#     Input Type: single
#     Required: false
#     Advanced: true
#   BIND_NETWORK_INTERFACE:
#     Category: Load Balancer
#     Description: The network interface to use for the bind address of the application
#       server. It can be either 'private' or 'public' interface.
#     Input Type: single
#     Required: false
#     Advanced: true
#   LISTEN_PORT:
#     Category: Load Balancer
#     Description: 'The port to use for the application to bind. Example: 8080'
#     Input Type: single
#     Required: false
#     Advanced: true
#   VHOST_PATH:
#     Category: Load Balancer
#     Description: 'The virtual host served by the application server. The virtual host
#       name can be a valid domain/path name supported by the access control lists (ACLs)
#       in a load balancer. Ensure that no two application servers in the same deployment
#       having the same application name have different vhost paths. Example: http:://www.example.com,
#       /index'
#     Input Type: single
#     Required: false
#     Advanced: true
#   REFRESH_TOKEN:
#     Category: Application
#     Description: 'The Rightscale OAUTH refresh token.  Example: cred: MY_REFRESH_TOKEN'
#     Input Type: single
#     Required: true
#     Advanced: false
# Attachments: []
# ...

set -e

HOME=/home/rightscale
export PATH=${PATH}:/usr/local/sbin:/usr/local/bin

/sbin/mkhomedir_helper rightlink

export chef_dir=$HOME/.chef
mkdir -p $chef_dir

#get instance data to pass to chef server
instance_data=$(/usr/local/bin/rsc --rl10 cm15 index_instance_session  /api/sessions/instance)
instance_uuid=$(echo $instance_data | /usr/local/bin/rsc --x1 '.monitoring_id' json)
instance_id=$(echo $instance_data | /usr/local/bin/rsc --x1 '.resource_uid' json)
monitoring_server=$(echo $instance_data | /usr/local/bin/rsc --x1 '.monitoring_server' json)
shard=$(echo $monitoring_server | sed -e 's/tss/us-/')

if [ -e $chef_dir/chef.json ]; then
  rm -f $chef_dir/chef.json
fi
# add the rightscale env variables to the chef runtime attributes
# http://docs.rightscale.com/cm/ref/environment_inputs.html
cat <<EOF> $chef_dir/chef.json
{
  "name": "${HOSTNAME}",
  "normal": {

    "tags": [
    ]
  },
  "rightscale":{
  "instance_uuid":"$instance_uuid",
  "instance_id":"$instance_id",
  "refresh_token":"$REFRESH_TOKEN",
  "api_url":"https://${shard}.rightscale.com"
  },
  "rsc_tomcat": {
    "application_name": "$APPLICATION_NAME",
    "bind_network_interface": "$BIND_NETWORK_INTERFACE",
    "listen_port": "$LISTEN_PORT",
    "vhost_path":"$VHOST_PATH"
  },
  "run_list": ["recipe[rsc_tomcat::application_backend]"]
}
EOF


chef-client --json-attributes $chef_dir/chef.json
