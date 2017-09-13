# Raspberry Pi Ansible

Glenn K. Lockwood, August 2017

## Introduction

This is an Ansible configuration that configures a fresh Raspbian installation
on Raspberry Pi.  This is very much a work in progress and not intended to be
used by anyone but me.

## Bootstrapping on Raspbian

If you want to use these playbooks to make a Raspberry Pi self-configure,
install Ansible by doing the following:

    $ pip install --user ansible
    $ ssh-keygen
    $ ssh-copy-id localhost

If not bootstrapping from the Raspberry Pi itself, you can instead do

    $ ssh-copy-id pi@raspberrypi

and authenticate using the default `raspberry` password.  This will enable
key-based authentication to the remote Raspberry Pi to be configured.

You can ensure that Ansible is able to configure using the following:

    $ ansible -i hosts all -m ping

You can also ensure that authentication also works.

    $ ansible -i hosts -u pi --sudo-user root all -a "/usr/bin/id -u"

## Running the Playbook

This playbook will deactivate password authentication for the `pi` user since
it assumes that you have key-based authentication configured _before_ the
playbook is executed.  Be sure that is the case or you may be locked out of
your Raspberry Pi altogether.

Then run the playbook:

    $ ansible-playbook --inventory-file hosts --limit cloverfield --user pi --sudo site.yml

or

    $ ansible-playbook -i hosts -l clovermine -u pi -s site.yml

Raspbian should allow the `pi` user to sudo without a password.  If not, run
using `--ask-become-pass` (or `-K`) and enter the sudo password (default would
be `raspberry`) for the remote user (`pi`).
