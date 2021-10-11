#!/bin/bash

# This script require Go Lang installed in order to works.
if ! command -v go version &>/dev/null; then
  echo "Please install Go to run this script. https://golang.org/doc/install"
  exit
fi

echo "Installing Bombardier..." # https://github.com/codesenberg/bombardier
go install github.com/codesenberg/bombardier@latest

for i in "${@:3}"
do
    bombardier -c $1 -n $2 "$i"
done
