# OpenSearch-Dashboards(Kibana)

<https://github.com/opensearch-project/OpenSearch-Dashboards>

```bash
git remote add upstream git@github.com:opensearch-project/OpenSearch-Dashboards.git

git fetch upstream

git merge 1.3.11
```

## debug

```bash
# 安装依赖
# src/dev/build/tasks/patch_native_modules_task.ts
rm -rf ./build/node-re2 && \
mkdir -p ./build/node-re2 && \
curl -x socks5://www.ali.wodcloud.com:1283 -L https://github.com/uhop/node-re2/releases/download/1.15.4/linux-x64-64.gz > ./build/node-re2/linux-x64-64.gz && \
curl -x socks5://www.ali.wodcloud.com:1283 https://d1v1sj258etie.cloudfront.net/node-re2/releases/download/1.15.4/linux-arm64-64.tar.gz > ./build/node-re2/linux-arm64-64.tar.gz && \
mc cp --recursive ./build/node-re2/ cache/vscode/beagle/opensearch-dashboards/uhop/node-re2/1.15.4/

# src/dev/build/tasks/os_packages/docker_generator/templates/Dockerfile
# https://github.com/notofonts/noto-cjk/raw/NotoSansV2.001/NotoSansCJK-Regular.ttc
rm -rf ./build/googlefonts && \
mkdir -p ./build/googlefonts && \
curl -x socks5://www.ali.wodcloud.com:1283 https://raw.githubusercontent.com/notofonts/noto-cjk/NotoSansV2.001/NotoSansCJK-Regular.ttc > ./build/googlefonts/NotoSansCJK-Regular.ttc && \
mc cp --recursive ./build/googlefonts/ cache/vscode/beagle/opensearch-dashboards/googlefonts/noto-cjk/NotoSansV2.001/

# plugins/index-management-dashboards-plugin
git clone -b 1.3 git@github.com:opensearch-project/index-management-dashboards-plugin.git plugins/index-management-dashboards-plugin

docker run --rm \
-it \
-v $PWD/:/go/src/github.com/elastic/kibana \
-w /go/src/github.com/elastic/kibana/plugins/index-management-dashboards-plugin \
registry.cn-qingdao.aliyuncs.com/wod/devops-node:v10 \
yarn osd bootstrap --allow-root true

docker run --rm \
-it \
-v $PWD/:/go/src/github.com/elastic/kibana \
-w /go/src/github.com/elastic/kibana/plugins/index-management-dashboards-plugin \
registry.cn-qingdao.aliyuncs.com/wod/devops-node:v10 \
yarn build

mc cp --recursive ./plugins/index-management-dashboards-plugin/build/index-management-dashboards-1.3.1-1.0.zip cache/vscode/beagle/opensearch-dashboards/plugins/index-management-dashboards-1.3.1-1.0.zip

# 安装node_modules
docker run --rm \
-it \
-v $PWD/:/go/src/github.com/elastic/kibana \
-w /go/src/github.com/elastic/kibana \
registry.cn-qingdao.aliyuncs.com/wod/devops-node:v10 \
yarn osd bootstrap --allow-root true 

# 构建项目
docker run --rm \
-it \
-v $PWD/:/go/src/github.com/elastic/kibana \
-w /go/src/github.com/elastic/kibana \
-e YARN_CACHE_FOLDER=/go/src/github.com/elastic/kibana/.yarn-local-mirror/ \
-e BUILD_VERSION=1.3.11 \
registry.cn-qingdao.aliyuncs.com/wod/devops-node:v10 \
bash -c '
yarn build-platform --skip-os-packages --skip-archives --linux --linux-arm --release
'

# Edit local yml
config/opensearch_dashboards.yml

# Bootstrap OpenSearch Dashboards
# $PWD/.vscode/opensearch_dashboards.yml
export OPENSEARCH_DASHBOARDS_PATH_CONF=$PWD/.vscode/
yarn start

# i18n
node scripts/i18n_extract --output-dir ./translations --output-format json

node scripts/i18n_integrate --source ./translations/zh-CN.json

# clean
docker run --rm \
-it \
-v $PWD/:/go/src/github.com/elastic/kibana \
-w /go/src/github.com/elastic/kibana \
registry.cn-qingdao.aliyuncs.com/wod/devops-node:v10 \
yarn osd clean
```

## docker

```bash
# Docker:dumb-init
docker run -it --rm \
-v $PWD/:/go/src/github.com/elastic/kibana \
-w /go/src/github.com/elastic/kibana \
registry.cn-qingdao.aliyuncs.com/wod/dumb-init:v1.2.5-amd64 \
bash -c '
mkdir -p ./build/dumb-init
cp /bin/dumb-init ./build/dumb-init/dumb-init-linux-x64-v1.2.5
'

# Docker
export CI_COMMIT_SHA=$(git rev-parse --short HEAD)
docker build \
  --build-arg BASE=registry.cn-qingdao.aliyuncs.com/wod/debian:bookworm-slim-amd64 \
  --build-arg AUTHOR=mengkzhaoyun@gmail.com \
  --build-arg VERSION=v1.3.11 \
  --build-arg TARGETARCH=x64 \
  --build-arg TARGEVERSION=1.3.11 \
  --build-arg BUILD_DATE=$(date) \
  --build-arg BUILD_VERSION=$CI_COMMIT_SHA \
  --tag registry.cn-qingdao.aliyuncs.com/wod/opensearch-dashboards:v1.3.11-amd64 \
  --file ./.beagle/opensearch-dashboards/dockerfile .

docker push registry.cn-qingdao.aliyuncs.com/wod/opensearch-dashboards:v1.3.11-amd64
```

## cache

```bash
# 构建缓存-->推送缓存至服务器
docker run --rm \
  -e PLUGIN_REBUILD=true \
  -e PLUGIN_ENDPOINT=$PLUGIN_ENDPOINT \
  -e PLUGIN_ACCESS_KEY=$PLUGIN_ACCESS_KEY \
  -e PLUGIN_SECRET_KEY=$PLUGIN_SECRET_KEY \
  -e DRONE_REPO_OWNER="open-beagle" \
  -e DRONE_REPO_NAME="opensearch-dashboards" \
  -e PLUGIN_MOUNT="./.git,./.yarn-local-mirror,./node_modules,./packages/*/node_modules,./test/plugin_functional/plugins/*/node_modules,./test/interpreter_functional/plugins/*/node_modules" \
  -v $(pwd):$(pwd) \
  -w $(pwd) \
  registry.cn-qingdao.aliyuncs.com/wod/devops-s3-cache:1.0

# 读取缓存-->将缓存从服务器拉取到本地
docker run --rm \
  -e PLUGIN_RESTORE=true \
  -e PLUGIN_ENDPOINT=$PLUGIN_ENDPOINT \
  -e PLUGIN_ACCESS_KEY=$PLUGIN_ACCESS_KEY \
  -e PLUGIN_SECRET_KEY=$PLUGIN_SECRET_KEY \
  -e DRONE_REPO_OWNER="open-beagle" \
  -e DRONE_REPO_NAME="opensearch-dashboards" \
  -v $(pwd):$(pwd) \
  -w $(pwd) \
  registry.cn-qingdao.aliyuncs.com/wod/devops-s3-cache:1.0
```

## patch

```bash
git format-patch -1 <r1>

git apply .beagle/v1.3-i18n-zh-CN.patch
```
