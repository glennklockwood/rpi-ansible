# Raspberry Pi Ansible Playbook

Glenn K. Lockwood, October 2018 - July 2020.

## Introduction

This is an Ansible configuration that configures a fresh Raspbian installation
on Raspberry Pi.  It can be run in local (pull) mode, where ansible is running
on the same Raspberry Pi to be configured, or standard remote mode.

This playbook is known to run on Raspbian stretch (9) and Raspberry Pi OS
buster (10).  I've not been able to run it on jessie because that ships with
Python 2.4, which is not supported by Ansible.  It can run against jessie in
remote mode.  See below.

## Bootstrapping on Raspbian

You will need ansible installed on the Raspberry Pi being configured.  This
playbook relies on Ansible 2.8 or newer, which means you can no longer use
`sudo apt-get install ansible`.  Instead, you must

    $ python3 -m venv --system-site-packages ansible_env

If this fails, you may need to:

    $ sudo apt install python3-apt python3-virtualenv

Then activate the environment and install ansible:
    
    $ source ./ansible_env/bin/activate
    
    # Make sure that pip will install into our virtualenv
    (ansible_env) $ which pip
    /home/pi/src/git/rpi-ansible/ansible/bin/pip
    
    # Install ansible and any other requirements
    (ansible_env) $ pip install -r requirements.txt

Note that the Python 3.5 that ships with Debian 9.13 doesn't install pip when
`-m venv` is used as above.  It may be easier to simply use

    $ pip3 install --user ansible

which pollutes your login Python environment, but is better than nothing.

## Configuration

The contents of each file in `host_vars/` is the intended configuration state
for each Raspberry Pi.  Look at one of the examples included to get a feel for
the configurations available.

To add local users, create and edit `roles/common/vars/users.yml`.  Follow the
structure in `roles/common/vars/users.yml.example`.  You can/should
`ansible-vault` this file.

## Using Local Mode

Edit `local.yml` and add the mac address of `eth0` for the Raspberry Pi to
configure to the `macaddrs` variable.  Its key should be a mac address (all
lower case) and the value should be the short hostname of that system.  Each
such entry's short hostname must match a file in the `host_vars/` directory.

Then run the playbook:

    (ansible_env) $ ansible-playbook ./local.yml

The playbook will self-discover its settings, then idempotently configure the
Raspberry Pi.

## Using Remote Mode

Run one of the playbooks as you would do normally:

    (ansible_env) $ ansible-playbook ./rpi.yml

The default hosts file and `become_*` configurations are set in ansible.cfg.

## After running the playbook

This playbook purposely requires a few manual steps _after_ running the playbook
to ensure that it does not lock you out of your Raspberry Pi.

1. While logged in as pi, `sudo passwd glock` (or whatever username you created)
   to set a password for that user.  This is _not_ required to log in as that
   user, but it _is_ required to `sudo` as that user.  You may also choose to
   set a password for the pi and/or root users.

2. `usermod --lock pi` to ensure that the default user is completely disabled.

## Optional configurations

### SSH host keys

This playbook can install ssh host keys.  To do so,

1. Drop the appropriate `ssh_host_*_key` files into `roles/common/files/etc/ssh/`
2. Rename each file from `ssh_host_*_key` to `ssh_host_*_key.{{ ansible_hostname }}`
3. `ansible-vault encrypt roles/common/files/etc/ssh/ssh_host_*_key.*`

The playbook will detect the presence of these files and install them.

## Acknowledgment

I stole a lot of knowledge from https://github.com/giuaig/ansible-raspi-config/.
