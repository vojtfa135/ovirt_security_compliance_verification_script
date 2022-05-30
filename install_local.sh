#!/bin/bash

OVIRT_VERSION=44

sudo yum install -y http://resources.ovirt.org/pub/yum-repo/ovirt-release$OVIRT_VERSION.rpm

ansible-galaxy install -r requirements.yml

sudo yum install -y sshpass \
              libcurl-devel \
             python38-devel \
              openssl-devel \
              libxslt-devel \
              libxml2-devel \
               epel-release

sudo yum install -y python3-ovirt-engine-sdk4
