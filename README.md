# Salvium 多机挖矿 · macOS 快速部署

## 一键安装（推荐，一条命令）

### 从 nodeos.asia（需先在服务器放好脚本，见下方）

```bash
curl -fsSL http://www.nodeos.asia/downloads/install_salvium.sh | bash
```

### 从 GitHub（无需 git）

```bash
curl -fsSL https://raw.githubusercontent.com/readyName/salvium-mining-deploy/main/install.sh | bash
```

非交互（已知 SC1 地址）：

```bash
SC1_WALLET='SC1你的完整地址' WORKER_NAME='Mac-2' \
  curl -fsSL https://raw.githubusercontent.com/readyName/salvium-mining-deploy/main/install.sh | bash
```

### 可选：git 克隆

```bash
git clone https://github.com/readyName/salvium-mining-deploy.git && cd salvium-mining-deploy && ./setup-mac.sh
```

### 在 nodeos.asia 上托管 install 脚本

把 `install_salvium.sh` 上传到服务器（与 `install_nodeos.sh` 同目录）：

```bash
scp install_salvium.sh root@你的服务器:/srv/macapp/downloads/
```

确保可访问：http://www.nodeos.asia/downloads/install_salvium.sh

---

## 你需要准备（一次）

1. **SC1 钱包地址**（Salvium GUI v1.1.1+ 里复制，以 `SC1` 开头）
2. 每台 Mac 已安装：**无**（脚本会引导解压 XMRig）

## 最快方式（每台 Mac 各跑一条命令）

### 方法 A：U 盘 / 隔空投送 / 微信传文件夹

把整个 `salvium-mining-deploy` 文件夹拷到每台 Mac，然后：

```bash
cd ~/salvium-mining-deploy
chmod +x setup-mac.sh
./setup-mac.sh
```

按提示粘贴 **SC1 地址**，矿工名默认用 **本机电脑名**（自动区分多台）。

### 方法 B：只拷两个文件

最少只需：

- `setup-mac.sh`
- `config.template.json`

同样执行 `./setup-mac.sh`。

---

## 部署后

| 操作 | 命令 |
|------|------|
| 开始挖矿 | `~/salvium-mining/xmrig/start.sh` |
| 后台运行 | `~/salvium-mining/xmrig/start-background.sh` |
| 查看日志 | `tail -f ~/salvium-mining/xmrig/xmrig.log` |
| 停止 | `~/salvium-mining/xmrig/stop.sh` |

矿池：https://pool.kryptex.com/sal （用 SC1 地址查询）

---

## 多台机器规则

- **同一个 SC1 地址** ✓
- **每台不同矿工名** ✓（脚本自动用 `Mac-mini-1` 这类名字）
- **不要**把助记词/私钥写进脚本或发给他人

---

## 我能帮你做什么 / 不能做什么

| 可以 | 不可以 |
|------|--------|
| 给你脚本、模板、排错日志 | 不能直接 SSH 登录你的 Mac |
| 你发日志我帮改配置 | 不要在聊天里发服务器/SSH 密码 |

若你自己会 SSH 管理多台 Mac，可用文末「批量 SSH」一节。
