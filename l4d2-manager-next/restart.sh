#!/bin/bash

# ============================================================
# L4D2 restart script
# ============================================================

SERVER_DIR="/home/steam/l4d2"
PID_FILE="$SERVER_DIR/l4d2_27015.pid"
LOG_FILE="$SERVER_DIR/server.log"

PORT="27015"
HOSTIP="106.55.135.45"

cd "$SERVER_DIR" || {
    echo "[ERROR] 无法进入目录: $SERVER_DIR"
    exit 1
}

echo "============================================================"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 开始重启 L4D2 :$PORT"
echo "============================================================"


# ------------------------------------------------------------
# 停止旧服务器
# ------------------------------------------------------------

stop_server() {
    local pid=""

    # 优先使用我们自己保存的 PID
    if [ -f "$PID_FILE" ]; then
        pid="$(cat "$PID_FILE" 2>/dev/null)"

        if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
            echo "[INFO] 找到 PID 文件中的服务器进程: $pid"

            # 新启动的服务使用 setsid，因此可以结束整个进程组
            kill -TERM -- "-$pid" 2>/dev/null || kill -TERM "$pid" 2>/dev/null
        fi
    fi

    # 同时查找当前 27015 实例。
    # 主要用于第一次使用本脚本、PID 文件不存在的情况。
    OLD_PIDS="$(pgrep -f "srcds_(run|linux).*hostport[[:space:]]+$PORT" 2>/dev/null || true)"

    if [ -n "$OLD_PIDS" ]; then
        echo "[INFO] 找到 $PORT 端口对应的旧 L4D2 进程:"
        echo "$OLD_PIDS"

        for oldpid in $OLD_PIDS; do
            # 不允许误杀当前 restart.sh
            if [ "$oldpid" != "$$" ]; then
                kill -TERM "$oldpid" 2>/dev/null || true
            fi
        done
    fi

    # 最多等待 15 秒
    for i in $(seq 1 15); do
        RUNNING="$(pgrep -f "srcds_(run|linux).*hostport[[:space:]]+$PORT" 2>/dev/null || true)"

        if [ -z "$RUNNING" ]; then
            echo "[INFO] 旧服务器已经退出。"
            rm -f "$PID_FILE"
            return 0
        fi

        echo "[INFO] 等待旧服务器退出... ($i/15)"
        sleep 1
    done

    # 超过 15 秒仍然存在则强制结束
    RUNNING="$(pgrep -f "srcds_(run|linux).*hostport[[:space:]]+$PORT" 2>/dev/null || true)"

    if [ -n "$RUNNING" ]; then
        echo "[WARN] 服务器没有正常退出，开始强制结束："
        echo "$RUNNING"

        for oldpid in $RUNNING; do
            if [ "$oldpid" != "$$" ]; then
                kill -KILL "$oldpid" 2>/dev/null || true
            fi
        done

        sleep 2
    fi

    rm -f "$PID_FILE"
}


# ------------------------------------------------------------
# 启动服务器
# ------------------------------------------------------------

start_server() {
    echo "[INFO] 正在启动 L4D2..."

    # setsid:
    #   创建独立 session / process group，
    #   以后重启时可以一次结束整个游戏服务器进程组。
    #
    # nohup + stdin 重定向:
    #   防止 l4d2-server-next 等待此脚本及游戏进程。

    nohup setsid "$SERVER_DIR/srcds_run" \
        -game left4dead2 \
        -insecure \
        +hostport "$PORT" \
        +hostip "$HOSTIP" \
        +ip 0.0.0.0 \
        -condebug \
        -tickrate 60 \
        +sv_setmax 31 \
        +map c2m1_highway \
        +exec server.cfg \
        >> "$LOG_FILE" 2>&1 < /dev/null &

    NEW_PID=$!

    echo "$NEW_PID" > "$PID_FILE"

    echo "[INFO] 新进程 PID: $NEW_PID"

    # 给服务器一点时间检查是否立即崩溃
    sleep 3

    if kill -0 "$NEW_PID" 2>/dev/null; then
        echo "[OK] L4D2 启动成功。"
        echo "[OK] PID: $NEW_PID"
        echo "[OK] PORT: $PORT"
        echo "[OK] LOG: $LOG_FILE"
        return 0
    else
        echo "[ERROR] L4D2 启动失败。"
        echo "[ERROR] 请检查日志：$LOG_FILE"
        rm -f "$PID_FILE"
        return 1
    fi
}


stop_server
start_server

exit $?
