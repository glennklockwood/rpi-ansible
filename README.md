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

## Running the Playbook

Authentication will be an issue since the configuration disables the default
user (`pi`) and adds new privileged users.  This means that you will probably
have to specify different `--sudo-user` options depending on how far into the
configuration you got.  For example, assuming the `pi` user still exists,

    $ ansible-playbook --inventory-file hosts --limit clovermine --ask-sudo-pass --sudo --sudo-user pi site.yml

You will be asked for the sudo password, which is the same as `pi`'s password
(which defaults to `raspberry`).  Once the users are set up and `pi` is no
longer a valid user.

    $ ansible-playbook -i hosts -l clovermine -K -s -U glock site.yml
