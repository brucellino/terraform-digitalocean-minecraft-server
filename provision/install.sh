#!/bin/env bash
set -eo pipefail

echo "starting install"
cat <<EOF >20auto-upgrades
// Do "apt-get update" automatically every n-days (0=disable)
APT::Periodic::Update-Package-Lists "0";
// Run the "unattended-upgrade" security upgrade script
// every n-days (0=disabled)
// Requires the package "unattended-upgrades" and will write
// a log in /var/log/unattended-upgrades
APT::Periodic::Unattended-Upgrade "0";
// Do "apt-get upgrade --download-only" every n-days (0=disable)
APT::Periodic::Download-Upgradeable-Packages "0";
// Do "apt-get autoclean" every n-days (0=disable)
APT::Periodic::AutocleanInterval "0";
// Send report mail to root
//     0:  no report             (or null string)
//     1:  progress report       (actually any string)
//     2:  + command outputs     (remove -qq, remove 2>/dev/null, add -d)
//     3:  + trace on
APT::Periodic::Verbose "1";
EOF
mv -f 20auto-upgrades /etc/apt/apt.conf.d/20auto-upgrades
chmod 644 /etc/apt/apt.conf.d/20auto-upgrades
apt-get purge -y unattended-upgrades
systemctl stop apt-daily.timer
systemctl disable apt-daily.timer
systemctl mask apt-daily.service
rm /usr/lib/apt/apt.systemd.daily
apt-get update
kill -9 "$(lsof -t /var/lib/dpkg/lock-frontend)" || echo "not running"
apt-get install -y openjdk-17-jre-headless jq git
java -version

# Make minecraft user
useradd -m minecraft
mkdir -p /home/minecraft/plugins
PAPER_VERSION=1.19.2
PAPER_DOWNLOADS=https://api.papermc.io/v2/projects/paper/versions/${PAPER_VERSION}
# Get paper
PAPER_BUILD="$(curl -fs ${PAPER_DOWNLOADS}/builds | jq -r '.builds[-1].build')"
curl -fs -o /home/minecraft/paper.jar "${PAPER_DOWNLOADS}/builds/${PAPER_BUILD}/downloads/paper-${PAPER_VERSION}-${PAPER_BUILD}.jar"

curl -fs -o /home/minecraft/plugins/server-essentials.jar https://dev.bukkit.org/projects/server-essentials-for-bukkit/files/3975569/download
nohup sudo -u minecraft java -Xms2G -Xmx2G -jar /home/minecraft/paper.jar --nogui &
