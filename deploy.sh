#!/bin/bash
# 智能部署：目录不存在则 clone，已存在则 pull，然后执行 setup-mac.sh
# DEPLOY_VERSION=2
set -euo pipefail

REPO_URL="${SALVIUM_REPO_URL:-https://github.com/readyName/salvium-mining-deploy.git}"
BRANCH="${SALVIUM_BRANCH:-main}"
INSTALL_ROOT="${HOME}/salvium-mining-deploy"

if [[ -d "${INSTALL_ROOT}/.git" ]]; then
  echo ">>> 更新已有仓库 ${INSTALL_ROOT}"
  git -C "${INSTALL_ROOT}" fetch origin "${BRANCH}" 2>/dev/null || true
  git -C "${INSTALL_ROOT}" pull --ff-only origin "${BRANCH}" 2>/dev/null || \
    git -C "${INSTALL_ROOT}" pull 2>/dev/null || true
elif [[ -d "${INSTALL_ROOT}" ]]; then
  BACKUP="${INSTALL_ROOT}.bak.$(date +%Y%m%d_%H%M%S)"
  echo ">>> ${INSTALL_ROOT} 已存在但不是 git 仓库（多为旧版 curl 只下了脚本）"
  echo ">>> 自动备份到: ${BACKUP}"
  mv "${INSTALL_ROOT}" "${BACKUP}"
  echo ">>> 重新克隆…"
  git clone --depth 1 -b "${BRANCH}" "${REPO_URL}" "${INSTALL_ROOT}"
else
  echo ">>> 克隆到 ${INSTALL_ROOT}"
  git clone --depth 1 -b "${BRANCH}" "${REPO_URL}" "${INSTALL_ROOT}"
fi

cd "${INSTALL_ROOT}"
chmod +x setup-mac.sh
exec ./setup-mac.sh
