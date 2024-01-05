#! /bin/bash

set -eu -o pipefail

sudo -n true
test $? -eq 0 || exit 1 "you should have priv for this script"

echo ...
echo ...
echo "this installs docker jenkins on ubuntu  (soon to be arm)"
echo ...

echo "installing the must-have pre-requisites"
sudo apt-get install python3-pip -y
while read -r p ; do sudo apt-get install -y $p ; done < <(cat << "EOF"
  git
  docker
  openjdk-8-jre
EOF
)

echo ...
echo ...
echo "need to check for ubuntu or arm"
host_linux=$(uname -v | awk '{ print $1 }' | sed -n 's/.*U//p' ) # expect 21-Ubuntu
host_arm=$(uname -a | awk '{ print $11 }' | grep -oP "arm") # expecting armv...
if [ $host_linux == "buntu" ]; then
  echo "installing docker image jenkins/jenkins for ubuntu"
  docker pull jenkins/jenkins
fi
if [ $host_arm == 'arm' ]; then
  echo "installing docker image mlucken/jenkins-arm for arm"
  docker pull mlucken/jenkins-arm
fi
echo ...



echo "running image on port 3000"
sudo docker run -p 3000:8080 -d --name oscar jenkins/jenkins
variable_2=$(sudo docker ps)
echo $variable_2
echo cat $variable_2 | egrep "oscar"
variable_1=$(cat $variable_2 | awk '{ print $1 }' | awk '/^[0-9]|[a-z]/ { print }'})
echo "this is the short version docker image ID ... $variable_1"
echo ...
echo ...
echo ...
sleep 10 # need a pause for the image to run before grabbing the password
variable_password=$(sudo docker exec $variable_1 cat /var/jenkins_home/secrets/initialAdminPassword)
echo "admin password is ... $variable_password"
echo .................
