#!/bin/bash

sudo chmod -v 400 /home/ubuntu/.ssh/ci-swapp*.pem
sudo chown -v ubuntu:ubuntu /home/ubuntu/.ssh/ci-swapp*.pem

sudo -u ubuntu bash -c 'cd /home/ubuntu/ansible; \
ansible-playbook init-all.yml -i hosts -vvv | sudo tee -a /home/ubuntu/log_ansible'

echo ">>> STEP 5 Succeeded at $(date -u) -- Ansible stack configure"