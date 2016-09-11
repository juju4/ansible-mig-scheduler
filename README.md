[![Build Status](https://travis-ci.org/juju4/ansible-mig-scheduler.svg?branch=master)](https://travis-ci.org/juju4/ansible-mig-scheduler)

# MIG ansible role: mig-scheduler service

Ansible role to setup MIG aka Mozilla InvestiGator: mig-scheduler component
Refer to [mig master role](https://github.com/juju4/ansible-mig) for complete integration.
http://mig.mozilla.org/

## Requirements & Dependencies

### Ansible
It was tested on the following versions:
 * 2.0

### Operating systems

Tested with vagrant on Ubuntu 14.04, Kitchen test with xenial, trusty and centos7

## Example Playbook

Just include this role in your list.

## Variables

There is a good number of variables to set the different settings of MIG. Both API and RabbitMQ hosts should be accessible to clients.
Some like password should be stored in ansible vault for production systems at least.

```
mig_user: "_mig"

mig_gover: 1.6.2
mig_gopath: "/home/{{ mig_user }}/go"
mig_src: "{{ mig_gopath }}/src/mig.ninja/mig"
mig_api_host: localhost
#mig_api_port: 51664
mig_api_port: 1664
mig_server_withagent: true

mig_enable_auth: true

mig_db_host: 127.0.0.1
mig_db_port: 5432
mig_db_migadmin_pass: xxx
mig_db_migapi_pass: xxx
mig_db_migscheduler_pass: xxx

mig_rabbitmq_host: localhost
mig_rabbitmq_port: 5672
mig_rabbitmq_vhost: mig

```

## Continuous integration


This role has a travis basic test (for github), more advanced with kitchen and also a Vagrantfile (test/vagrant).
Default kitchen config (.kitchen.yml) is lxd-based, while (.kitchen.vagrant.yml) is vagrant/virtualbox based.

Once you ensured all necessary roles are present, You can test with:
```
$ gem install kitchen-ansible kitchen-lxd_cli kitchen-sync kitchen-vagrant
$ cd /path/to/roles/mig-scheduler
$ kitchen verify
$ kitchen login
$ KITCHEN_YAML=".kitchen.vagrant.yml" kitchen verify
```
or
```
$ cd /path/to/roles/mig-scheduler/test/vagrant
$ vagrant up
$ vagrant ssh
```


## Troubleshooting & Known issues

* mig-scheduler not starting
```
$ $GOPATH/src/mig.ninja/mig/bin/linux/amd64/mig-scheduler 
Initializing Scheduler context...
FATAL: Init() -> initRelay() -> tls: oversized record received with length 20480
```
=
check ssl configuration is consistent on both scheduler and nginx/rabbitmq (fully disabled or enabled)

* pq: relation \"agents_stats\" does not exist
```
$ curl http://localhost/api/v1/dashboard
{"collection":{"version":"1.0","href":"http://localhost:51664/api/v1/dashboard","template":{},"error":{"code":"5505623982082","message":"Error while retrieving agent statistics: 'pq: relation \"agents_stats\" does not exist'"}}}
```
check that postgresql database is initialized

* no access to this vhost
```
$ $GOPATH/src/mig.ninja/mig/bin/linux/amd64/mig-scheduler 
Initializing Scheduler context...
FATAL: Init() -> initRelay() -> Exception (403) Reason: "no access to this vhost"
```
=
check rabbitmq available, configured and permissions applied on the right vhost
```
$ sudo -u rabbitmq rabbitmqctl status
$ sudo -u rabbitmq rabbitmqctl list_vhosts
$ sudo -u rabbitmq rabbitmqctl list_users
$ sudo -u rabbitmq rabbitmqctl list_permissions
$ tail /var/log/rabbitmq/rabbit*
```

* pq: role "migscheduler" does not exist
```
$ $GOPATH/src/mig.ninja/mig/bin/linux/amd64/mig-scheduler
Initializing Scheduler context...
FATAL: Init() -> initSecring() -> makeSecring() -> Error while retrieving scheduler private key: 'pq: role "migscheduler" does not exist'
```
=
check no typo in postgresql user name
```
$ sudo -u postgres psql
psql (9.3.10)
Type "help" for help.

postgres=# \du
                              List of roles
  Role name  |                   Attributes                   | Member of 
-------------+------------------------------------------------+-----------
 migadmin    |                                                | {}
 migapi      |                                                | {}
 migcheduler |                                                | {}
 postgres    | Superuser, Create role, Create DB, Replication | {}

postgres=# \l
                                  List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   
-----------+----------+----------+-------------+-------------+-----------------------
 mig       | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =Tc/postgres         +
           |          |          |             |             | postgres=CTc/postgres+
           |          |          |             |             | migadmin=CTc/postgres
 postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
```
*But what should be the (restricted) privileges of migapi and migscheduler?* (nothing in script)
Currently ALL

* 
```
$ cat /var/log/supervisor/mig-scheduler.log
[...]
Initializing Scheduler context...
FATAL: Init() -> initSecring() -> makeSecring() -> Error while retrieving scheduler private key: 'pq: Ident authentication failed for user "migscheduler"'
$ psql -U migscheduler -h localhost -W mig
pq: Ident authentication failed for user "migscheduler"
```
FIX: edit /var/lib/pgsql/data/pg_hba.conf, s/ident/trust/

* mig-scheduler with rabbitmq ssl not starting
```
$ cat /var/log/supervisor/mig-scheduler.log
x509: cannot validate certificate for 192.168.101.51 because it doesn't contain any IP SANs
```
check Alternate Names for openssl are filled


## License

BSD 2-clause



