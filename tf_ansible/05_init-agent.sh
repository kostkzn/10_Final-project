#!/bin/bash

cat << _EOF_ > /home/ubuntu/ansible/init-agent.yml
---        
- name: Docker install for Agent of Jenkins via Socat
  hosts: agents
  become: True 
  vars:
    container_image: alpine/socat
  tasks:
    - name: (1/4) Alpine/Socat -- Geting info
      community.docker.docker_container_info:
        name: socat
      register: socat_run

    - name: (2/4) Alpine/Socat -- Checking Running Status
      debug:
        var: socat_run.container.State.Status  
  
    - name: (3/4) Alpine/Socat -- Starting
      community.docker.docker_container:
        name: socat
        image: "{{ container_image }}"
        command: tcp-listen:2375,fork,reuseaddr unix-connect:/var/run/docker.sock
        volumes:
          - /var/run/docker.sock:/var/run/docker.sock
        ports:
          - "2375:2375"
        restart_policy: always
        detach: true
        state: started 
      register: socat_run

    - name: (4/4) Alpine/Socat -- Checking Running Status 
      debug:
        var: socat_run.container.State.Status

_EOF_

