#!/bin/bash
# nodeos.asia/downloads/ 托管版，逻辑与 install.sh 相同
set -euo pipefail

REPO="${SALVIUM_DEPLOY_REPO:-readyName/salvium-mining-deploy}"
BRANCH="${SALVIUM_DEPLOY_BRANCH:-main}"
INSTALL_ROOT="${HOME}/salvium-mining-deploy"
REPO_URL="https://github.com/${REPO}.git"

echo "=== Salvium 挖矿 · 一键安装 (nodeos) ==="
echo "仓库: ${REPO_URL}"
echo ""

if ! command -v git >/dev/null 2>&1; then
  echo "未安装 git，请先执行: xcode-select --install"
  exit 1
fi

if [[ -d "${INSTALL_ROOT}/.git" ]]; then
  echo "更新已有目录 ${INSTALL_ROOT} …"
  git -C "${INSTALL_ROOT}" fetch origin "${BRANCH}" 2>/dev/null || true
  git -C "${INSTALL_ROOT}" reset --hard "origin/${BRANCH}" 2>/dev/null || \
    git -C "${INSTALL_ROOT}" pull --ff-only origin "${BRANCH}" 2>/dev/null || true
elif [[ -d "${INSTALL_ROOT}" ]]; then
  BACKUP="${INSTALL_ROOT}.bak.$(date +%Y%m%d_%H%M%S)"
  echo ">>> ${INSTALL_ROOT} 已存在但不是 git 仓库，自动备份到 ${BACKUP} 并重新克隆…"
  mv "${INSTALL_ROOT}" "${BACKUP}"
  git clone --depth 1 -b "${BRANCH}" "${REPO_URL}" "${INSTALL_ROOT}"
else
  git clone --depth 1 -b "${BRANCH}" "${REPO_URL}" "${INSTALL_ROOT}"
fi

chmod +x "${INSTALL_ROOT}/setup-mac.sh"
cd "${INSTALL_ROOT}"
exec ./setup-mac.sh
