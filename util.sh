
if [ $# -eq 1 ]
then
   if dirname $1 | grep -q '^/'
   then
      scriptFile=$1
   else
      scriptFile=$PWD$1
   fi
fi

# logging

## styles
stBold="\e[1m"
stReset="\e[0m"

## colors
cfDefault="\e[39m"
cfRed="\e[31m"
cfGreen="\e[32m"
cfYellow="\e[33m"
cfLightGray="\e[37m"
cfDarkGray="\e[90m"
cfLightBlue="\e[94m"

debug() {
   if [ -n "$loggerLevel" -a "$loggerLevel" = 'debug' ]
   then
      if [ -t 1 ]
      then
         >&2 echo -e "${cfLightBlue}DEBUG $*${cfDefault}"
      else
         >&2 echo "DEBUG $*"
      fi
   fi
}

rdebug() {
   if [ -n "$loggerLevel" -a "$loggerLevel" = 'debug' ]
   then
     >&2 echo -e "${cfDarkGray}DEBUG redis $*${cfDefault}"
   fi
}

info() {
   if [ -t 1 ]
   then
      >&2 echo -e "${cfGreen}INFO  $*${cfDefault}"
   else
      >&2 echo "INFO $*"
   fi
}

warn() {
   if [ -t 1 ]
   then
      >&2 echo -e "${cfYellow}${stBold}WARN  $*${stReset}"
   else
      >&2 echo "WARN $*"
   fi
}

error() {
   if [ -t 1 ]
   then
      >&2 echo -e "${cfRed}${stBold}ERROR $*${stReset}"
   else
      >&2 echo "ERROR $*"
   fi
}


# exit

abort() {
   if [ -t 1 ]
   then
      echo -e "${cfRed}${stBold}ABORT $*${stReset}"
   else
      echo "ABORT $*"
   fi
   exit 1
}


# grep utils

grepq() {
   [ $# -eq 1 ]
   grep -q "^${1}$"
}


# redis utils

validateKey() {
   true
}

redis() {
   $redisCli $*
}

redise() {
   expect=$1
   shift
   redisCommand="$@"
   reply=`$redisCli $redisCommand`
   if [ "$reply" != $expect ]
   then
      warn "$redisCommand - reply $reply - not $expect"
      return 2
   else
      return 0
   fi
}

redis0() {
   [ $# -gt 1 ]
   redise 0 $*
}

redis1() {
   [ $# -gt 1 ]
   redise 1 $*
}

# redis commands

expire() {
   info "expire $*"
   [ $# -eq 2 ]
   redis1 expire $*
}

exists() {
   [ $# -eq 1 ]
   redis1 exists $1
}

incr() {
   [ $# -eq 1 ]
   key=$1
   validateKey "$key"
   seq=`$redisCli incr $key`
   echo "$seq" | grep '^[1-9][0-9]*$'
}

## hashes

hgetall() {
   [ $# -eq 1 ]
   key=$1
   validateKey "$key"
   rdebug "hgetall $key"
   $redisCli hgetall $key
}

hsetnx() {
   [ $# -eq 3 ]
   $redisCli hsetnx $* | grep -q '^1$'
}

hincrby() {
   [ $# -eq 3 ]
   reply=`$redisCli hincrby $*`
   rdebug "hincrby $* - $reply"
   echo $reply | grep '^[1-9][0-9]*$'
}


## lists

lpush() {
   [ $# -eq 2 ]
   reply=`$redisCli lpush $*`
   rdebug "lpush $* - $reply"
   echo "$reply" | grep -q '^[1-9][0-9]*$'
}

brpoplpush() {
   [ $# -eq 3 ]
   popId=`$redisCli brpoplpush $*`
   rdebug "brpoplpush $* - $popId"
   echo $popId | grep '^[1-9][0-9]*$'
}

brpop() {
   [ $# -eq 2 ]
   debug "$redisCli brpop $*"
   popId=`$redisCli brpop $* | tail -1`
   rdebug "brpop $* - $popId"
   echo $popId | grep '^[1-9][0-9]*$'
}

lrem() {
   [ $# -eq 3 ]
   $redisCli lrem $* | grep -q '^[1-9][0-9]*$'
}

llen() {
   [ $# -eq 1 ]
   llen=`$redisCli llen $*`
   rdebug "llen $* - $llen"
   echo $llen | grep '^[1-9][0-9]*$'
}

## sets

sadd() {
   [ $# -eq 2 ]
   $redisCli sadd $* | grep -q '^[1-9][0-9]*$'
}


## custom redis commands

nexists() {
   [ $# -eq 1 ]
   redis0 exists $1
}

hgetd() {
   [ $# -eq 3 ]
   defaultValue=$1
   key=$2
   field=$3
   value=`$redisCli hget $key $field`
   if [ -z "$value" ]
   then
      echo "$defaultValue"
   else
      echo $value
   fi
}


# commands

help() {
   if [ -n "$scriptFile" ]
   then
      cat $scriptFile | grep ^c[0-9] | sed 's/^c\([0-9]\)\(\w*\)() {\s*[\W#]*\s*\(.*\)$/\2 \1 \3/' | sort
   else
      warn "no command"
   fi
}

command() {
   if [ $# -ge 1 ]
   then
      command=$1
      shift
      c$#$command $@
   else
      help
   fi
}
