FROM jenkins/agent:latest-jdk11
# if we want to install via apt
USER root
RUN apt-get update && apt-get install -y maven
# drop back to the regular jenkins user - good practice
USER jenkins

# docker build -t jenkins-agent-maven:kzn-v1 .