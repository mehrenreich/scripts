#!/usr/bin/env bash

if [[ $# != 2 ]] ; then
  echo "Usage: ${0} SWITCH_IP_ADDRESS PORT_NUM [SSH_PASS]"
  exit 1
fi

SWITCH_IP_ADDRESS=$1
PORT_NUM=$2
SSH_PASS=$3

function remote_exec() {
  command=$1
  echo $command
  ssh ubnt@$SWITCH_IP_ADDRESS $command
}

if [[ -n $SSH_PASS ]] ; then
  sshpass -p $SSH_PASS ssh ubnt@$SWITCH_IP_ADDRESS '(echo "enable" ; echo "configure" ; echo "interface 0/'$PORT_NUM'" ; echo "poe opmode shutdown" ; echo "exit" ; echo "exit" ; echo "exit") | telnet localhost ; exit;'
else
  remote_exec '(echo "enable" ; echo "configure" ; echo "interface 0/'$PORT_NUM'" ; echo "poe opmode shutdown" ; echo "exit" ; echo "exit" ; echo "exit") | telnet localhost ; exit;'
  remote_exec '(echo "enable" ; echo "configure" ; echo "show poe port 0/'$PORT_NUM'"; echo "exit" ; echo "exit") | telnet localhost; exit;'
fi
