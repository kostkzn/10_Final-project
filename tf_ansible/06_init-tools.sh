#!/bin/bash

cat << _EOF_ > /home/ubuntu/ansible/init-tools.yml
---        
- name: Setup Container for NEXUS
  hosts: nexus
  become: True 
  vars:
    container_image: sonatype/nexus3:3.47.1
    docker_user: ubuntu
    dest_dir: "/home/{{docker_user}}"
    s3_bucket: s3://kooky-swapp-nexus-backup
    # s3_file: backup.tar.gz
  tasks:
    - name: Pull NEXUS image
      community.docker.docker_image:
        name: "{{ container_image }}"
        source: pull

    - name: Copy Backup from s3
      shell:
        cmd: "aws s3 cp {{s3_bucket}}/backup.tar.gz {{ dest_dir }}"
        creates: "{{ dest_dir }}/backup.tar.gz"
    
    - name: Dowloaded Backup exists
      stat:
        path: "{{ dest_dir }}/backup.tar.gz"
      register: s3_result
      until: s3_result.stat.exists == true  
      retries: 24
      delay: 5
    
    # - name: Dowloaded File exists
    #   debug:
    #     msg: s3_result.stat.exists
        
    - name: (1/3) Restore NEXUS Volume Container -- Getting info 
      community.docker.docker_container_info:
        name: box_restore_1
      register: box_restore_1

    - name: (1/3) Restore NEXUS Volume Container -- Checking Exit Status  
      debug:
        var: box_restore_1.container.State.Status 

    - name: (1/3) Restore NEXUS Volume Container -- Starting 
      community.docker.docker_container:
        name: box_restore_1
        image: busybox
        command: sh -c "chown 200:200 /nexus-data"
        volumes:
          - busyboxvol:/nexus-data 
        state: started
      when: (box_restore_1.container.State.Status is undefined) or
            (box_restore_1.container.State.Status != "exited")  
 
    - name: (2/3) Backup NEXUS Unzip Container -- Geting info
      community.docker.docker_container_info:
        name: box_restore_2
      register: box_restore_2

    - name: (2/3) Backup NEXUS Unzip Container -- Checking Exit Status
      debug:
        var: box_restore_2.container.State.Status         

    - name: (2/3) Backup NEXUS Unzip Container -- Starting
      community.docker.docker_container:
        name: box_restore_2
        image: busybox
        command: sh -c "cd /nexus-data && tar xvfz /backup/backup.tar.gz --strip 1"
        volumes:
          - "{{ dest_dir }}:/backup"
        volumes_from:
          - box_restore_1        
        state: started
      when: (box_restore_2.container.State.Status is undefined) or
            (box_restore_2.container.State.Status != "exited")       
  
    - name: (2/3) Backup NEXUS Unzip Container -- Waiting Exit Status
      community.docker.docker_container_info:
        name: box_restore_2
      register: box_restore_2
      until: box_restore_2.container.State.Status != "running"
      retries: 24
      delay: 5

    - name: (2/3) Backup Unzip Container -- Checking Exit Status
      debug:
        var: box_restore_2.container.State.Status      
    
    - name: (3/3) NEXUS Main Container -- Starting 
      community.docker.docker_container:
        name: box_restore_3
        image: "{{ container_image }}"
        volumes:
          - busyboxvol:/nexus-data 
        ports:
          - "8081:8081"
        detach: true
        state: started
        restart_policy: on-failure 
      register: box_restore_3

    - name: (3/3) NEXUS Main Container -- Checking Running Status 
      debug:
        var: box_restore_3.container.State.Status

- name: Setup Container for Jenkins
  hosts: jenkins
  become: True 
  vars:
    container_image: jenkins/jenkins:2.375.3-jdk11
    docker_user: ubuntu
    dest_dir: "/home/{{docker_user}}"
    s3_bucket: s3://kooky-swapp-jenkins-backup
    # s3_file: backup.tar.gz
  tasks:
    - name: Pull Jenkins image
      community.docker.docker_image:
        name: "{{ container_image }}"
        source: pull

    - name: Copy Backup from s3
      shell:
        cmd: "aws s3 cp {{s3_bucket}}/backup.tar.gz {{ dest_dir }}"
        creates: "{{ dest_dir }}/backup.tar.gz"
    
    - name: Dowloaded Backup exists
      stat:
        path: "{{ dest_dir }}/backup.tar.gz"
      register: s3_result
      until: s3_result.stat.exists == true  
      retries: 24
      delay: 5
    
    # - name: Dowloaded File exists
    #   debug:
    #     msg: s3_result.stat.exists
        
    - name: (1/3) Restore Jenkins Volume Container -- Getting info 
      community.docker.docker_container_info:
        name: box_restore_1
      register: box_restore_1

    - name: (1/3) Restore Jenkins Volume Container -- Checking Exit Status  
      debug:
        var: box_restore_1.container.State.Status 

    - name: (1/3) Restore Jenkins Volume Container -- Starting 
      community.docker.docker_container:
        name: box_restore_1
        image: busybox
        command: sh -c "chown 1000:1000 /var/jenkins_home"
        volumes:
          - busyboxvol:/var/jenkins_home 
        state: started
      when: (box_restore_1.container.State.Status is undefined) or
            (box_restore_1.container.State.Status != "exited")  
 
    - name: (2/3) Backup Jenkins Unzip Container -- Geting info
      community.docker.docker_container_info:
        name: box_restore_2
      register: box_restore_2

    - name: (2/3) Backup Jenkins Unzip Container -- Checking Exit Status
      debug:
        var: box_restore_2.container.State.Status         

    - name: (2/3) Backup Jenkins Unzip Container -- Starting
      community.docker.docker_container:
        name: box_restore_2
        image: busybox
        command: sh -c "cd /var/jenkins_home && tar xvfz /backup/backup.tar.gz --strip 2"
        volumes:
          - "{{ dest_dir }}:/backup"
        volumes_from:
          - box_restore_1        
        state: started
      when: (box_restore_2.container.State.Status is undefined) or
            (box_restore_2.container.State.Status != "exited")       
  
    - name: (2/3) Backup Jenkins Unzip Container -- Waiting Exit Status
      community.docker.docker_container_info:
        name: box_restore_2
      register: box_restore_2
      until: box_restore_2.container.State.Status != "running"
      retries: 24
      delay: 5

    - name: (2/3) Backup Unzip Container -- Checking Exit Status
      debug:
        var: box_restore_2.container.State.Status      
    
    - name: (3/3) Jenkins Main Container -- Starting 
      community.docker.docker_container:
        name: box_restore_3
        image: "{{ container_image }}"
        volumes:
          - busyboxvol:/var/jenkins_home
          - jenkins-docker-certs:/certs/client:ro
        ports:
          - "8080:8080"
          - "50000:50000"
        env:
          DOCKER_HOST: "tcp://docker:2376"
          DOCKER_CERT_PATH: "/certs/client"
          DOCKER_TLS_VERIFY: "1" 
        detach: true
        state: started
        restart_policy: on-failure 
      register: box_restore_3

    - name: (3/3) Jenkins Main Container -- Checking Running Status 
      debug:
        var: box_restore_3.container.State.Status

_EOF_

