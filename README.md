# Raspberry Pi Ansible

Glenn K. Lockwood, August 2017

## Introduction

This is an Ansible configuration that configures a fresh Raspbian installation
on Raspberry Pi.  This is very much a work in progress and not intended to be
used by anyone but me.

## Bootstrapping on Raspbian

If you want to use these playbooks to make a Raspberry Pi self-configure,
install Ansible by doing the following:

    # apt-get install ansible
    # pip install --user ansible
    # ssh-keygen
    # ssh-copy-id localhost

You can ensure that Ansible is able to configure using the following:

    $ ansible -i hosts all -m ping
    $ ansible -i hosts -u pi --sudo-user root all -a "/usr/bin/id -u"
