#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════
# COMMON FUNCTIONS — sourced by install.sh
# Supports: --dry-run mode (verifies URLs without downloading)
# Supports: RunPod + Vast.ai (auto-detects platform)
# ══════════════════════════════════════════════════════════════
set -euo pipefail

COMFY=/workspace/ComfyUI
MODELS="$COMFY/models"
CNODES="$COMFY/custom_nodes"

DL_OK=0; DL_SKIP=0; DL_FAIL=0
DRY_RUN="${DRY_RUN:-0}"

# ── Logging ──
log()  { echo -e "\033[32m[+]\033[0m $*"; }
warn() { echo -e "\033[33m[!]\033[0m $*"; }
err()  { echo -e "\033[31m[x]\033[0m $*"; }
section() { echo -e "\n\033[36m═══ $* ═══\033[0m\n"; }

# ── Dry-run: verify URL returns 200 ──
_check_url() {
    local url="$1" name="$2" auth_header="${3:-}"
    local http_code
    if [ -n "$auth_header" ]; then
        http_code=$(curl -s -o /dev/null -w "%{http_code}" -L -H "$auth_header" --head "$url" 2>/dev/null || echo "000")
    else
        http_code=$(curl -s -o /dev/null -w "%{http_code}" -L --head "$url" 2>/dev/null || echo "000")
    fi
    if [ "$http_code" = "200" ] || [ "$http_code" = "302" ] || [ "$http_code" = "301" ]; then
        log "URL OK ($http_code): $name"
        DL_OK=$((DL_OK + 1))
    else
        err "URL FAIL ($http_code): $name → $url"
        DL_FAIL=$((DL_FAIL + 1))
    fi
}

# ── Download: HuggingFace (with token from $HF_TOKEN env) ──
dl_hf() {
    local url="$1" dest="$2"
    local name; name=$(basename "$dest")

    if [ "$DRY_RUN" = "1" ]; then
        _check_url "$url" "$name" "Authorization: Bearer ${HF_TOKEN:-}"
        return 0
    fi

    if [ -f "$dest" ] && [ "$(stat -c%s "$dest" 2>/dev/null || echo 0)" -gt 1000000 ]; then
        log "SKIP: $name (exists)"
        DL_SKIP=$((DL_SKIP + 1))
        return 0
    fi
    mkdir -p "$(dirname "$dest")"
    log "Downloading: $name ..."
    if curl -L --progress-bar -H "Authorization: Bearer ${HF_TOKEN:-}" "$url" -o "$dest" 2>&1; then
        if [ "$(stat -c%s "$dest" 2>/dev/null || echo 0)" -gt 1000 ]; then
            DL_OK=$((DL_OK + 1))
            return 0
        fi
    fi
    err "FAIL: $name"
    rm -f "$dest"
    DL_FAIL=$((DL_FAIL + 1))
}

# ── Download: HuggingFace (public, no auth) ──
dl_pub() {
    local url="$1" dest="$2"
    local name; name=$(basename "$dest")

    if [ "$DRY_RUN" = "1" ]; then
        _check_url "$url" "$name"
        return 0
    fi

    if [ -f "$dest" ] && [ "$(stat -c%s "$dest" 2>/dev/null || echo 0)" -gt 1000000 ]; then
        log "SKIP: $name (exists)"
        DL_SKIP=$((DL_SKIP + 1))
        return 0
    fi
    mkdir -p "$(dirname "$dest")"
    log "Downloading: $name ..."
    if curl -L --progress-bar "$url" -o "$dest" 2>&1; then
        if [ "$(stat -c%s "$dest" 2>/dev/null || echo 0)" -gt 1000 ]; then
            DL_OK=$((DL_OK + 1))
            return 0
        fi
    fi
    err "FAIL: $name"
    rm -f "$dest"
    DL_FAIL=$((DL_FAIL + 1))
}

