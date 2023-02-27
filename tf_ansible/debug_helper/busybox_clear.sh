#!/bin/bash

docker stop box_restore_3
docker rm box_restore_3
docker rm box_restore_2
docker rm box_restore_1
docker volume rm busyboxvol
# rm -fv /home/vagrant/backup.tar.gz
