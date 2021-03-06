
## bash-redis

A bash util script for Redis. It also includes logging.

### Status

UNSTABLE


### Implementation

See: https://github.com/evanx/bash-redis/blob/master/util.sh


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

Note that to use this util, we <b>must</b> `set -e` i.e. error on exit, i.e. any command that returns nonzero, that is not checked using an `if` statement.


### Demo

See: https://github.com/evanx/bash-redis/blob/master/demo.sh


```shell
# context

loggerName=`basename $0 .sh`
loggerLevel=debug
redisCli="redis-cli -h localhost -n 0"

. ~/bash-redis/util.sh $0

debug redisCli $redisCli

# testing

debug 'testing debug'
info 'testing info'
warn 'testing warn'
error 'testing error'

help

# custom commands

c1llen() { # key
  echo "llen $1" `llen $1`
}


# call custom command

command $@ || help

abort 'testing abort'
```
where we use `command` to handle command-line parameters.

The first parameter is the "command" e.g. `llen` with 1 parameter, will call `c1llen`

<img src='http://evanx.github.io/images/bash-redis/bash-redis.png' alt='script output'>

Notice that we colorify logging messages e.g. `ERROR` is red.

Note that we <b>must</b> execute the script with `bash` rather than `sh.`


### Related

A deployment microservice: https://github.com/evanx/ndeploy-bash
