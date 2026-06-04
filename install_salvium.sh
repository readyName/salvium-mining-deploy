#!/bin/bash
# 托管在 nodeos.asia/downloads/ 时使用；内容与 install.sh 相同
set -euo pipefail

REPO="${SALVIUM_DEPLOY_REPO:-readyName/salvium-mining-deploy}"
BRANCH="${SALVIUM_DEPLOY_BRANCH:-main}"
RAW_BASE="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
INSTALL_ROOT="${HOME}/salvium-mining-deploy"

echo "=== Salvium 挖矿 · 一键安装 (nodeos) ==="
echo "源: ${RAW_BASE}"
echo ""

mkdir -p "${INSTALL_ROOT}"

curl -fsSL "${RAW_BASE}/setup-mac.sh" -o "${INSTALL_ROOT}/setup-mac.sh"
curl -fsSL "${RAW_BASE}/config.template.json" -o "${INSTALL_ROOT}/config.template.json"

chmod +x "${INSTALL_ROOT}/setup-mac.sh"
cd "${INSTALL_ROOT}"
if [[ -e /dev/tty ]]; then
  exec ./setup-mac.sh </dev/tty
else
  exec ./setup-mac.sh
fi
