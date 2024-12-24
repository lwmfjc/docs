#!/bin/bash

trap killgroup SIGINT

killgroup(){
  echo killing...
  kill 0
}

loop(){
  echo $1
  sleep $1
  loop $1
}

loop 1 &
loop 2 &
wait