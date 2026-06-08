# debian-arm64-cortex-a76

離線用的 **ARM Cortex-A76 (ARMv8.2-A / AArch64)** Docker base image。公司內部機器無法
直接 pull registry,所以這裡把 image 打包成 tar,透過 GitHub Releases 散布,內部機器
再 `docker load` 匯入。

image 內含純淨 Debian 12 (bookworm) rootfs,已具備 `bash` / `echo` / `cat` /
`/etc/os-release` 等基本工具。**不依賴 host 的 lib**(lib 都打包在 image 內),只依賴
host kernel 必須是 arm64。

## 為什麼選 `debian:bookworm-slim`

| 面向 | Debian bookworm-slim | Ubuntu | CentOS |
|---|---|---|---|
| 體積(arm64 `docker save`+gzip) | 最小,~27MB | ~30–35MB | base 就 70MB+ |
| 授權 / 重新散布 | DFSG 全自由,**無商標散布限制**,打 tar 上 GitHub 沒問題 | Canonical 對 "Ubuntu" 品牌有 redistribution policy(灰色地帶) | ⚠️ CentOS Linux 已 EOL、Red Hat 收緊散布 |
| 維護狀態 | 活躍、長期支援 | 活躍 | 死掉 / 轉 Stream |

> 想再更小可用 Alpine(~3MB),但它是 musl 而非 glibc,glibc 連結的 binary 會出問題。

---

## 1. Build(在 x86_64 host 上)

```bash
./build.sh
```

`build.sh` 會:
1. 註冊 QEMU(x86 host 模擬 arm64);
2. 用 `buildx --platform linux/arm64` 跨架構 build 並 load 進本機 docker;
3. `docker save` + gzip,**同時**產出兩個檔:
   - `debian-arm64-cortex-a76-bookworm-slim.tar`(未壓縮)
   - `debian-arm64-cortex-a76-bookworm-slim.tar.gz`(gzip,約 27MB)

> 需要 docker(含 buildx)。本 repo 不追蹤 `*.tar` / `*.tar.gz`(見 `.gitignore`)。

## 2. 散布到 GitHub(手動上傳)

到 repo 的 **Releases → Draft a new release**,把上面兩個檔 `.tar` 與 `.tar.gz`
一起拖進 **Attach binaries** 即可(Release asset 單檔上限 2GB,不受 repo 內 100MB 限制)。

## 3. 帶到目標機器並匯入

從 Release 下載任一檔(`.tar` 或 `.tar.gz` 都可),放到 SD 卡 / USB / scp 過去,
然後在**目標 arm64 機器**上:

```bash
# .tar.gz 不用先解壓,docker load 會自動處理 gzip
docker load -i debian-arm64-cortex-a76-bookworm-slim.tar.gz
# 或用未壓縮的:
docker load -i debian-arm64-cortex-a76-bookworm-slim.tar
```

目標機器本身是 arm64,**原生執行、不需要 QEMU**。

---

## 4. Docker 常用指令速查(免再查文件)

### 匯入 / 檢視 image
```bash
docker load -i xxx.tar.gz                  # 從 tar 匯入 image
docker images                              # 列出本機所有 image
docker image inspect debian-arm64-cortex-a76:bookworm-slim   # 看 image 詳細(架構、layer…)
docker image inspect debian-arm64-cortex-a76:bookworm-slim --format '{{.Architecture}}'  # 只看架構 → arm64
docker rmi debian-arm64-cortex-a76:bookworm-slim            # 刪除 image
```

### 跑容器
```bash
# 進入互動式 shell(-i 互動 / -t 配 tty;--rm 離開後自動刪容器)
docker run --rm -it debian-arm64-cortex-a76:bookworm-slim bash

# 跑一條指令就結束
docker run --rm debian-arm64-cortex-a76:bookworm-slim cat /etc/os-release

# 背景常駐 + 取名 + 重啟策略
docker run -d --name mybox --restart unless-stopped debian-arm64-cortex-a76:bookworm-slim sleep infinity

# 掛載 host 目錄進容器(host:container)
docker run --rm -it -v /data/work:/work debian-arm64-cortex-a76:bookworm-slim bash

# 對外開 port(host:container)
docker run -d -p 8080:80 --name web debian-arm64-cortex-a76:bookworm-slim sleep infinity
```

### 觀察 / 管理執行中的容器
```bash
docker ps                  # 列出執行中的容器
docker ps -a               # 列出所有容器(含已停止)
docker logs mybox          # 看容器 stdout/stderr log
docker logs -f mybox       # 持續跟著看 log(follow)
docker exec -it mybox bash # 進入「已在跑」的容器開一個 shell
docker stats               # 即時看 CPU / 記憶體用量
docker inspect mybox       # 看容器詳細設定(IP、mount、env…)
```

### 停止 / 清理
```bash
docker stop mybox          # 停止容器
docker start mybox         # 重新啟動已停止的容器
docker restart mybox       # 重啟
docker rm mybox            # 刪除(已停止的)容器
docker rm -f mybox         # 強制刪除(連同還在跑的)
docker container prune     # 一次清掉所有已停止的容器
docker image prune         # 清掉沒被使用的 dangling image
docker system prune -a     # 大掃除(未使用的 image/容器/網路,小心使用)
```

### 環境健檢
```bash
docker info                # 看 docker engine 整體狀態(版本、儲存、架構…)
docker version            # client / server 版本
```

> 提示:大部分指令的 `<容器>` 可用「容器名」或「容器 ID 前幾碼」;`<image>` 可用
> 「repo:tag」或「image ID」。容器 ID / image ID 用 `docker ps` / `docker images` 查。
