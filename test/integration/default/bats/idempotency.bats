#!/usr/bin/env bats
#

#
# Idempotence test
# from https://github.com/neillturner/kitchen-ansible/issues/92
#

@test "Second run should change nothing" {
    if [ -f /etc/redhat-release ]; then
      skip "centos7 - yum | Ensure haveged is running and enabled on boot."
    elif [ -f /etc/debian_version ]; then
      skip "ubuntu - apt | MIG dependencies - ansible v2.2 ???"
    fi
    run bash -c "ansible-playbook -i /tmp/kitchen/hosts /tmp/kitchen/default.yml -c local 2>&1 | tee /tmp/idempotency.test | grep -q 'changed=0.*failed=0' && exit 0 || exit 1"
    [ "$status" -eq 0 ]
}

