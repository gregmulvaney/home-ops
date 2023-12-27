#!/bin/bash

echo "lxc.apparmor.profile: unconfined" >> ${config_file}
echo "lxc.cgroup2.devices.allow: a" >> ${config_file}
echo "lxc.cap.drop:" >> ${config_file}
echo "lxc.mount.auto: "proc:rw sys:rw"" >> ${config_file}

rm -rf /root/app_armor_${key}.sh