# ── Download: CivitAI (with $CIVITAI_TOKEN) ──
dl_civitai() {
    local model_id="$1" dest="$2"
    local name; name=$(basename "$dest")

    if [ "$DRY_RUN" = "1" ]; then
        local tok="${CIVITAI_TOKEN:-}"
        if [ -z "$tok" ]; then
            warn "CIVITAI_TOKEN not set — cannot verify $name"
            DL_FAIL=$((DL_FAIL + 1))
        else
            _check_url "https://civitai.com/api/download/models/${model_id}?type=Model&format=SafeTensor" \
                "$name" "Authorization: Bearer $tok"
        fi
        return 0
    fi

    if [ -f "$dest" ] && [ "$(stat -c%s "$dest" 2>/dev/null || echo 0)" -gt 1000000 ]; then
        log "SKIP: $name (exists)"
        DL_SKIP=$((DL_SKIP + 1))
        return 0
    fi
    mkdir -p "$(dirname "$dest")"
    log "Downloading from CivitAI: $name ..."
    local tok="${CIVITAI_TOKEN:-}"
    if [ -z "$tok" ]; then
        warn "CIVITAI_TOKEN not set, skipping $name"
        DL_FAIL=$((DL_FAIL + 1))
        return 1
    fi
    if curl -L --progress-bar -H "Authorization: Bearer $tok" \
        "https://civitai.com/api/download/models/${model_id}?type=Model&format=SafeTensor" \
        -o "$dest" 2>&1; then
        if [ "$(stat -c%s "$dest" 2>/dev/null || echo 0)" -gt 1000 ]; then
            DL_OK=$((DL_OK + 1))
            return 0
        fi
    fi
    err "FAIL: $name"
    rm -f "$dest"
    DL_FAIL=$((DL_FAIL + 1))
}

# ── Clone custom node (idempotent) ──
clone_node() {
    local url="$1"
    local name; name=$(basename "$url" .git)

    if [ "$DRY_RUN" = "1" ]; then
        log "CHECK node: $name → $url"
        DL_OK=$((DL_OK + 1))
        return 0
    fi

    if [ -d "$CNODES/$name" ]; then
        log "SKIP node: $name (exists)"
        return 0
    fi
    log "Cloning: $name"
    git clone --quiet --depth 1 "$url" "$CNODES/$name" 2>/dev/null || {
        warn "Clone failed: $name"
        DL_FAIL=$((DL_FAIL + 1))
        return 1
    }
    if [ -f "$CNODES/$name/requirements.txt" ]; then
        pip install --break-system-packages -q -r "$CNODES/$name/requirements.txt" 2>/dev/null || true
    fi
}

# ── Create symlink (safe) ──
make_link() {
    local target="$1" link="$2"
    [ "$DRY_RUN" = "1" ] && return 0
    if [ ! -L "$link" ] && [ ! -f "$link" ]; then
        ln -sf "$target" "$link"
        log "Symlink: $(basename "$link") -> $(basename "$target")"
    fi
}

# ── Detect platform & generate ComfyUI URL ──
detect_platform() {
    RPID="${RUNPOD_POD_ID:-}"
    if [ -n "$RPID" ]; then
        PLATFORM="runpod"
        COMFYUI_URL="https://${RPID}-8188.proxy.runpod.net"
        return
    fi

    # Vast.ai: check for VAST_CONTAINERLABEL or direct port
    if [ -n "${VAST_CONTAINERLABEL:-}" ] || [ -n "${CONTAINER_ID:-}" ]; then
        PLATFORM="vastai"
        local ip; ip=$(hostname -I 2>/dev/null | awk '{print $1}')
        COMFYUI_URL="http://${ip:-localhost}:8188"
        return
    fi

    # Local/generic
    PLATFORM="local"
    local ip; ip=$(hostname -I 2>/dev/null | awk '{print $1}')
    COMFYUI_URL="http://${ip:-localhost}:8188"
}
