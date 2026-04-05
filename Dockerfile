# ══════════════════════════════════════════════════════════════
# ComfyUI Ready Image
#
# Contains: ComfyUI + 39 custom nodes + all pip dependencies
# Does NOT contain: models (downloaded at runtime per workflow)
#
# Usage: docker pull ghcr.io/treforyan-hue/comfyui-ready:latest
# ══════════════════════════════════════════════════════════════

FROM runpod/pytorch:2.4.0-py3.11-cuda12.4.1-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV COMFY=/workspace/ComfyUI
ENV CNODES=/workspace/ComfyUI/custom_nodes

# System packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl ffmpeg libgl1 libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# ── ComfyUI ──
RUN git clone --depth 1 https://github.com/comfyanonymous/ComfyUI.git $COMFY \
    && pip install --break-system-packages -q -r $COMFY/requirements.txt

# Create model directories (models downloaded at runtime)
RUN mkdir -p $COMFY/models/{diffusion_models,unet,vae,text_encoders,clip,clip_vision} \
    && mkdir -p $COMFY/models/{loras,checkpoints,upscale_models,detection,sam2,sams,rife} \
    && mkdir -p $COMFY/models/{controlnet,model_patches,seedvr2} \
    && mkdir -p $COMFY/models/ultralytics/{bbox,segm} \
    && mkdir -p $COMFY/user/default/workflows

# ── Custom Nodes (39 packages) ──
# Core nodes
RUN git clone --depth 1 https://github.com/kijai/ComfyUI-KJNodes $CNODES/ComfyUI-KJNodes
RUN git clone --depth 1 https://github.com/kijai/ComfyUI-WanVideoWrapper $CNODES/ComfyUI-WanVideoWrapper
RUN git clone --depth 1 https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite $CNODES/ComfyUI-VideoHelperSuite
RUN git clone --depth 1 https://github.com/rgthree/rgthree-comfy $CNODES/rgthree-comfy
RUN git clone --depth 1 https://github.com/yolain/ComfyUI-Easy-Use $CNODES/ComfyUI-Easy-Use
RUN git clone --depth 1 https://github.com/pythongosssss/ComfyUI-Custom-Scripts $CNODES/ComfyUI-Custom-Scripts
RUN git clone --depth 1 https://github.com/ltdrdata/ComfyUI-Impact-Pack $CNODES/ComfyUI-Impact-Pack

# Video / Animation
RUN git clone --depth 1 https://github.com/kijai/ComfyUI-segment-anything-2 $CNODES/ComfyUI-segment-anything-2
RUN git clone --depth 1 https://github.com/kijai/ComfyUI-WanAnimatePreprocess $CNODES/ComfyUI-WanAnimatePreprocess
RUN git clone --depth 1 https://github.com/Fannovel16/ComfyUI-Frame-Interpolation $CNODES/ComfyUI-Frame-Interpolation
RUN git clone --depth 1 https://github.com/vrgamegirl19/comfyui-vrgamedevgirl $CNODES/comfyui-vrgamedevgirl

# ControlNet / Image
RUN git clone --depth 1 https://github.com/Fannovel16/comfyui_controlnet_aux $CNODES/comfyui_controlnet_aux
RUN git clone --depth 1 https://github.com/ClownsharkBatwing/RES4LYF $CNODES/RES4LYF
RUN git clone --depth 1 https://github.com/numz/ComfyUI-SeedVR2_VideoUpscaler $CNODES/ComfyUI-SeedVR2_VideoUpscaler
RUN git clone --depth 1 https://github.com/cubiq/ComfyUI_essentials $CNODES/ComfyUI_essentials
RUN git clone --depth 1 https://github.com/cubiq/ComfyUI_IPAdapter_plus $CNODES/ComfyUI_IPAdapter_plus
RUN git clone --depth 1 https://github.com/erosDiffusion/ComfyUI-EulerDiscreteScheduler $CNODES/ComfyUI-EulerDiscreteScheduler

