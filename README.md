# Getting started

cake-sol-test-wordpress-prometheus-grafana.md advises what is to be built.

The monitoring setup uses docker via docker-compose, which orchestrates all the containers, on you development workstation. This would be prometheus and grafana. The monitoring setup would then scrape stats from the EC2 instance and cadvisor running inside docker running on this instance.

The EC2 instance will be provisioned via ansible. Then ansible will install docker on it, along with prometheus node exporter, wordpress, marinadb and cadvisor containers deployed in docker. 

Finally there is the integration of the local docker setup with the remote EC2 instance config, and some tweaking of grafana to produce meaningful dashboards. The monitoring config needs to know what to scrape, and the ec2 security group needs to have the right ports open to allow this, etc. Prometheus ec2 discovery could be used, but I had something that already discovered the ec2 setup, so I used that.

My development workstation is ubuntu 16.04 LTS so this setup runs on this. 

I am of the view you keep things as simple and clean as possible. Thus I have tried to use prebuilt docker images, reuse what is available and keep manual config to a minimum. Ansible playbooks could be better implemented and written as roles (as I have done before). However this is a poc, and time is of essence to get something up and running that can be reliably reproduced.

# Ansible AWS setup

We can provision aws services using ansible, as it has built in playbooks for this. This requires an up to date ansible, boto, boto3 and awscli. So I decided to do it that way.

Obviously you need an AWS account, and to have created a key/secret pair in IAM so you can use aws cli (with AdministratorAccess priv via a group).

This step can be done by running 'getting-started.sh'

# Configuring the ec2 inventory

We need some magic to inventory what we have in our ec2 world and then choose the host via a tag rather than its ip address to provision.

Ansible has some tools for this. ec2.py/ec2.ini, which I installed in the ansible subdir.

We implement the IAM key/secret as env vars as this is more secure than saving it in config files (that may get commited to git):

```
export AWS_ACCESS_KEY_ID=y
export AWS_SECRET_ACCESS_KEY=x
```

I suggest editing the ec2.ini and setting region in the ec2 block to the region where you provisioned against (default is all regions).

Then source 'inventory.sh':

. ./inventory.sh

Then you can list your ec2 inventory:

```
ansible/ec2.py --list

```

You should have a aws key par setup to allow ssh access to your ec2 instances. If you don't have one, go and set one up, and save the priv key somewhere on your workstation. Then add the aws ssh priv key to the ssh keyring; something like this:

```
ssh-add ~/.ssh/aws-andy.pem
```

From now we can refer to the host as tag_Name_dev_docker_wp when running ansible. Also the same tag can be used on more than one instance, in which case ansible will apply changes to all instances referred via the tag.

# Creating the ec2 instance

We will use a instance tag to refer to the ec2 instance, rather than an IP address. Ensure instance_tags->Name in ansible/vars/dev-env.yml (or the config file you use) is set to something unique and meaningful. Its currently set to dev_docker_wp. Note that hyphens get changes to underscores... 

Run this to create the instance; this can be run again and again and it will maintain state until you terminate the instance:

```
./create-ec2-instance.sh
```

Wait until its fully created in aws (suppose the playbook could have done this).

Finally test access, using the tag. If this fails, revisit the inventry setup section:

```
ansible -u ubuntu -m ping tag_Name_dev_docker_wp
35.176.159.213 | SUCCESS => {
    "changed": false, 
    "ping": "pong"
}
```

# Provision the ec2 instance

This is somewhat different from creating it, as that step talked to the aws infrastructure. Now we need to ssh into the host to do configuration, and this needs a different ansible setup. Hence its a seperate task.

Provisioning the ec2 instance using the tag; again this maintains state so can be re-run:

```
./provision-ec2-instance.sh
```


# Docker on the ec2 instance

I did consider allowing remote requests to the docker daemon from the dev workstation, but this is horribly insecure (I could setup tls, etc, but that just adds more effort). For example I could run docker-compose on the dev workstation where it executes it on the ec2 instance. So I keep it simple, and copy over a docker-compose.yml file to the ec2 instance, and then run it there using ansible.

Then I discovered ansible can do docker compose for us. To I added the ec2 compose provisioning to the ec2 provision playbook.

# Docker and docker compose local dev setup

Install docker-engine from docker.io (not ubuntu repo) and docker-compose. I used non CE/EE versions.

This setup will also works out what ip addresses to use for the ec2 instance and cadvisor running on the instance. Prometheus config will be updated accordingly. Grafana is already populate with some dashboards.

```
./docker-dev-start.sh
```

To bring it down and remove containers:

```
./docker-dev-stop.sh
```
# Testing

Grafana will be exposed on http://localhost:3000. Login to it using admin/password.

The dashboards:
 - Docker Host: the ec2 instance prometheus node exporter.
 - Docker Containers: ec2 docker cadvisor.
 - Prometheus stats: the prometheus server docker container on your local workstation.
 - Monitor Services: not sure how useful that is.

The dashboards I found later on in the development process from here: https://github.com/stefanprodan/dockprom. 

Prometheus is exposed at http://localhost:9090. You can click on Status->Targets to see what is being scraped.

You can use ./ansible/ec.py to get the ec2 instance public ip. From that you can connect to the containers running on it:

 - http://<pub-ip> - Will get you to Wordpress, which needs a bit more work getting it installed (it does have a connection to a marinadb). Good enough for the poc I think.
 - http://<pub-ip>:8080 - cadvisor. Add /metrics to the url to get the metrics.
 - http://<pub-ip>:9100/metrics - node exporter metrics

I think its in a state I am happy to release, but there is much scope for improvement.

To do (priority in order below):
 - Improve some of the ansible errors, which I am not happy with.
 - Get the prometheus ec2 discovery working (quick setup did not work).
 - Setup the wordpress better.
 - Learn more about prometheus and get it to display nodes, etc, and setup some graphs. Documentation is a little sparse.
 - Look at prometheus storage, so collected data is not lost when the containers are destroyed (docker volume). Appreciate data is time series and it gets overwritten.
