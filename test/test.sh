#!/usr/bin/env bash

if [ ${#} -gt 0 ]
then
    COMMAND=${*}
else
    COMMAND='kitchen test --destroy=passing --color centos-centos-6     ; \
             kitchen test --destroy=passing --color centos-centos-7     ; \
             kitchen test --destroy=passing --color debian-debian-6     ; \
             kitchen test --destroy=passing --color debian-debian-7     ; \
             kitchen test --destroy=passing --color debian-debian-8     ; \
             kitchen test --destroy=passing --color debian-debian-9     ; \
             kitchen test --destroy=passing --color debian-debian-10    ; \
             kitchen test --destroy=passing --color ubuntu-ubuntu-12-04 ; \
             kitchen test --destroy=passing --color ubuntu-ubuntu-14-04 ; \
             kitchen test --destroy=passing --color ubuntu-ubuntu-16-04'
fi

docker run \
       --privileged \
       --rm \
       --volume ${PWD}:/usr/src \
       --volume /sys/fs/cgroup:/sys/fs/cgroup \
       --volume /var/run/docker.sock:/var/run/docker.sock \
       vpgrp/kitchen \
       bash -c "cd /usr/src && ${COMMAND}"
# EOF
