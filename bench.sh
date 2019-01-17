#!/usr/bin/env bash

STATS_DIR=stats/wrk2
BENCH_DURATION=30s

#wrk-report > $STATS_DIR/report.html

mkdir -p $STATS_DIR

TITLE=$2
case "$1" in
    now)
        wrk2 "${@:3}" -d${BENCH_DURATION} -L http://localhost:8080/now | tee $STATS_DIR/$TITLE.out
        ;;
    now-5ms-delay)
        wrk2 "${@:3}" -d${BENCH_DURATION} -L http://localhost:8080/now-5ms-delay | tee $STATS_DIR/$TITLE.out
        ;;
    *)
        echo "Unknown command: $1"
        exit 1
        ;;
esac

#[ -e "server.pid" ] && kill -TERM `cat server.pid`
