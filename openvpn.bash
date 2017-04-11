#!/bin/bash
### BEGIN INIT INFO
# Provides:          openvpnas
# Required-Start:    $local_fs $remote_fs $network $syslog
# Required-Stop:     $local_fs $remote_fs $network $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start/stop openvpnas daemon
### END INIT INFO
# Get lsb functions
. /lib/lsb/init-functions
# pyovpn-generated init script for debian
# should be located in /etc/init.d/openvpnas
name="openvpnas"
target="/usr/local/openvpn_as/scripts/openvpnas"
pidfile="/var/run/openvpnas.pid"
sockfile="/usr/local/openvpn_as/etc/sock/sagent /usr/local/openvpn_as/etc/sock/sagent.localroot /usr/local/openvpn_as/etc/sock/sagent.api"
logfile="/var/log/openvpnas.log"
uid=""
gid=""
exit_timeout=90
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
pid=""
# remove daemon control socket
rm_sock()
{
    for sf in $sockfile ; do
        if [ -e "$sf" ]; then
        rm -f "$sf" &>/dev/null
        fi
    done
}
# remove pidfile
rm_pidfile()
{
    rm -f "$pidfile" &>/dev/null
}
# return a success status code if daemon has exited
daemon_exited()
{
    if [ -z "$pid" ]; then
    if [ -f "$pidfile" ]; then
        if ! [ -r "$pidfile" ]; then
        echo "pidfile $pidfile exists but we cannot read it"
        return 1
        fi
        pid="$(cat "$pidfile")"
    fi
    fi
    if [ -n "$pid" ] && [ -d "/proc/$pid" ]; then
        return 1 # process is still running
    else
    pid=""
    return 0 # process exited
    fi
}
# wait up to $exit_timeout seconds for daemon to exit
wait_exit()
{
    local count=0
    until [ $count -ge "$exit_timeout" ]; do
        if daemon_exited; then
        return 0
    else
        sleep 1
    fi
        let count=count+1
    done
    return 1
}
# start the daemon
do_start()
{
    if daemon_exited; then
        rm_sock
    rm_pidfile
        local u=""
        local g=""
        [ -n "$uid" ] && u="--uid=$uid"
        [ -n "$gid" ] && g="--gid=$gid"
        $target --logfile="$logfile" --pidfile="$pidfile" $u $g
    else
        return 0 # process is already running
    fi
}
# stop the daemon
do_stop()
{
    if ! daemon_exited; then
    if [ -n "$pid" ]; then
        kill "$pid" &>/dev/null
    else
        return 1
    fi
    wait_exit || return 1
    fi
    rm_sock
    rm_pidfile
    return 0
}
case $1 in
    start)
        log_daemon_msg "Starting openvpnas" "openvpnas"
        if do_start; then
        log_end_msg 0
        else
        log_end_msg 1
        fi
    ;;
    stop)
    log_daemon_msg "Stopping openvpnas" "openvpnas"
        if do_stop; then
        log_end_msg 0
        else
        log_end_msg 1
        fi
    ;;
    restart)
    log_daemon_msg "Restarting openvpnas" "openvpnas"
    if do_stop; then
            if do_start; then
            log_end_msg 0
            else
            log_end_msg 1
            fi
        else
        log_end_msg 1
        fi
    ;;
    *)
    echo "Usage: $name start|stop|restart"
        exit 1
    ;;
esac​