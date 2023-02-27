#!/bin/bash
cat << _EOF_ > /home/ubuntu/ansible/init-docker.yml
---
- name: Setup docker for host groups -- tool and agents
  hosts: docker
  become: True 
  vars:
    docker_user: ubuntu
  tasks:
    - name: Install aptitude
      apt:
        name: aptitude
        state: latest
        update_cache: true

    - name: Install required system packages
      apt:
        pkg:
          - apt-transport-https
          - ca-certificates
          - curl
          - software-properties-common
          - gnupg
          - lsb-release
          - python3-pip
          - virtualenv
          - python3-setuptools
        state: latest
        update_cache: true
    - name: Add Docker GPG apt Key
      apt_key:
        url: https://download.docker.com/linux/ubuntu/gpg
        state: present

    - name: Add Docker Repository
      apt_repository:
        repo: deb https://download.docker.com/linux/ubuntu focal stable
        state: present

    - name: Update apt and install docker-ce
      apt:
        name: docker-ce
        state: latest
        update_cache: true

    - name: Install docker-ce-cli
      apt:
        name: docker-ce-cli
        state: latest
        update_cache: true

    - name: Install containerd.io
      apt:
        name: containerd.io
        state: latest
        update_cache: true

    - name: Adding user to docker group  
      user:
        name: "{{ docker_user }}"
        group: "{{ docker_user }}"
        groups: docker
        append: yes

- name: Setup AWSCLI -- tools hostgroup
  hosts: tools
  become: True 
  tasks:
    - name: Install AWSCLI
      pip:
        name: awscli

_EOF_