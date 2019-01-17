#!/usr/bin/env bash

[ -z "$BATTLE_PORT"] && BATTLE_PORT=8080

STATS_DIR=stats
PIDFILE=server.pid
PERFLOG_NAME=activity.txt
PLOTFILE_NAME=stats.png

NODE_DIR=node-server
GO_DIR=go-server

mkdir -p $STATS_DIR
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT


function record_stats() {
  pid=$1

  sleep 1
  echo -n $pid > $PIDFILE
  echo "Start recording CPU and memory stats... "
  psrecord $pid --log $STATS_DIR/$PERFLOG_NAME --plot $STATS_DIR/$PLOTFILE_NAME
}


export BATTLE_PORT
case "$1" in
  node)
    node $NODE_DIR/app.js &
    record_stats $!
    ;;
  go)
    cd $GO_DIR && go build; cd -
    ./$GO_DIR/go-server &
    record_stats $!
    ;;
  *)
    echo "Don't know what \"$1\" means"
    exit 1
    ;;
esac

# node app.js &
# pid=$!
# watch -n1 "ps mwMw -o rss ${pid}"
