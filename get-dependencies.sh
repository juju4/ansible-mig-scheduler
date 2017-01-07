#!/bin/sh
## one script to be used by travis, jenkins, packer...

umask 022

rolesdir=$(dirname $0)/..

[ ! -d $rolesdir/juju4.redhat-epel ] && git clone https://github.com/juju4/ansible-redhat-epel $rolesdir/juju4.redhat-epel
[ ! -d $rolesdir/juju4.golang ] && git clone https://github.com/juju4/ansible-golang $rolesdir/juju4.golang
## galaxy naming: kitchen fails to transfer symlink folder
#[ ! -e $rolesdir/juju4.mig-scheduler ] && ln -s ansible-mig-scheduler $rolesdir/juju4.mig-scheduler
[ ! -e $rolesdir/juju4.mig-scheduler ] && cp -R $rolesdir/ansible-mig-scheduler $rolesdir/juju4.mig-scheduler

## don't stop build on this script return code
true

