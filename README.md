# Raspberry Pi Ansible

Glenn K. Lockwood, October 2018

## Introduction

This is an Ansible configuration that configures a fresh Raspbian installation
on Raspberry Pi.  It is intended to be run in local (pull) mode, where ansible
is running on the same Raspberry Pi to be configured.

## Bootstrapping on Raspbian

You will need ansible installed on the Raspberry Pi being configured.  This
playbook relies on Ansible 2.8 or newer, which means you can no longer use
`sudo apt-get install ansible`.  Instead, you must

    $ python3 -m venv --system-site-packages ansible_env
    
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

This playbook can be run on localhost or against one or more remote hosts.  The
former is good for a bare Raspberry Pi that was freshly provisioned using NOOBS
or the like, as you don't need a second host to act as the provisioning host.
The latter is the conventional way in which ansible is typically run and makes
more sense if you want to configure a bunch of Raspberry Pis.

### Local Mode

Edit `local.yml` and add the mac address of `eth0` for the Raspberry Pi to
configure to the `macaddrs` variable.  Its key should be a mac address (all
lower case) and the value should be the short hostname of that system.  Each
such entry's short hostname must match a file in the `host_vars/` directory.

### All modes

The contents of each file in `host_vars/` is the intended configuration state
for each Raspberry Pi.  Look at one of the examples included to get a feel for
the configurations available.

To add local users, create and edit `roles/common/vars/users.yml`.  Follow the
structure in `roles/common/vars/users.yml.example`.  You can/should
`ansible-vault` this file.

## Running the playbook

### Local Mode

Then run the playbook:

    (ansible_env) $ ansible-playbook --ask-vault-pass --become --become-user root --ask-become-pass --inventory hosts ./local.yml

The playbook will self-discover its settings, then idempotently configure the
Raspberry Pi.

### Remote Mode

This is similar to local mode:

    (ansible_env) $ ansible-playbook --ask-vault-pass --inventory hosts.remote ./remote.yml

The playbook follows the same code path.

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
2. Rename each file from `ssh_host_*_key` to `ssh_host_*_key.hostname` where
   `hostname` matches the `hostname` in `roles/common/vars/main.yml` to which
   the hostkey should be deployed
3. `ansible-vault encrypt roles/common/files/etc/ssh/ssh_host_*_key.*`
4. Add these files to `roles/common/vars/main.yml`

The format expected in `roles/common/vars/main.yml` is something like

    ---
    macaddrs:
        dc:a6:32:8c:8a:53:
            hostname: "cloverdale"
            # ...
            ssh_host_key_files:
              - etc/ssh/ssh_host_rsa_key.cloverdale
              - etc/ssh/ssh_host_dsa_key.cloverdale
              - etc/ssh/ssh_host_ecdsa_key.cloverdale
              - etc/ssh/ssh_host_ed25519_key.cloverdale

## Acknowledgment

I stole a lot of knowledge from https://github.com/giuaig/ansible-raspi-config/.
