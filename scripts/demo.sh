#!/bin/bash

set -u -e

# env context

ns=${ns:=demo\:ndeploy}
redisCli=${redisCli:=redis-cli -n 13}


# client init

loggerName=`basename $0 .sh`
loggerLevel=debug
redisCli="redis-cli -h localhost -n 0"

. ~/bash-redis/util.sh $0

debug $redisCli

c1llen() { # key
  echo "llen $1" `llen $1`
}

debug 'testing logging debug'
info 'testing info'
warn 'testing warn'
error 'testing error'

command "$@" || help 

abort 'testing abort'
