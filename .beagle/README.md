# OpenSearch-Dashboards(Kibana)

<https://github.com/opensearch-project/OpenSearch-Dashboards>

```bash
git remote add upstream git@github.com:opensearch-project/OpenSearch-Dashboards.git

git fetch upstream

// 1.3.9 2022.08.26
git merge upstream/1.3
```

## debug

```bash
# 安装plugins
git clone -b 1.3 git@github.com:opensearch-project/index-management-dashboards-plugin.git plugins/index-management-dashboards-plugin
export CYPRESS_INSTALL_BINARY=https://cache.wodcloud.com/vscode/node/cypress/cypress_6.8.0_linux_x64.zip

# 准备node
export NODE_VERSION=v10.24.1
bash /go/src/gitlab.wodcloud.com/shucheng/wsl/src/node.sh
node --version

# 安装所有依赖node_modules
yarn osd bootstrap --allow-root

# opensearch-dashboards-build
docker build \
  --build-arg BASE=registry.cn-qingdao.aliyuncs.com/wod/debian:bookworm \
  --build-arg AUTHOR=mengkzhaoyun@gmail.com \
  --build-arg VERSION=v1.x \
  --tag registry.cn-qingdao.aliyuncs.com/wod-arm/opensearch-dashboards-build:v1.x \
  --file .beagle/opensearch-dashboards-build/dockerfile .

docker push registry.cn-qingdao.aliyuncs.com/wod-arm/opensearch-dashboards-build:v1.x

# Bootstrap OpenSearch Dashboards
docker run --rm \
-it \
-v $PWD/:/go/src/github.com/elastic/kibana \
-w /go/src/github.com/elastic/kibana \
registry.cn-qingdao.aliyuncs.com/wod-arm/opensearch-dashboards-build:v1.x \
bash -c "
yarn osd bootstrap --allow-root
"

# Build
docker run --rm \
-it \
-v $PWD/:/go/src/github.com/elastic/kibana \
-w /go/src/github.com/elastic/kibana \
-e YARN_CACHE_FOLDER=/go/src/github.com/elastic/kibana/.yarn-local-mirror/ \
-e BUILD_VERSION=1.3.5 \
registry.cn-qingdao.aliyuncs.com/wod-arm/opensearch-dashboards-build:v1.x \
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
  --build-arg VERSION=v1.4.0 \
  --build-arg TARGETARCH=x64 \
  --build-arg TARGEVERSION=1.3.5 \
  --build-arg BUILD_DATE=$(date) \
  --build-arg BUILD_VERSION=$CI_COMMIT_SHA \
  --tag registry.cn-qingdao.aliyuncs.com/wod/opensearch-dashboards:v1.4.0-amd64 \
  --file ./.beagle/opensearch-dashboards/dockerfile .

docker push registry.cn-qingdao.aliyuncs.com/wod/opensearch-dashboards:v1.4.0-amd64
```

## cache

```bash
# 构建缓存-->推送缓存至服务器
docker run --rm \
  -e PLUGIN_REBUILD=true \
  -e PLUGIN_ENDPOINT=$PLUGIN_ENDPOINT \
  -e PLUGIN_ACCESS_KEY=$PLUGIN_ACCESS_KEY \
  -e PLUGIN_SECRET_KEY=$PLUGIN_SECRET_KEY \
  -e DRONE_REPO_OWNER="cloud" \
  -e DRONE_REPO_NAME="opensearch-dashboards" \
  -e DRONE_COMMIT_BRANCH="dev" \
  -e PLUGIN_MOUNT="./.yarn-local-mirror,./node_modules,./packages/*/node_modules,./test/plugin_functional/plugins/*/node_modules,./test/interpreter_functional/plugins/*/node_modules" \
  -v $(pwd):$(pwd) \
  -w $(pwd) \
  registry.cn-qingdao.aliyuncs.com/wod/devops-s3-cache:1.0

# 读取缓存-->将缓存从服务器拉取到本地
docker run --rm \
  -e PLUGIN_RESTORE=true \
  -e PLUGIN_ENDPOINT=$PLUGIN_ENDPOINT \
  -e PLUGIN_ACCESS_KEY=$PLUGIN_ACCESS_KEY \
  -e PLUGIN_SECRET_KEY=$PLUGIN_SECRET_KEY \
  -e DRONE_REPO_OWNER="cloud" \
  -e DRONE_REPO_NAME="opensearch-dashboards" \
  -e DRONE_COMMIT_BRANCH="dev" \
  -v $(pwd):$(pwd) \
  -w $(pwd) \
  registry.cn-qingdao.aliyuncs.com/wod/devops-s3-cache:1.0
```

## patch

```bash
git format-patch -1 <r1>

git apply .beagle/v1.3-i18n-zh-CN.patch
```
