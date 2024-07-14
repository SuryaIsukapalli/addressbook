#! /bin/bash

sudo yum install git -y
# sudo yum install java-1.8.0-openjdk-devel -y
# sudo yum install maven -y
sudo yum install docker -y 
sudo systemctl start docker

if [-d "addressbook"]
then
  echo "repo is cloned and exsists"
  cd addressbook
  git pull origin ci/cd-docker
else
  git clone https://github.com/SuryaIsukapalli/addressbook.git
  cd addressbook
  git checkout ci/cd-docker
fi

sudo docker build -t $1 .
