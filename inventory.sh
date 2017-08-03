#!/bin/bash

export ANSIBLE_HOSTS=ansible/ec2.py
export EC2_INI_PATH=ansible/ec2.ini

[ -z "$AWS_SECRET_ACCESS_KEY" ] && {
  echo "Env var AWS_SECRET_ACCESS_KEY is not defined; export it!"
}

[ -z "$AWS_ACCESS_KEY_ID" ] && {
  echo "Env var AWS_ACCESS_KEY_ID is not defined; export it!"
}
