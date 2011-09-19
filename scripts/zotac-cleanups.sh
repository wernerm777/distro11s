#!/bin/bash
source `dirname $0`/common.sh

#Load ath9k module with nohwcrypt parametar at boot time
add_text "options ath9k nohwcrypt=1" ${STAGING}/etc/modprobe.d/local.conf

#Activate syntax highlightning
[ ! -e ${STAGING}/root/.vimrc ] || touch ${STAGING}/root/.vimrc
add_text "syntax on" ${STAGING}/root/.vimrc

#Make VIM the default editor
add_text "export EDITOR=vim" ${STAGING}/root/.bashrc

#Install & configure acpid to enable clean shutdown when pressing the power
#button
sudo mount proc ${STAGING}/proc/ -t proc
sudo chroot ${STAGING} apt-get -y --force-yes install acpid
sudo umount ${STAGING}/proc/

#Enabling coredumps for meshtkid
if [ "`grep ulimit ${STAGING}/usr/local/bin/meshkitd`" == "" ]; then
	sed '/bash/ a\
ulimit -c 100000' ${STAGING}/usr/local/bin/meshkitd > /tmp/meshkitd
	mv /tmp/meshkitd ${STAGING}/usr/local/bin/meshkitd
	chmod 755 ${STAGING}/usr/local/bin/meshkitd
fi

#Seting coredump output folder
mkdir -p ${STAGING}/var/log/dumps
sudo chown -R root.root ${STAGING}/var/log/dumps
sudo chmod -R 1777 ${STAGING}/var/log/dumps
add_text "#Core Files Destination: core_filename_pid_time_signal" ${STAGING}/etc/sysctl.conf
add_text "kernel.core_pattern=/var/log/dumps/core_%e_%p_%t_%s" ${STAGING}/etc/sysctl.conf

# set regulatory domain
echo "configuring regulatory domain: ${DISTRO11S_REGDOMAIN}"
echo "sed -i \"s/^REGDOMAIN=/REGDOMAIN=${DISTRO11S_REGDOMAIN}/\" ${STAGING}/etc/default/crda" | sudo sh
# CRDA debian package expects iw in /usr/sbin/ and /sbin/
sudo ln -s ${STAGING}/usr/local/sbin/iw ${STAGING}/usr/sbin/iw
sudo ln -s ${STAGING}/usr/local/sbin/iw ${STAGING}/sbin/iw
# udev rules don't work as expected. We use rc.local as a workaround to set the
# regulatory domain
echo "$(cat <<EOF
#!/bin/sh -e
export COUNTRY=00
/sbin/crda
exit 0
EOF
)" > /tmp/rc.local
sudo mv /tmp/rc.local ${STAGING}/etc/

# Disable DNS lookup - Makes SSH login faster
add_text "UseDNS no" ${STAGING}/etc/ssh/sshd_config

# Add some jobs to cron: memstats, logrotate, ..
sudo chroot ${STAGING} crontab -r
sudo touch ${STAGING}/tmp/mycron
add_text '*/20 * * * * /usr/local/bin/memstats >> /var/log/memstats.log' ${STAGING}/tmp/mycron
add_text '*/20 * * * * /usr/local/bin/peerstats >> /var/log/peerstats.log' ${STAGING}/tmp/mycron
add_text '1 */1 * * * /usr/sbin/logrotate /etc/logrotate.conf' ${STAGING}/tmp/mycron
sudo chroot ${STAGING} crontab /tmp/mycron
sudo rm ${STAGING}/tmp/mycron
