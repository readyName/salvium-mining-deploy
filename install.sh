#!/bin/bash
# 一键安装：从 GitHub 拉取并部署 Salvium 挖矿 (macOS)
set -euo pipefail

REPO="${SALVIUM_DEPLOY_REPO:-YOUR_GITHUB_USER/salvium-mining-deploy}"
BRANCH="${SALVIUM_DEPLOY_BRANCH:-main}"
INSTALL_ROOT="${HOME}/salvium-mining-deploy"

echo "=== Salvium 挖矿 · 一键安装 ==="
echo "仓库: https://github.com/${REPO}"
echo ""

if command -v git >/dev/null 2>&1; then
  if [[ -d "${INSTALL_ROOT}/.git" ]]; then
    echo "更新已有目录 ${INSTALL_ROOT} ..."
    git -C "$INSTALL_ROOT" pull --ff-only origin "$BRANCH" 2>/dev/null || true
  else
    rm -rf "$INSTALL_ROOT"
    git clone --depth 1 -b "$BRANCH" "https://github.com/${REPO}.git" "$INSTALL_ROOT"
  fi
else
  echo "未安装 git，请先: xcode-select --install"
  exit 1
fi

chmod +x "${INSTALL_ROOT}/setup-mac.sh"
exec "${INSTALL_ROOT}/setup-mac.sh"
