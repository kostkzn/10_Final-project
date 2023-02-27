#!/bin/bash
cat << _EOF_ > /home/ubuntu/ansible/init-control.yml
---
- name: Setup localhost as Agent of Jenkins
  hosts: localhost
  become: True 
  tasks:
    - name: Install aptitude
      apt:
        name: aptitude
        state: latest
        update_cache: true
    - name: Install required system packages
      apt:
        pkg:
          - openjdk-11-jre
        state: latest
        update_cache: true

_EOF_
