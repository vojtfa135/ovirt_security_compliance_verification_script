# ovirt_security_compliance_verification_script

## In order to run this script first fill in accordingly variables in vars_files i.e. engine.yml and hosts.yml
engine.yml
```shell
---
engine_profile: internal
engine_username: "username"
engine_username_full: "{{ engine_username }}@{{ engine_profile }}"
engine_password: "secret"
engine_url: "https://hosted-engine.lab.com"
```

hosts.yml
```shell
---
host_username: "username"
host_password: "secret"
```

## Then fill in accordingly variables at the top of the Makefile
Makefile
```shell
SECRET = "secret"
USERNAME = "username"
```

## Then install necessary dependencies
Make sure your current directory is the one of this script.
```shell
sudo yum install -y epel-release ansible
sudo yum groupinstall -y "Development tools"
./install_local.sh
```

## Finally run commands as according to the Makefile
Make sure your current directory is the one of this script.
```shell
make test-fips
make test-stig
make test-cc
make test-all
```