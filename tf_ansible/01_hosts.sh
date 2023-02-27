#!/bin/bash
mkdir /home/ubuntu/ansible

cat <<- _EOF_ > /home/ubuntu/ansible/ansible.cfg
[defaults]
inventory = hosts
host_key_checking = False
timeout = 30
gather_timeout = 30
gather_subset = !all

_EOF_

cat << _EOF_ > /home/ubuntu/ansible/hosts
[ansible_control]
control ansible_host=${node_1_ip}

[webservers] 
tomcat ansible_host=${node_2_ip}

[agents]
agent ansible_host=${node_3_ip}

[tools]
nexus ansible_host=${node_4_ip}
jenkins ansible_host=${node_5_ip}

[docker:children] 
tools
agents

[all:vars]
ansible_user=ubuntu
ansible_private_key_file=/home/ubuntu/.ssh/ci-swapp.pem

_EOF_
