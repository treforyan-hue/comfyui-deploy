#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════
# ALL 38 CUSTOM NODES — installed ONCE, covers ALL 13 workflows
# After this: ZERO red nodes for ANY workflow JSON
# ══════════════════════════════════════════════════════════════

install_all_nodes() {
    section "Custom Nodes (38 packages)"

    # ── Core nodes (used by 5+ workflows) ──
    clone_node "https://github.com/kijai/ComfyUI-KJNodes"
    clone_node "https://github.com/kijai/ComfyUI-WanVideoWrapper"
    clone_node "https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite"
    clone_node "https://github.com/rgthree/rgthree-comfy"
    clone_node "https://github.com/yolain/ComfyUI-Easy-Use"
    clone_node "https://github.com/pythongosssss/ComfyUI-Custom-Scripts"
    clone_node "https://github.com/ltdrdata/ComfyUI-Impact-Pack"

    # ── Video / Animation nodes ──
    clone_node "https://github.com/kijai/ComfyUI-segment-anything-2"
    clone_node "https://github.com/kijai/ComfyUI-WanAnimatePreprocess"
    clone_node "https://github.com/Fannovel16/ComfyUI-Frame-Interpolation"
    clone_node "https://github.com/vrgamegirl19/comfyui-vrgamedevgirl"

    # ── ControlNet / Image nodes ──
    clone_node "https://github.com/Fannovel16/comfyui_controlnet_aux"
    clone_node "https://github.com/ClownsharkBatwing/RES4LYF"
    clone_node "https://github.com/numz/ComfyUI-SeedVR2_VideoUpscaler"
    clone_node "https://github.com/cubiq/ComfyUI_essentials"
    clone_node "https://github.com/cubiq/ComfyUI_IPAdapter_plus"
    clone_node "https://github.com/erosDiffusion/ComfyUI-EulerDiscreteScheduler"

    # ── Utility nodes ──
    clone_node "https://github.com/city96/ComfyUI-GGUF"
    clone_node "https://github.com/kijai/ComfyUI-Florence2"
    clone_node "https://github.com/pythongosssss/ComfyUI-WD14-Tagger"
    clone_node "https://github.com/digitaljohn/comfyui-propost"
    clone_node "https://github.com/PGCRT/CRT-Nodes"
    clone_node "https://github.com/Jonseed/ComfyUI-Detail-Daemon"
    clone_node "https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes"
    clone_node "https://github.com/evanspearman/ComfyMath"
    clone_node "https://github.com/jags111/efficiency-nodes-comfyui"
    clone_node "https://github.com/ssitu/ComfyUI_UltimateSDUpscale"
    clone_node "https://github.com/Smirnov75/ComfyUI-mxToolkit"
    clone_node "https://github.com/daxcay/ComfyUI-DataSet"
    clone_node "https://github.com/chflame163/ComfyUI_LayerStyle"

    # ── Sub-packages & extras ──
    clone_node "https://github.com/ltdrdata/ComfyUI-Impact-Subpack"
    clone_node "https://github.com/filliptm/ComfyUI_Fill-Nodes"
    clone_node "https://github.com/JPS-GER/ComfyUI_JPS-Nodes"
    clone_node "https://github.com/WASasquatch/was-node-suite-comfyui"
    clone_node "https://github.com/BadCafeCode/masquerade-nodes-comfyui"
    clone_node "https://github.com/jamesWalker55/comfyui-various"
    clone_node "https://github.com/SKBv0/ComfyUI_SKBundle"
    clone_node "https://github.com/teskor-hub/comfyui-teskors-utils"

    # ── KiaraPanels (custom generated nodes for kiara_sasat) ──
    if [ -d "$SCRIPT_DIR/extras/KiaraPanels" ] && [ ! -d "$CNODES/KiaraPanels" ]; then
        log "Installing KiaraPanels..."
        cp -r "$SCRIPT_DIR/extras/KiaraPanels" "$CNODES/"
    fi

    # ── INSTARAW (proprietary, bundled in repo) ──
    if [ -d "$SCRIPT_DIR/extras/ComfyUI_INSTARAW" ] && [ ! -d "$CNODES/ComfyUI_INSTARAW" ]; then
        log "Installing INSTARAW..."
        cp -r "$SCRIPT_DIR/extras/ComfyUI_INSTARAW" "$CNODES/"
        mkdir -p "$CNODES/ComfyUI_INSTARAW/js"
        if [ -f "$CNODES/ComfyUI_INSTARAW/requirements.txt" ]; then
            pip install --break-system-packages -q -r "$CNODES/ComfyUI_INSTARAW/requirements.txt" 2>/dev/null || true
        fi
    fi

    # ── Post-install fixes ──

    # Impact-Pack submodule
    if [ -d "$CNODES/ComfyUI-Impact-Pack" ] && [ -f "$CNODES/ComfyUI-Impact-Pack/install.py" ]; then
        cd "$CNODES/ComfyUI-Impact-Pack" && python install.py 2>/dev/null || true
        cd "$COMFY"
    fi

    # UltimateSDUpscale submodule
    if [ -d "$CNODES/ComfyUI_UltimateSDUpscale" ] && [ ! -d "$CNODES/ComfyUI_UltimateSDUpscale/repositories" ]; then
        mkdir -p "$CNODES/ComfyUI_UltimateSDUpscale/repositories"
        git clone --quiet --depth 1 \
            "https://github.com/Coyote-A/ultimate-upscale-for-automatic1111.git" \
            "$CNODES/ComfyUI_UltimateSDUpscale/repositories/ultimate_sd_upscale" 2>/dev/null || true
    fi

    # Frame-Interpolation RIFE directory
    mkdir -p "$CNODES/ComfyUI-Frame-Interpolation/ckpts/rife" 2>/dev/null || true

    # Extra pip packages needed by various nodes
    pip install --break-system-packages -q \
        sageattention mediapipe==0.10.14 lpips pyexiftool \
        segment_anything imageio-ffmpeg insightface onnxruntime-gpu \
        2>/dev/null || warn "Some pip packages failed (non-critical)"

    log "All custom nodes installed"
}
