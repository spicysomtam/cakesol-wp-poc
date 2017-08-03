#!/bin/bash

ansible-playbook -i ansible/ec2.py --limit tag_Name_dev_docker_wp ansible/provision-ec2-instance.yml