# Utility
RUN git clone --depth 1 https://github.com/city96/ComfyUI-GGUF $CNODES/ComfyUI-GGUF
RUN git clone --depth 1 https://github.com/kijai/ComfyUI-Florence2 $CNODES/ComfyUI-Florence2
RUN git clone --depth 1 https://github.com/pythongosssss/ComfyUI-WD14-Tagger $CNODES/ComfyUI-WD14-Tagger
RUN git clone --depth 1 https://github.com/digitaljohn/comfyui-propost $CNODES/comfyui-propost
RUN git clone --depth 1 https://github.com/PGCRT/CRT-Nodes $CNODES/CRT-Nodes
RUN git clone --depth 1 https://github.com/Jonseed/ComfyUI-Detail-Daemon $CNODES/ComfyUI-Detail-Daemon
RUN git clone --depth 1 https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes $CNODES/ComfyUI_Comfyroll_CustomNodes
RUN git clone --depth 1 https://github.com/evanspearman/ComfyMath $CNODES/ComfyMath
RUN git clone --depth 1 https://github.com/jags111/efficiency-nodes-comfyui $CNODES/efficiency-nodes-comfyui
RUN git clone --depth 1 https://github.com/ssitu/ComfyUI_UltimateSDUpscale $CNODES/ComfyUI_UltimateSDUpscale
RUN git clone --depth 1 https://github.com/Smirnov75/ComfyUI-mxToolkit $CNODES/ComfyUI-mxToolkit
RUN git clone --depth 1 https://github.com/daxcay/ComfyUI-DataSet $CNODES/ComfyUI-DataSet
RUN git clone --depth 1 https://github.com/chflame163/ComfyUI_LayerStyle $CNODES/ComfyUI_LayerStyle

# Sub-packages
RUN git clone --depth 1 https://github.com/ltdrdata/ComfyUI-Impact-Subpack $CNODES/ComfyUI-Impact-Subpack
RUN git clone --depth 1 https://github.com/filliptm/ComfyUI_Fill-Nodes $CNODES/ComfyUI_Fill-Nodes
RUN git clone --depth 1 https://github.com/JPS-GER/ComfyUI_JPS-Nodes $CNODES/ComfyUI_JPS-Nodes
RUN git clone --depth 1 https://github.com/WASasquatch/was-node-suite-comfyui $CNODES/was-node-suite-comfyui
RUN git clone --depth 1 https://github.com/BadCafeCode/masquerade-nodes-comfyui $CNODES/masquerade-nodes-comfyui
RUN git clone --depth 1 https://github.com/jamesWalker55/comfyui-various $CNODES/comfyui-various
RUN git clone --depth 1 https://github.com/SKBv0/ComfyUI_SKBundle $CNODES/ComfyUI_SKBundle
RUN git clone --depth 1 https://github.com/teskor-hub/comfyui-teskors-utils $CNODES/comfyui-teskors-utils

# ── Bundled extras ──
COPY extras/ComfyUI_INSTARAW $CNODES/ComfyUI_INSTARAW
COPY extras/KiaraPanels $CNODES/KiaraPanels
RUN mkdir -p $CNODES/ComfyUI_INSTARAW/js

# ── Install ALL pip requirements ──
RUN for d in $CNODES/*/; do \
        if [ -f "$d/requirements.txt" ]; then \
            pip install --break-system-packages -q -r "$d/requirements.txt" 2>/dev/null || true; \
        fi; \
    done

# ── Post-install fixes ──
# Impact-Pack
RUN cd $CNODES/ComfyUI-Impact-Pack && python install.py 2>/dev/null || true

# UltimateSDUpscale submodule
RUN mkdir -p $CNODES/ComfyUI_UltimateSDUpscale/repositories \
    && git clone --depth 1 https://github.com/Coyote-A/ultimate-upscale-for-automatic1111.git \
       $CNODES/ComfyUI_UltimateSDUpscale/repositories/ultimate_sd_upscale 2>/dev/null || true

# Frame-Interpolation RIFE dir
RUN mkdir -p $CNODES/ComfyUI-Frame-Interpolation/ckpts/rife

# Extra pip packages
RUN pip install --break-system-packages -q \
    sageattention mediapipe==0.10.14 lpips pyexiftool \
    segment_anything imageio-ffmpeg insightface onnxruntime-gpu \
    2>/dev/null || true

# ── Cleanup ──
RUN pip cache purge 2>/dev/null || true \
    && rm -rf /tmp/* /root/.cache/pip

# Copy install.sh for model downloads at runtime
COPY install.sh /workspace/install.sh
COPY lib/ /workspace/lib/
COPY workflows/ /workspace/workflows/

WORKDIR /workspace/ComfyUI

# Default: start ComfyUI (can be overridden by docker_args)
CMD ["python", "main.py", "--listen", "0.0.0.0", "--port", "8188"]
