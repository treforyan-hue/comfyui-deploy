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
#   2. If WORKFLOW_ID is set, launch install.sh in the background.
#      install.sh DOWNLOADS MODELS, then starts ComfyUI itself at
#      the very end (same flow as Vast.ai).
#
# CRITICAL: we do NOT start ComfyUI here in parallel with install.sh.
# An earlier version did and caused this bug:
#   - ComfyUI starts immediately on :8188, responds to /system_stats
#   - bot probes ComfyUI, sees it ready, marks pod status="ready"
#   - user clicks add_wf thinking install is done
#   - meanwhile install.sh + aria2c are still saturating network/CPU
#   - sshd gets starved, refuses new SSH handshakes (TCP open but
#     SSH banner never sent → asyncssh.TimeoutError)
#   - add_wf SSH thundering herd kills the pod entirely
# By keeping it sequential (install.sh → ComfyUI), bot only sees
# ready when install.sh truly finishes and writes the DONE markers
# (Nodes: N loaded / ComfyUI is ready) that the regex catches.
#
# Detached pattern: explicit `< /dev/null > log 2>&1 &` so the
# parent /start.sh can return and let `sleep infinity` keep the
# container alive. Without these redirects, /start.sh would block
# waiting for the bg process's fds.
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

mkdir -p /workspace

# 2. Launch install.sh in the background. install.sh handles model
#    downloads AND starts ComfyUI at the very end (same as Vast onstart).
#    The script is baked into the image at /workspace/install.sh by
#    the parent jkhlk/comfyui-ready build.
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
    # No WORKFLOW_ID = manual pod, no auto-install. The user can SSH in
    # and start ComfyUI themselves, or set WORKFLOW_ID and reboot.
    echo "[post_start] WORKFLOW_ID not set — skipping install + ComfyUI start"
fi

echo "[post_start] === hook done ==="
