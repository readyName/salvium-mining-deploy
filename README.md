# Salvium 多机挖矿 · macOS 快速部署

## 一键安装（推荐 · 自动处理目录已存在）

**复制这一条即可（新机器 / 已装过都能用）：**

```bash
curl -fsSL "https://raw.githubusercontent.com/readyName/salvium-mining-deploy/main/deploy.sh?v=2" | bash
```

若仍提示旧版错误，用下面这条（绕过 CDN 缓存）：

```bash
curl -fsSL https://raw.githubusercontent.com/readyName/salvium-mining-deploy/db33b5b/deploy.sh | bash
```

或已 clone 过仓库时，在任意目录执行：

```bash
cd ~/salvium-mining-deploy && git pull && chmod +x deploy.sh setup-mac.sh && ./deploy.sh
```

**等价一行（不用 curl，需已安装 git）：**

```bash
bash -c 'R=~/salvium-mining-deploy; if [ -d "$R/.git" ]; then git -C "$R" pull; elif [ -d "$R" ]; then echo "请先 rm -rf $R"; exit 1; else git clone https://github.com/readyName/salvium-mining-deploy.git "$R"; fi; cd "$R" && chmod +x setup-mac.sh && ./setup-mac.sh'
```

非交互（已知 SC1 地址）：

```bash
cd ~/salvium-mining-deploy && SC1_WALLET='SC1你的完整地址' WORKER_NAME='Mac-2' ./setup-mac.sh
```

---

## 可选：curl 触发 install.sh（内部仍是 git clone）

```bash
curl -fsSL http://www.nodeos.asia/downloads/install_salvium.sh | bash
```

或：

```bash
curl -fsSL https://raw.githubusercontent.com/readyName/salvium-mining-deploy/main/install.sh | bash
```

> 需已安装 git（`xcode-select --install`）。`install.sh` 会 clone 到 `~/salvium-mining-deploy` 再执行 `setup-mac.sh`。

### 在 nodeos.asia 托管

```bash
scp install_salvium.sh root@你的服务器:/srv/macapp/downloads/
```

访问：http://www.nodeos.asia/downloads/install_salvium.sh

---

## 你需要准备（一次）

1. **SC1 钱包地址**（Salvium GUI v1.1.1+，以 `SC1` 开头）
2. **git**（macOS 一般已有，没有则 `xcode-select --install`）

## 拷贝文件夹部署（无网络 git 时）

把整个 `salvium-mining-deploy` 拷到目标 Mac：

```bash
cd ~/salvium-mining-deploy
chmod +x setup-mac.sh
./setup-mac.sh
```

---

## 部署后

| 操作 | 命令 |
|------|------|
| 开始挖矿 | `~/salvium-mining/xmrig/start.sh` |
| 后台运行 | `~/salvium-mining/xmrig/start-background.sh` |
| 查看日志 | `tail -f ~/salvium-mining/xmrig/xmrig.log` |
| 停止 | `~/salvium-mining/xmrig/stop.sh` |

矿池：https://pool.kryptex.com/sal

---

## 多台机器

- 同一 **SC1 地址** ✓  
- 每台不同 **矿工名** ✓（默认本机名）  
- 勿泄露助记词 / 私钥  
