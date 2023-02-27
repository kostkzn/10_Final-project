#!/bin/bash
mkdir /home/ubuntu/ansible

cat <<- _EOF_ > /home/ubuntu/ansible/ansible.cfg
[defaults]
inventory = hosts
remote_user = ubuntu
host_key_checking = False
timeout = 30
gather_timeout = 30
gather_subset = !all

_EOF_

cat << _EOF_ > /home/ubuntu/ansible/hosts
[ansible_control]
control ansible_host=${node_1_ip} ansible_private_key_file=/home/ubuntu/.ssh/ci-swapp.pem

[webservers] 
tomcat ansible_host=${node_2_ip} ansible_private_key_file=/home/ubuntu/.ssh/ci-swapp.pem

[agents]
agent ansible_host=${node_3_ip} ansible_private_key_file=/home/ubuntu/.ssh/ci-swapp.pem

[tools]
nexus ansible_host=${node_4_ip} ansible_private_key_file=/home/ubuntu/.ssh/ci-swapp.pem
jenkins ansible_host=${node_5_ip} ansible_private_key_file=/home/ubuntu/.ssh/ci-swapp.pem

[docker:children] 
tools
agents
_EOF_
