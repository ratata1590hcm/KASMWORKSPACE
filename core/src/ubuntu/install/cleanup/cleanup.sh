#!/usr/bin/env bash
set -ex

# Distro package cleanup
if [[ "${DISTRO}" == @(centos|oracle7) ]] ; then
  yum clean all
elif [[ "${DISTRO}" == @(almalinux8|almalinux9|fedora37|fedora38|fedora39|fedora40|oracle8|oracle9|rockylinux8|rockylinux9) ]]; then
  dnf clean all
elif [ "${DISTRO}" == "opensuse" ]; then
  zypper clean --all
elif [[ "${DISTRO}" == @(debian|kali|parrotos6|ubuntu) ]]; then
  apt-get autoremove -y
  apt-get autoclean -y
fi

# File cleanups
rm -Rf \
  /home/kasm-default-profile/.cache \
  /home/kasm-user/.cache \
  /tmp \
  /var/lib/apt/lists/* \
  /var/tmp/*
mkdir -m 1777 /tmp

# Services we don't want to start disable in xfce init
rm -f \
  /etc/xdg/autostart/blueman.desktop \
  /etc/xdg/autostart/geoclue-demo-agent.desktop \
  /etc/xdg/autostart/gnome-keyring-pkcs11.desktop \
  /etc/xdg/autostart/gnome-keyring-secrets.desktop \
  /etc/xdg/autostart/gnome-keyring-ssh.desktop \
  /etc/xdg/autostart/gnome-shell-overrides-migration.desktop \
  /etc/xdg/autostart/light-locker.desktop \
  /etc/xdg/autostart/org.gnome.Evolution-alarm-notify.desktop \
  /etc/xdg/autostart/org.gnome.SettingsDaemon.A11ySettings.desktop \
  /etc/xdg/autostart/org.gnome.SettingsDaemon.Color.desktop \
  /etc/xdg/autostart/org.gnome.SettingsDaemon.Datetime.desktop \
  /etc/xdg/autostart/org.gnome.SettingsDaemon.Housekeeping.desktop \
  /etc/xdg/autostart/org.gnome.SettingsDaemon.Keyboard.desktop \
  /etc/xdg/autostart/org.gnome.SettingsDaemon.MediaKeys.desktop \
  /etc/xdg/autostart/org.gnome.SettingsDaemon.Power.desktop \
  /etc/xdg/autostart/org.gnome.SettingsDaemon.PrintNotifications.desktop \
  /etc/xdg/autostart/org.gnome.SettingsDaemon.Rfkill.desktop \
  /etc/xdg/autostart/org.gnome.SettingsDaemon.ScreensaverProxy.desktop \
  /etc/xdg/autostart/org.gnome.SettingsDaemon.Sharing.desktop \
  /etc/xdg/autostart/org.gnome.SettingsDaemon.Smartcard.desktop \
  /etc/xdg/autostart/org.gnome.SettingsDaemon.Sound.desktop \
  /etc/xdg/autostart/org.gnome.SettingsDaemon.UsbProtection.desktop \
  /etc/xdg/autostart/org.gnome.SettingsDaemon.Wacom.desktop \
  /etc/xdg/autostart/org.gnome.SettingsDaemon.Wwan.desktop \
  /etc/xdg/autostart/org.gnome.SettingsDaemon.XSettings.desktop \
  /etc/xdg/autostart/pulseaudio.desktop \
  /etc/xdg/autostart/xfce4-power-manager.desktop \
  /etc/xdg/autostart/xfce4-screensaver.desktop \
  /etc/xdg/autostart/xfce-polkit.desktop \
  /etc/xdg/autostart/xscreensaver.desktop

# Bins we don't want in the final image
if which gnome-keyring-daemon; then
  rm -f $(which gnome-keyring-daemon)
fi

set +e

# Updating the system
echo "Updating the system..."
apt-get -qq update
apt-get -qq dist-upgrade -y

# Cleaning npm cache
echo "Cleaning npm cache..."
npm cache clean --force

# Cleaning pip cache
echo "Cleaning pip cache..."
pip cache purge

# Cleaning up APT cache
echo "Cleaning up APT cache..."
apt-get clean -y
apt-get autoclean -y
apt-get autoremove --purge -y

# Remove Old Kernels (keep the latest 2)
echo "Removing old kernels..."
apt-get purge -y $(dpkg --list 'linux-image-[0-9]*' | sed '/ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d' | head -n -2)

# Cleaning up old log files
echo "Cleaning up old log files..."
find /var/log -type f -name "*.log" -delete

# Cleaning thumbnail cache
echo "Cleaning thumbnail cache..."
rm -rf ~/.cache/thumbnails/*

# Cleaning /tmp directory
echo "Cleaning /tmp directory..."
rm -rf \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*

# Running bleachbit for system clean up
echo "Running bleachbit for system clean up..."
bleachbit --list | grep -E "[a-z0-9_\-]+\.[a-z0-9_\-]+" | grep -v 'system.free_disk_space' | grep -v 'system.memory' | grep -v 'deepscan.vim_swap_root' | grep -v 'deepscan.vim_swap_root' | xargs bleachbit --clean
echo "Cleanup completed."

# List all installed language packs
echo "Listing all installed language packs..."
dpkg --list | grep language-pack

# Remove all language packs
echo "Removing all installed language packs..."
sudo apt-get purge -y $(dpkg --list | grep '^ii' | grep 'language-pack' | awk '{print $2}')

# Clean up unused dependencies
echo "Cleaning up unused dependencies..."
sudo apt-get autoremove -y
sudo apt-get clean

# Done
echo "Language packs removed and system cleaned."
