#!/bin/bash

fio "$@" --output-format=json --output out.json &> /tmp/error.log

if [ $? -ne 0 ] ; then
  cat /tmp/error.log
  exit 1
fi

sed -i '/Additional Terse Output.*/,//d' out.json

if [ -d /results/ ]; then
  mv out.json /results/
else
  cat out.json
fi
