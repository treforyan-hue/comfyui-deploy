#!/bin/bash
# ══════════════════════════════════════════════════════════════
# RunPod post_start hook — runs AFTER sshd, BEFORE sleep infinity.
#
# Invoked by /start.sh (inherited from runpod/pytorch base) at
# container boot, automatically. We never invoke this script via
# SSH from the bot; it runs as part of container startup so the
# bot doesn't need to babysit install kickoff timing.
#
# What it does:
#   1. Source /etc/rp_environment so env vars set on the pod
#      (HF_TOKEN, CIVITAI_TOKEN, WORKFLOW_ID) are visible.
#   2. Launch ComfyUI server in the background on :8188.
#   3. If WORKFLOW_ID is set, launch install.sh in the background
#      to download models for that workflow. The install.sh script
#      is baked into /workspace/install.sh by jkhlk/comfyui-ready
#      (it's the same script Vast.ai uses via onstart_cmd).
#
# Detached pattern: explicit `< /dev/null > log 2>&1 &` so the
# parent /start.sh can return and let `sleep infinity` keep the
# container alive. Without these redirects, /start.sh would block
# waiting for the bg processes' fds.
# ══════════════════════════════════════════════════════════════
set -u  # NOTE: no -e — install.sh handles its own errors and we
        #       don't want a failed model download to kill the pod

echo "[post_start] === ComfyUI Ready RunPod hook ==="
date

# 1. Source RunPod-exported env vars (HF_TOKEN, CIVITAI_TOKEN, WORKFLOW_ID)
if [ -f /etc/rp_environment ]; then
    # shellcheck disable=SC1091
    source /etc/rp_environment
    echo "[post_start] sourced /etc/rp_environment"
else
    echo "[post_start] WARN: /etc/rp_environment not found — env vars may be missing"
fi

cd /workspace/ComfyUI || {
    echo "[post_start] FATAL: /workspace/ComfyUI missing — image is broken"
    exit 1
}

# 2. Launch ComfyUI server in background
mkdir -p /workspace
echo "[post_start] starting ComfyUI on 0.0.0.0:8188"
nohup python3 main.py \
    --listen 0.0.0.0 \
    --port 8188 \
    --front-end-version Comfy-Org/ComfyUI_frontend@1.42.6 \
    > /workspace/comfyui.log 2>&1 < /dev/null &
echo $! > /workspace/comfyui.pid
echo "[post_start] ComfyUI pid=$(cat /workspace/comfyui.pid)"

# 3. If WORKFLOW_ID is set, kick install.sh in the background.
#    install.sh is idempotent — it skips files that already exist,
#    so re-runs are cheap. The script is baked into the image at
#    /workspace/install.sh by the parent jkhlk/comfyui-ready build.
if [ -n "${WORKFLOW_ID:-}" ]; then
    if [ -f /workspace/install.sh ]; then
        echo "[post_start] launching install.sh for WORKFLOW_ID=$WORKFLOW_ID"
        nohup bash /workspace/install.sh "$WORKFLOW_ID" \
            > /workspace/install.log 2>&1 < /dev/null &
        echo $! > /workspace/install.pid
        echo "[post_start] install.sh pid=$(cat /workspace/install.pid)"
    else
        echo "[post_start] WARN: /workspace/install.sh missing — cannot install models"
    fi
else
    echo "[post_start] WORKFLOW_ID not set — skipping model download"
fi

echo "[post_start] === hook done ==="
