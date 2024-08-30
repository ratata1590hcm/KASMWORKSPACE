#!/usr/bin/env bash
set -ex
if [[ "${DISTRO}" == @(oracle8|rockylinux9|rockylinux8|oracle9|almalinux9|almalinux8|fedora37|fedora38|fedora39|fedora40) ]]; then
  dnf install -y gimp
  if [ -z ${SKIP_CLEAN+x} ]; then
    dnf clean all
  fi
else
  yum install -y gimp
  if [ -z ${SKIP_CLEAN+x} ]; then
    yum clean all
  fi
fi
cp /usr/share/applications/gimp.desktop $HOME/Desktop/
chmod +x $HOME/Desktop/gimp.desktop
