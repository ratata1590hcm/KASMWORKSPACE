#!/usr/bin/env bash
set -ex

# Install
if [[ "${DISTRO}" == @(centos|oracle8|rockylinux9|rockylinux8|oracle9|almalinux9|almalinux8|fedora37|fedora38|fedora39|fedora40) ]]; then
  if [[ "${DISTRO}" == @(oracle8|rockylinux9|rockylinux8|oracle9|almalinux9|almalinux8|fedora37|fedora38|fedora39|fedora40) ]]; then
    dnf install -y thunderbird
    if [ -z ${SKIP_CLEAN+x} ]; then
      dnf clean all
    fi
  else
    yum install -y thunderbird
    if [ -z ${SKIP_CLEAN+x} ]; then
      yum clean all
    fi
  fi
elif [ "${DISTRO}" == "opensuse" ]; then
  zypper install -yn MozillaThunderbird
  if [ -z ${SKIP_CLEAN+x} ]; then
    zypper clean --all
  fi
elif grep -q "ID=debian" /etc/os-release; then
  apt-get update
  apt-get install -y thunderbird
  if [ -z ${SKIP_CLEAN+x} ]; then
  apt-get autoclean
  rm -rf \
    /var/lib/apt/lists/* \
    /var/tmp/*
  fi
else
  apt-get update
  if [ ! -f '/etc/apt/preferences.d/mozilla-firefox' ]; then
    add-apt-repository -y ppa:mozillateam/ppa
    echo '
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
' > /etc/apt/preferences.d/mozilla-firefox
  fi
  apt-get install -y thunderbird
  if [ -z ${SKIP_CLEAN+x} ]; then
  apt-get autoclean
  rm -rf \
    /var/lib/apt/lists/* \
    /var/tmp/*
  fi
fi

# Desktop icon
if [[ "${DISTRO}" == @(fedora37|fedora38|fedora39) ]]; then
  cp /usr/share/applications/mozilla-thunderbird.desktop $HOME/Desktop/
  chmod +x $HOME/Desktop/mozilla-thunderbird.desktop
elif [[ "${DISTRO}" == "fedora40" ]]; then
  cp /usr/share/applications/org.mozilla.thunderbird.desktop $HOME/Desktop/
  chmod +x $HOME/Desktop/org.mozilla.thunderbird.desktop
else
  cp /usr/share/applications/thunderbird.desktop $HOME/Desktop/
  chmod +x $HOME/Desktop/thunderbird.desktop
fi

# Cleanup for app layer
chown -R 1000:0 $HOME
find /usr/share/ -name "icon-theme.cache" -exec rm -f {} \;
