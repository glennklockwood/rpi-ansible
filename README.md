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
    
## Configuration

The `macaddrs` structure in _roles/common/vars/main.yml_ maps the MAC address of
a Raspberry Pi to its intended configuration state.  Add your Raspberry Pi's MAC
address (specifically for `eth0` if your RPi has multiple NICs) to that
structure and set its configuration accordingly.

## Running the playbook

Then run the playbook:

    (ansible_env) $ sudo $(which ansible-playbook) --ask-vault-pass ./local.yml

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

1. drop the appropriate `ssh_host_*_key` files into `roles/common/files/etc/ssh/`
2. rename each file from `ssh_host_*_key` to `ssh_host_*_key.hostname` where
   `hostname` matches the `hostname` in `roles/common/vars/main.yml` to which
   the hostkey should be deployed
3. `ansible-vault encrypt roles/common/files/etc/ssh/ssh_host_*_key.*`

## Acknowledgment

I stole a lot of knowledge from https://github.com/giuaig/ansible-raspi-config/.
