#!/bin/sh
# Start a Catalyst app under FastCGI
#
### BEGIN INIT INFO
# Provides: webapp
# Required-Start: $local_fs $network $named
# Required-Stop: $local_fs $network $named
# Should-Start: apache2
# Should-Stop: apache2
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: A Catalyst Application
### END INIT INFO

. /lib/lsb/init-functions

APPNAME=YourNextMP
APPDIR=/var/www/yournextmp_stage
UNIXNAME=$(echo $APPNAME | perl -pe 's/::/_/g;$_=lc')
PROCS=1
SOCKET=127.0.0.1:55901
# Leave these unset and we won't try to setuid/setgid.
USER=www-data
GROUP=www-data
# Set this if you have more than one instance of the app and you don't want
# them to step on each other's pidfile.
PIDSUFFIX=stage

if [ -f "/etc/default/"$UNIXNAME ]; then
. "/etc/default/"$UNIXNAME
fi

if [ $(id -u) -eq 0 ] ; then
  PIDDIR=/var/run/$UNIXNAME
  mkdir $PIDDIR >/dev/null 2>&1
  chown $USER:$GROUP $PIDDIR
  chmod 775 $PIDDIR
else
  PIDDIR=/tmp
fi

PIDFILE=$PIDDIR/$UNIXNAME${PIDSUFFIX:+"-$PIDSUFFIX"}.pid

check_running() {
    [ -s $PIDFILE ] && kill -0 $(cat $PIDFILE) >/dev/null 2>&1
}

check_compile() {
  if [ -n "$USER" ] ; then
    if su $USER -c "cd $APPDIR ; perl -Ilib -M$APPNAME -ce1" ; then
        return 1
    fi
    return 0
  else
    if ( cd $APPDIR ; perl -Ilib -M$APPNAME -ce1 ) ; then
      return 1
    fi
    return 0
  fi
}

_start() {
  start-stop-daemon --start --quiet --pidfile $PIDFILE --chdir $APPDIR \
    ${USER:+"--chuid"} $USER ${GROUP:+"--group"} $GROUP --background \
    --startas $APPDIR/script/${UNIXNAME}_fastcgi.pl -- -n $PROCS -l $SOCKET -p $PIDFILE

  for i in 1 2 3 4 5 ; do
    sleep 1
    if check_running ; then
      return 0
    fi
  done
  return 1
}

start() {
    log_daemon_msg "Starting $APPNAME" $UNIXNAME
    if check_running; then
        log_progress_msg "already running"
        log_end_msg 0
        exit 0
    fi

    rm -f $PIDFILE 2>/dev/null

    _start
    log_end_msg $?
    return $?
}

stop() {
    log_daemon_msg "Stopping $APPNAME" $UNIXNAME

    start-stop-daemon --stop --user $USER --quiet --oknodo --pidfile $PIDFILE
    log_end_msg $?
    return $?
}

restart() {
    log_daemon_msg "Restarting $APPNAME" $UNIXNAME
    if check_compile ; then
        log_failure_msg "Error detected; not restarting."
        log_end_msg 1
        exit 1
    fi

    start-stop-daemon --stop --quiet --oknodo --pidfile $PIDFILE
    _start
    log_end_msg $?
    return $?
}

# See how we were called.
case "$1" in
    start)
        start
    ;;
    stop)
        stop
    ;;
    restart|force-reload)
        restart
    ;;
    *)
        echo $"Usage: $0 {start|stop|restart}"
        exit 1
esac
exit $?
