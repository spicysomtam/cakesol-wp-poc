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

```
sudo apt-add-repository ppa:ansible/ansible
sudo apt-get update
sudo apt-get install ansible
```

For good measure, lets get awscli up to date:

```
sudo pip install --upgrade awscli
```

Then install boto and boto3:

```
sudo pip install boto
sudo pip install boto3
```

This step can be done by running 'getting-started.sh'

# Creating the ec2 instance

We will use a instance tag to refer to the ec2 instance, rather than an IP address when we configure it after its created. Ensure instance_tags->Name in ansible/vars/dev-env.yml (or the config file you use) is set to something unique and meaningful. Its currently set to docker_wp_dev. Note that hyphens get changes to underscores... 

Then setup some env vars for your IAM key/secret; we need this later but might as well set it up now and then use the env vars:

```
export AWS_ACCESS_KEY_ID=y
export AWS_SECRET_ACCESS_KEY=x
```
Run this to create the instance (specify the ec2 iam key id and secret):

```
ansible-playbook -i127.0.0.1, -e "ec2key=$AWS_ACCESS_KEY_ID ec2secret=$AWS_SECRET_ACCESS_KEY" ansible/create-ec2-instance.yml
```

Alternative, if specifying your own config file:

```
ansible-playbook -i127.0.0.1, -e "envconf=vars/dev-env.yml" ansible/create-ec2-instance.yml
```

# Configuring the ec2 inventory

Now we have a ec2 instance, we need to configure it. We need some magic to inventory what we have in our ec2 world and then choose the host via its tag to provision.

Ansible has some tools for this. Lets get them:

```
cd ansible
mkdir inventory
cd inventory
wget https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/ec2.py
chmod u+x ec2.py
wget https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/ec2.ini
cd ../..
```

I suggest editing the ec2.ini and setting region in the ec2 block to the region where you provisioned against.


And for the ec2 setup:

```
export ANSIBLE_HOSTS=ansible/inventory/ec2.py
export EC2_INI_PATH=ansible/inventory/ec2.ini
```

Then you can list your ec2 inventory:

```
ansible/inventry/ec2.py --list

```

Then add the aws ssh priv key to the ssh keyring; something like this:

```
ssh-add ~/.ssh/aws-andy.pem
```

Finally test access, using the tag:

```
ansible -u ubuntu -m ping tag_Name_docker_wp_dev
35.176.159.213 | SUCCESS => {
    "changed": false, 
    "ping": "pong"
}
```

If it complains that /usr/bin/python cannot be found, welcome to later versions of ubuntu with no python! See this for a work around: https://gist.github.com/gwillem/4ba393dceb55e5ae276a87300f6b8e6f
Use ubuntu 14.04 as recommended :)

From now we can refer to the host as tag_Name_docker_wp_dev when running ansible. Also the same tag can be used on more than one instance, in which case ansible will apply changes to all instances referred via the tag.

# Docker and docker compose local dev setup

Install docker-engine from docker.io (not ubuntu repo) and docker-compose.  These should be reasonably recent releases as the technology is changing fast.

I used docker version 1.13.1 and docker-compose version 1.10.0. These are not the most recent versions and I don't want to upgrade to the latest due to the docker versioning changes (which broke kubernetes/openshift so I locked my versions to docker 1.13.1 in apt).

You will need to create an empty grafana dir, before running docker-compose. Then, to spin up the dev docker stack:

```
docker-compose up -d
```

To bring it down and remove containers:

```
docker-compose down
```
