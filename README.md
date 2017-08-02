# Getting started

Read cake-sol-test-wordpress-prometheus-grafana.md to see what we are trying to achieve.

The monitoring setup uses docker via docker-compose, which orchestrates all the containers, on you development workstation. This would be prometheus, cadviser and grafana. The monitoring setup would then scrape stats from the EC2 instance and docker running on this instance.

The EC2 instance will be provisioned via ansible. Then docker will be installed on it, and a wordpress docker image downloaded and deployed via docker. All this should be provisioned by ansible.

My development workstation is ubuntu 16.04 LTS. 

I am of the view you keep things as simple and clean as possible. Thus I have tried to use prebuilt docker images and keep manual config to a minimum.

# Ansible AWS setup

We can provision aws services using ansible, as it has built in playbooks for this. This requires an up to date ansible, boto, boto3 and awscli. So I decided to do it that way.

Obviously you need an AWS account, and to have created a key/secret pair in IAM so you can use aws cli (with AdministratorAccess priv via a group).

We want the latest ansible, rather than what ubuntu has, which is older, so lets add the ansible repo, update, and install it:

`sudo apt-add-repository ppa:ansible/ansible`
`sudo apt-get update`
`sudo apt-get install ansible`

For good measure, lets get awscli up to date:

`sudo pip install --upgrade awscli`

Then install boto and boto3:

`sudo pip install boto`
`sudo pip install boto3`

Creating the ec2 instance (specify the ec2 iam key id and secret):

`ansible-playbook -i127.0.0.1, -e "ec2key=x ec2secret=y" ansible/create-ec2-instance.yml`

Alternative, if specifying your own config file (with the ec2 iam key/secret in the file); can also include the vars above if the config key/secret is incorrect:

`ansible-playbook -i127.0.0.1, -e "envconf=vars/dev-env.yml" ansible/create-ec2-instance.yml`

# Docker and docker compose local dev setup

Install docker-engine from docker.io (not ubuntu repo) and docker-compose.  These should be resonably recent releases as the technology is changing fast.

I used docker version 1.13.1 and docker-compose version 1.10.0. These are not the most recent versions and I am reluctant to upgrade to the latest due to the docker versioning changing (which broke kubernetes/openshift so I locked my versions to docker 1.13.1).

You will need to create an empty grafana dir, before running docker-compose. Then, to spin up the dev docker stack:

`docker-compose up -d`

To bring it down and remove containers:

`docker-compose down`
