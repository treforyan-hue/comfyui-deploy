#!/usr/bin/env bash
# OFM Tech AN.MODE V2 — Best quality Wan animation (bf16)
# GPU: 48GB+ | Models: ~42GB | Time: ~120 min
# Source: 2.Команды JupyterTerminal.txt

models_ofm_tech_v2() {
    section "Models: OFM Tech V2 (Wan 2.2 Animate bf16)"

    # Wan 2.2 Animate 14B bf16 (LARGE: 28GB)
    dl_hf "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_animate_14B_bf16.safetensors" \
        "$MODELS/diffusion_models/wan2.2_animate_14B_bf16.safetensors"

    # VAE
    dl_hf "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan2_1_VAE_bf16.safetensors" \
        "$MODELS/vae/Wan2_1_VAE_bf16.safetensors"

    # Text encoders
    dl_hf "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp16.safetensors" \
        "$MODELS/text_encoders/umt5_xxl_fp16.safetensors"
    dl_hf "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors" \
        "$MODELS/clip/clip_l.safetensors"
    dl_hf "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp8_e4m3fn.safetensors" \
        "$MODELS/text_encoders/t5xxl_fp8_e4m3fn.safetensors"

    # CLIP vision
    dl_hf "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors" \
        "$MODELS/clip_vision/clip_vision_h.safetensors"

    # Detection + SAM
    dl_pub "https://huggingface.co/Kijai/vitpose_comfy/resolve/main/onnx/vitpose_h_wholebody_model.onnx" \
        "$MODELS/detection/vitpose_h_wholebody_model.onnx"
    dl_pub "https://huggingface.co/Kijai/vitpose_comfy/resolve/main/onnx/vitpose_h_wholebody_data.bin" \
        "$MODELS/detection/vitpose_h_wholebody_data.bin"
    dl_pub "https://huggingface.co/Wan-AI/Wan2.2-Animate-14B/resolve/main/process_checkpoint/det/yolov10m.onnx" \
        "$MODELS/detection/yolov10m.onnx"
    dl_hf "https://huggingface.co/Kijai/sam2-safetensors/resolve/main/sam2.1_hiera_base_plus.safetensors" \
        "$MODELS/sam2/sam2.1_hiera_base_plus.safetensors"

    # RIFE
    dl_pub "https://huggingface.co/Fannovel16/ComfyUI-Frame-Interpolation/resolve/main/rife49.pth" \
        "$MODELS/rife/rife49.pth"
    # RIFE symlink for Frame-Interpolation node
    make_link "$MODELS/rife/rife49.pth" "$CNODES/ComfyUI-Frame-Interpolation/ckpts/rife/rife49.pth"

    # LoRAs (5)
    dl_hf "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/WanAnimate_relight_lora_fp16.safetensors" \
        "$MODELS/loras/wan2.2_animate14B_relight_lora_bf16.safetensors"
    dl_hf "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Lightx2v/lightx2vT2V14B_cfg_step_distillv2_lora_rank256_bf16.safetensors" \
        "$MODELS/loras/lightx2vT2V14B_cfg_step_distillv2_lora_rank256_bf16.safetensors"
    dl_hf "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Lightx2v/wan2.2_iv_lightx2v_4steps_lora_v1_low_noise.safetensors" \
        "$MODELS/loras/wan2.2_iv_lightx2v_4steps_lora_v1_low_noise.safetensors"
    dl_hf "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Pusa/Wan2.1PusaLoRA14B_rank512_bf16.safetensors" \
        "$MODELS/loras/Wan2.1PusaLoRA14B_rank512_bf16.safetensors"
    dl_hf "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan22_FunReward/Wan2.2-Fun-A14B-Inp-low-noise-MPS.safetensors" \
        "$MODELS/loras/Wan2.2-Fun-A14B-Inp-low-noise-MPS.safetensors"
}
