# Raspberry Pi Ansible

Glenn K. Lockwood, October 2018

## Introduction

This is an Ansible configuration that configures a fresh Raspbian installation
on Raspberry Pi.  It is intended to be run in local (pull) mode, where ansible
is running on the same Raspberry Pi to be configured.

## Bootstrapping on Raspbian

You will need ansible installed on the Raspberry Pi being configured.

    $ sudo apt-get install ansible

## Configuration

The `macaddrs` structure in _roles/common/vars/main.yml_ maps the MAC address of
a Raspberry Pi to its intended configuration state.  Add your Raspberry Pi's MAC
address to that structure and set its configuration accordingly.

## Running the playbook

Then run the playbook:

    $ sudo ansible-playbook local.yml 

The playbook will self-discover its settings, then idempotently configure the
Raspberry Pi.

## After running the playbook

This playbook purposely requires a few manual steps _after_ running the playbook
to ensure that it does not lock you out of your Raspberry Pi.

1. While logged in as pi, `sudo passwd glock` (or whatever username you created)
   to set a password for that user.  This is _not_ required to log in as that
   user, but it _is_ required to `sudo` as that user.  You may also choose to
   set a password for the pi and/or root users.

2. `usermod --lock pi` to ensure that the default user is completely disabled.

## Acknowledgment

I stole a lot of knowledge from https://github.com/giuaig/ansible-raspi-config/.
