#!/bin/bash

sudo apt-add-repository ppa:ansible/ansible
sudo apt-get update
sudo apt-get install ansible
sudo pip install --upgrade awscli
sudo pip install boto
sudo pip install boto3
