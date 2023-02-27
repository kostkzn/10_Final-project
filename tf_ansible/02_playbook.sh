#!/bin/bash

cat << _EOF_ > /home/ubuntu/ansible/init-all.yml
---
- import_playbook: init-docker.yml
- import_playbook: init-tomcat9.yml
- import_playbook: init-agent.yml
- import_playbook: init-control.yml
- import_playbook: init-tools.yml

_EOF_
