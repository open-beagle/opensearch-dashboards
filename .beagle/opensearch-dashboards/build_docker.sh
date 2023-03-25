#!/usr/bin/env bash
#
# ** THIS IS AN AUTO-GENERATED FILE **
#
set -euo pipefail

retry_docker_pull() {
  image=$1
  attempt=0
  max_retries=5

  while true
  do
    attempt=$((attempt+1))

    if [ $attempt -gt $max_retries ]
    then
      echo "Docker pull retries exceeded, aborting."
      exit 1
    fi

    if docker pull "$image"
    then
      echo "Docker pull successful."
      break
    else
      echo "Docker pull unsuccessful, attempt '$attempt'."
    fi

  done
}

retry_docker_pull centos:8

echo "Building: opensearch-dashboards-docker"; docker build -t docker.opensearch.org/opensearch-dashboards/opensearch-dashboards:1.2.0-SNAPSHOT -f Dockerfile . || exit 1;

docker save docker.opensearch.org/opensearch-dashboards/opensearch-dashboards:1.2.0-SNAPSHOT | gzip -c > /go/src/gitlab.wodcloud.com/cloud/opensearch-dashboards/target/opensearch-dashboards-1.2.0-SNAPSHOT-docker-image.tar.gz

exit 0