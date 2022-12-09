
MPID="$1"
ret=0
TUNNEL_DEBUG=""
#---

if [ -n "$TUNNEL_DEBUG" ] ; then
  exec 2>/tmp/t1; set -x; env >&2
fi

which jq &> /dev/null || echo "You must install jq" >&2

# Parent process: This parses arguments and runs the tunnel inside a timeout block

if [ -z "$MPID" ] ; then
  # parse arguments
  query="`dd 2>/dev/null`"
  echo "query: <$query>" >&2

  eval $(echo $query | jq -r '@sh "
export TIMEOUT=\(.timeout)
export KUBECTL_CMD=\(.kubectl_cmd)
export RESOURCE=\(.resource)
export LOCAL_PORT=\(.local_port)
export TARGET_PORT=\(.target_port)
export SHELL_CMD=\(.shell_cmd)
export TUNNEL_CHECK_SLEEP=\(.tunnel_check_sleep)"')

echo ".timeout" $TIMEOUT >&2
echo ".kubectl_cmd" $KUBECTL_CMD >&2
echo ".resource" $RESOURCE >&2
echo ".local_port" $LOCAL_PORT >&2
echo ".target_port" $TARGET_PORT >&2
echo ".shell_cmd" $SHELL_CMD >&2
echo ".tunnel_check_sleep" $TUNNEL_CHECK_SLEEP >&2

  # Send result to output
  # TODO: get local port from kubectl port-forward output
  jq -n --arg LOCAL_PORT "$LOCAL_PORT" '{"port":$LOCAL_PORT}'

  # run port forward with timeout
  p=`ps -p $PPID -o "ppid="`
  clog=`mktemp`
  nohup timeout $TIMEOUT $SHELL_CMD \
      "$(cd "$(dirname "$0")"; pwd -P)/tunnel.sh" $p \
      <&- >&- 2>$clog &
  CPID=$!
  # A little time for the SSH tunnel process to start or fail
  sleep 3
  # If the child process does not exist anymore after this delay, report failure
  if ! ps -p $CPID >/dev/null 2>&1 ; then
    echo "Child process ($CPID) failure - Aborting" >&2
    echo "Child diagnostics:" >&2
    cat $clog >&2
    ret=1
  fi
  rm -f $clog
else  #------ Child
  $KUBECTL_CMD port-forward $RESOURCE $LOCAL_PORT:$TARGET_PORT &
  CPID=$!
  
  sleep $TUNNEL_CHECK_SLEEP

  while true ; do
    # check if port-forward is still running
    if ! ps -p $CPID >/dev/null 2>&1 ; then
      echo "kubectl port-forward process ($CPID) failure - Aborting" >&2
      exit 1
    fi
    # check if parent is still running
    ps -p $MPID >/dev/null 2>&1 || break
    sleep 1
  done

  kill $CPID
fi

exit $ret
