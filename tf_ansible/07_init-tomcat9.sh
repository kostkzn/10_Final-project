#!/bin/bash

cat << _EOF_ > /home/ubuntu/ansible/init-tomcat9.yml
---
- name: Setup Tomcat9
  hosts: webservers
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
          - tomcat9
        state: latest
        update_cache: true
     
    - name: Ensure tomcat9 is running
      service:
        name: tomcat9
        state: started
_EOF_