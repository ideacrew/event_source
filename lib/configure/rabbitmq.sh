### Setup and configuration for RabbitMQ ###

# Envinroment Variables

# ENV[RABBITMQ_DEFAULT_USER]
# ENV[RABBITMQ_DEFAULT_PWD]
# ENV[SYSADMIN_USER] - RabbitMQ Administrator user name
# ENV[SYSADMIN_PWD]- RabbitMQ Administrator password
# ENV[CLIENT_KEY] - Abbreviation for Client, eg. DC, MA, ME
# ENV[DEV_SERVICE_PWD]- Service password for Development environment
# ENV[TEST_SERVICE_PWD]- Service password for Test environment
# ENV[PROD_SERVICE_PWD]- Service password for Production environment

# Docker
docker pull rabbitmq
docker run -d \
  --hostname ENV[RABBITMQ_HOSTNAME] \
  --name ENV[RABBITMQ_HOSTNAME] \
  -p 5672:5672 \
  -e RABBITMQ_ERLANG_COOKIE='cookie for clustering' \
  -e RABBITMQ_DEFAULT_USER=ENV[RABBITMQ_DEFAULT_USER] \
  -e RABBITMQ_DEFAULT_PASS=ENV[RABBITMQ_DEFAULT_PWD] \
  --name some-rabbit rabbitmq:3-management

# Configure Plugins
## Management plugin runs on port 15672
rabbitmq-plugins enable rabbitmq_management

## Kubernetes
rabbitmq-plugins enable rabbitmq_peer_discovery_k8s

## Note: consider using this plugin w/AWS for SSO
# rabbitmq-plugins enable rabbitmq_auth_backend_http

# Configure Users
## Admin User
rabbitmqctl add_user ENV[SYSADMIN_USER] ENV[SYSADMIN_PWD]
rabbitmqctl set_user_tags ENV[SYSADMIN_USER] administrator

## Change default user creds
rabbitmqctl change_password guest ENV[NEW_GUEST_PWD]

## Environment Users
rabbitmqctl add_user ENV[CLIENT_KEY].dev ENV[DEV_SERVICE_PWD]
rabbitmqctl add_user ENV[CLIENT_KEY].test ENV[TEST_SERVICE_PWD]
rabbitmqctl add_user ENV[CLIENT_KEY].prod ENV[PROD_SERVICE_PWD]

# Configure vhosts
rabbitmqctl add_vhost ENV[CLIENT_KEY]-dev-vhost
rabbitmqctl add_vhost ENV[CLIENT_KEY]-test-vhost
rabbitmqctl add_vhost ENV[CLIENT_KEY]-prod-vhost

## Grant configure, write and read access to vhosts
rabbitmqctl set_permissions -p ENV[CLIENT_KEY]-dev-vhost ENV[CLIENT_KEY].dev ".*" ".*" ".*"
rabbitmqctl set_permissions -p ENV[CLIENT_KEY]-test-vhost ENV[CLIENT_KEY].test ".*" ".*" ".*"
rabbitmqctl set_permissions -p ENV[CLIENT_KEY]-prod-vhost ENV[CLIENT_KEY].prod ".*" ".*" ".*"
