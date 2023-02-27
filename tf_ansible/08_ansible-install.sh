#!/bin/bash
echo ">>> INIT 0 $(date -u)" > /home/ubuntu/log_ansible
sudo apt update && sudo apt install python3-pip --yes | sudo tee -a /home/ubuntu/log_ansible > /dev/null
echo ">>> STEP 1 Succeeded at $(date -u)" >> /home/ubuntu/log_ansible
python3 -m pip install --upgrade pip wheel ansible awscli | sudo tee -a /home/ubuntu/log_ansible > /dev/null
echo ">>> STEP 3 Succeeded at $(date -u)" >> /home/ubuntu/log_ansible
echo "$(ansible --version)" >> /home/ubuntu/log_ansible
ansible-galaxy collection install community.docker | sudo tee -a /home/ubuntu/log_ansible > /dev/null
sudo -u ubuntu bash -c 'ansible-galaxy collection install community.docker | sudo tee -a /home/ubuntu/log_ansible > /dev/null'
echo ">>> STEP 4 Succeeded at $(date -u) -- community.docker of ansible-galaxy collection"
