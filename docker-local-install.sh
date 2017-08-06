#!/bin/bash

dock=1.13.1-0~ubuntu-xenial
dockcmp=1.10.0

echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" > docker.list
sudo mv docker.list /etc/apt/sources.list.d/
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
sudo apt-get update
sudo apt-get install docker-engine=$dock
sudo pip install docker-compose==$dockcmp
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker $USER

echo "You have just been added to the docker group, but it will not be effective until you logout and back in."
echo "Please logout and back in to use docker."
