# Raspberry Pi Ansible Playbook

Glenn K. Lockwood, October 2018 - June 2021.

## Introduction

This is an Ansible configuration that configures a fresh Raspbian installation
on Raspberry Pi.  It can be run in local (pull) mode, where ansible is running
on the same Raspberry Pi to be configured, or standard remote mode.  This
playbook is known to run on Raspberry Pi OS 11.

Also included are plays for use with other single-board computers including
NVIDIA Jetson Nano and BeagleBone Black.

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
the configurations available.  Most variables should be optional, and if left
undefined, do not enforce a specific configuration.

To add local users, create and edit `roles/rpi/vars/users.yml`.  Follow the
structure in `roles/rpi/vars/users.yml.example`.  You can/should
`ansible-vault` this file.

## Using Remote Mode

Run one of the playbooks as you would do normally:

    (ansible_env) $ ansible-playbook ./rpi.yml

The default hosts file and `become_*` configurations are set in ansible.cfg.

If you are bootstrapping a completely fresh system with the default users and
hostnames, you may have to do the following:

**Step 1:** Add a config to `~/.ssh/config` to map your intended hostname to
the IP address of your fresh system.  For example,

```
Host mynewrpi
    Hostname 192.168.1.101
    User pi
```
   
This allows, for example, `ssh mynewrpi` to work even if `mynewrpi`'s hostname
hasn't yet been from the default.

**Step 2:** `ssh-copy-id mynewrpi` to ensure passwordless SSH works to the new
host.  This will also make sure that your step 1 above was done correctly.

**Step 3:** Run the Ansible playbook to create new users and do most of the
system configuration

**Step 4:** Set a password for new user(s) created by Ansible by logging in as
the default privileged user (`pi`) and `sudo passwd username`.  This is required
for the new user(s) to be able to sudo.

After you run the playbook, the Raspberry Pi is configured, and your new user(s)
have been created and passwords set, delete the changes you made to
`~/.ssh/config` so that you can disable the default user and switch to using
the new user that Ansible created.

## Using Local Mode

Edit `local.yml` and add the mac address of `eth0` for the Raspberry Pi to
configure to the `macaddrs` variable.  Its key should be a mac address (all
lower case) and the value should be the short hostname of that system.  Each
such entry's short hostname must match a file in the `host_vars/` directory.

Then run the playbook:

    (ansible_env) $ ansible-playbook ./local.yml

The playbook will self-discover its settings, then idempotently configure the
Raspberry Pi.

That said, it is better to use remote mode (so Ansible ssh'es into localhost)
since that's what I most commonly test.

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

## Adding a new host to an existing role

In broad strokes, the process for adding a new host whose board-specific role
already exists is

1. Add the new host to `hosts`.
2. Creating `host_vars/newhost.yml` and filling it out appropriately.  It's
   easiest to start with an existing file for the same board type (e.g.,
   `cloverdale.yml` for Raspberry Pi) and change it.  Be sure to change the
   `target_hostname` variable at minimum.

## Acknowledgment

I stole a lot of knowledge from https://github.com/giuaig/ansible-raspi-config/.
