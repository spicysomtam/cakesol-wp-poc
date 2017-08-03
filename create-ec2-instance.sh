#!/bin/bash

[ -z "$AWS_SECRET_ACCESS_KEY" ] && {
  echo "Env var AWS_SECRET_ACCESS_KEY is not defined; export it!"
  exit 1
}

[ -z "$AWS_ACCESS_KEY_ID" ] && {
  echo "Env var AWS_ACCESS_KEY_ID is not defined; export it!"
  exit 1
}

ansible-playbook -i127.0.0.1, -e "ec2key=$AWS_ACCESS_KEY_ID ec2secret=$AWS_SECRET_ACCESS_KEY" ansible/create-ec2-instance.yml
