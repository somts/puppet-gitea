#!/bin/sh

# PROVIDE: gitea
# REQUIRE: NETWORKING SYSLOG
# KEYWORD: shutdown
#
# Add the following lines to /etc/rc.conf to enable gitea:
#
#gitea_enable="YES"

. /etc/rc.subr

name="gitea"
rcvar="gitea_enable"

load_rc_config $name

: ${gitea_user:="git"}
: ${gitea_enable:="NO"}
: ${gitea_facility:="daemon"}
: ${gitea_priority:="debug"}
: ${gitea_shared:="/usr/local/share/${name}"}
: ${gitea_custom:="/usr/local/etc/${name}"}

command="/usr/local/sbin/${name} web"
procname="/usr/local/sbin/${name}"
githome="$(eval echo ~${gitea_user})"

pidfile="/var/run/${name}.pid"

start_cmd="${name}_start"

gitea_start() {
	for d in /var/db/gitea /var/log/gitea; do
		if [ ! -e "$d" ]; then
			mkdir "$d"
			chown ${gitea_user} "$d"
		fi
	done
	/usr/sbin/daemon -S -l ${gitea_facility} -s ${gitea_priority} -T ${name} \
		-u ${gitea_user} -p ${pidfile} \
		/usr/bin/env -i \
		"GITEA_WORK_DIR=${gitea_shared}" \
		"GITEA_CUSTOM=${gitea_custom}" \
		"HOME=${githome}" \
		"PATH=/usr/local/bin:${PATH}" \
		"USER=${gitea_user}" \
		$command
}

run_rc_command "$1"
