
## bash-redis

A bash util script for Redis.

### Status

UNSTABLE


### Implementation


### Installation

```shell
git clone https://github.com/evanx/bash-redis
```

### Usage

You can include this as follows:
```shell
set -u -e

loggerName=`basename $0 .sh`
loggerLevel=debug
redisCli="redis-cli -h localhost -n 0"

. ~/bash-redis/util.sh
```
where we set `redisCli` et al.

The util script also includes logging, for which we specify `loggerName` and `loggerLevel` e.g. `debug`


### Demo

```shell
loggerName=`basename $0 .sh`
loggerLevel=debug
redisCli="redis-cli -h localhost -n 0"

. ~/bash-redis/util.sh $0

debug $redisCli

debug 'testing debug'
info 'testing info'
warn 'testing warn'
error 'testing error'
abort 'testing abort'

help

# custom commands

c1llen() { # key
  echo "llen $1" `llen $1`
}

command $@
```
where we use `command` to handle command-line parameters.

The first parameter is the "command" e.g. `llen` with 1 parameter, will call `c1llen`

```shell
evans@eowyn:~/bash-redis$ bash scripts/demo.sh llen test:list
DEBUG redis-cli -h localhost -n 0
DEBUG redis llen test:list - 1
llen test:list 1
DEBUG testing logging debug
INFO  testing info
WARN  testing warn
ERROR testing error
ABORT testing abort
```
Actually in the terminal, we color and style the logging messages e.g. `ERROR` is bold red.

### Related

A deployment microservice: https://github.com/evanx/ndeploy-bash
