#!/bin/sh

set -e

USER=$1
EMAIL=$2

if [ -n "$USER" ]
then
  git config --global user.name "$USER"
fi

if [ -n "$EMAIL" ]
then
  git config --global user.email "$EMAIL"
fi
