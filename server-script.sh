#! /bin/bash

sudo yum install git -y
sudo yum install java-1.8.0-openjdk-devel -y
sudo yum install maven -y

if [-d "addressbook"]
then
  echo "repo is cloned and exsists"
  cd addressbook
  git pull origin jenkins-pipeline
else
  git clone https://github.com/SuryaIsukapalli/addressbook.git
  git checkout jenkins-pipeline
  cd addressbook
fi

mvn test
