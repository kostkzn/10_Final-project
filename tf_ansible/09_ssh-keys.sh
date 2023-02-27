#!/bin/bash
cat << _EOF_ > /home/ubuntu/.ssh/ci-swapp.pem
-----BEGIN RSA PRIVATE KEY-----
# PUT YOU SSH KEY HERE
-----END RSA PRIVATE KEY-----
_EOF_
