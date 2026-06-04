#!/bin/bash
# 一键安装：curl | bash 或 bash install.sh（无需 git）
set -euo pipefail

REPO="${SALVIUM_DEPLOY_REPO:-readyName/salvium-mining-deploy}"
BRANCH="${SALVIUM_DEPLOY_BRANCH:-main}"
RAW_BASE="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
INSTALL_ROOT="${HOME}/salvium-mining-deploy"

echo "=== Salvium 挖矿 · 一键安装 ==="
echo "源: ${RAW_BASE}"
echo ""

mkdir -p "${INSTALL_ROOT}"

echo "下载部署脚本…"
curl -fsSL "${RAW_BASE}/setup-mac.sh" -o "${INSTALL_ROOT}/setup-mac.sh"
curl -fsSL "${RAW_BASE}/config.template.json" -o "${INSTALL_ROOT}/config.template.json"

chmod +x "${INSTALL_ROOT}/setup-mac.sh"
cd "${INSTALL_ROOT}"
# curl | bash 时让 setup-mac.sh 从终端读入（修复 read 被跳过）
if [[ -e /dev/tty ]]; then
  exec ./setup-mac.sh </dev/tty
else
  exec ./setup-mac.sh
fi
