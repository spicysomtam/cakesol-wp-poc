I am building this on ubuntu 16.04 LTS (actually Linux Mint 18.2 that is based on ubuntu, but that is a digression). 

We can provision aws services using ansible, as its built in to ansible. This requires an up to date ansible, boto, boto3 and awscli. So I decided to do it that way.

We want the latest ansible from ansible, rather than what ubuntu has, which is older, so lets add the ansible repo, update, and install it:

sudo apt-add-repository ppa:ansible/ansible
sudo apt-get update
sudo apt-get install ansible

For good measure, lets get aws cli up to date:

sudo pip install --upgrade awscli

Then install boto and boto3:

sudo pip install boto
sudo pip install boto3

Creating the ec2 instance (specify the ec2 iam key id and secret):

ansible-playbook -i127.0.0.1, -e "ec2key=x ec2secret=y" ansible/create-ec2-instance.yml

Alternative, if specifying your own config file (with the ec2 iam key/secret in the file); can also include the vars above too:

ansible-playbook -i127.0.0.1, -e "envconf=vars/dev-env.yml" ansible/create-ec2-instance.yml
