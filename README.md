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

The `macaddrs` structure in _roles/common/vars/main.yml_ maps the MAC address of
a Raspberry Pi to its intended configuration state.  Add your Raspberry Pi's MAC
address (specifically for `eth0` if your RPi has multiple NICs) to that
structure and set its configuration accordingly.

To add local users, create and edit `roles/common/vars/users.yml`.  Follow the
structure in `roles/common/vars/users.yml.example`.  You can/should
`ansible-vault` this file.

## Running the playbook

Then run the playbook:

    (ansible_env) $ ansible-playbook --ask-vault-pass --become --become-user root --ask-become-pass ./local.yml

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

### Remote mode

The playbooks can also be run in a traditional remote mode:

    $ ansible-playbook --ask-become-pass --ask-vault-pass --inventory hosts.remote ./remote.yml

At present this does _not_ make use of hostvars; this is because the playbook
started out designed to be run against localhost and the playbook
self-identifies the system and fetches configuration variables from
`roles/common/vars/main.yml` based on that.

## Acknowledgment

I stole a lot of knowledge from https://github.com/giuaig/ansible-raspi-config/.
