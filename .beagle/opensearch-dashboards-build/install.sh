#!/bin/bash

set -ex

HTTP_SERVER="${HTTP_SERVER:-https://cache.wodcloud.com}"

# node
NODE_VERSION="${NODE_VERSION:-v10.24.1}"
if ! [[ -e /usr/local/lib/node-$NODE_VERSION/README.md ]]; then
  curl $HTTP_SERVER/vscode/node-$NODE_VERSION-linux-x64.tar.gz > /tmp/node-$NODE_VERSION-linux-x64.tar.gz
  cd /tmp
  tar -xzvf node-$NODE_VERSION-linux-x64.tar.gz
  mv /tmp/node-$NODE_VERSION-linux-x64 /usr/local/lib/node-$NODE_VERSION
  rm -rf /tmp/node-$NODE_VERSION-linux-x64 /tmp/node-$NODE_VERSION-linux-x64.tar.gz
fi

# yarn
YARN_VERSION="${YARN_VERSION:-v1.22.10}"
if ! [[ -e /usr/local/lib/yarn-$YARN_VERSION/README.md ]]; then
  curl $HTTP_SERVER/vscode/yarn-$YARN_VERSION.tar.gz > /tmp/yarn-$YARN_VERSION.tar.gz
  cd /tmp
  tar -xzvf yarn-$YARN_VERSION.tar.gz
  mv /tmp/yarn-$YARN_VERSION /usr/local/lib/yarn-$YARN_VERSION
  rm -rf /tmp/yarn-$YARN_VERSION /tmp/yarn-$YARN_VERSION.tar.gz
fi
