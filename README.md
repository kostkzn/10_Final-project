# Simple Web Application Continuous Delivery

## Motivation

It was supposed that the choosing of the task will introduce to complexities of deploying web applications using technology of containerization technology and configuration management tools

## Actuality

Using management tools and containers as computational agents with required dependencies for building/testing/deploying applications provides a scalable efficiency and offload of main manager server

## Main goal

Provide a automated release management  of java web application using Jenkins via conterization and Ansible for continuous delivery

## Tasks

- Configure CI pipeline on Jenkins host Container with Remote API
- Build [Jenkins agent Docker image](https://hub.docker.com/repository/docker/kostkzn/jenkins-agent-maven-jdk11/general) & integrate with Jenkins host
- Configure additional agent host with Ansible tool to Deploy application to Tomcat servlet 
- Configure AWS hosts for migration to cloud setup

## Design

![The setup structure](Images/01.jpg)

- Git – version control system
- Jenkins – continuous integration server
- Maven – build tool for java applications
- NEXUS – artifact repository with a cache of necessary dependencies on it
- Ansible – configuration for stack of hosts and delivery application to server
- Tomcat – server/webcontainer for java applications
- AWS – provides cloud computing

## Implementation

[AWS CodeStar](https://aws.amazon.com/codestar/) demo web application were taken for implementation with minor visual changes

The basic code is located on [https://github.com/kostkzn/aws-codestar-tomcatweb](https://github.com/kostkzn/aws-codestar-tomcatweb)

The code also contains testing instructions and ansible playbook for app deploying to Tomcat

Another ansible playbook for configuration of cloud stack located [here](/ansible_inits/). The playbook isn't yet pumped to full automation but is really helps for quick setup of Tomcat and Docker environment

## Demo

Hosts stack on AWS

![Hosts stack on AWS](Images/02.jpg)

Initial page of Tomcat after installing

![Initial page of Tomcat](Images/03.jpg)

Jenkins pipeline

![Jenkins pipeline](Images/04.jpg)

First application deploy

![First deploy](Images/05.jpg)

Some visual code changes triggers a second pipeline iteration

![Some code editions](Images/06.jpg)

![Second pipeline iteration](Images/07.jpg)

New results

![Second deploy](Images/08.jpg)

Saved artifacts on NEXUS repository

![Saved artifacts on repository](Images/09.jpg)

Cashed dependencies

![Cashed dependencies](Images/10.jpg)

## Conclusions

There's always room for improvement. The next expert level is a single keyboard command to complete full CI/CD. and deep understanding of architectures

There is a need to delve into understanding application architectures, to understand the pros and cons
