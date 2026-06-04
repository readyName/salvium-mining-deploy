#!/bin/bash
# 智能部署：目录不存在则 clone，已存在则 pull，然后执行 setup-mac.sh
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
  echo "错误: ${INSTALL_ROOT} 已存在但不是 git 仓库。"
  echo "解决: rm -rf ${INSTALL_ROOT}  后重新运行本脚本"
  exit 1
else
  echo ">>> 克隆到 ${INSTALL_ROOT}"
  git clone --depth 1 -b "${BRANCH}" "${REPO_URL}" "${INSTALL_ROOT}"
fi

cd "${INSTALL_ROOT}"
chmod +x setup-mac.sh
exec ./setup-mac.sh
