#!/usr/bin/env bash
# OFM Skin Gen3 — Realistic skin/face generation
# GPU: 16GB+ | Models: ~20GB | Time: ~60 min
# Source: 1.Команды JupyterTerminal.txt

models_ofm_skin_gen3() {
    section "Models: OFM Skin Gen3"

    # CivitAI checkpoints
    dl_civitai "1301668" "$MODELS/loras/aidmaRealisticSkin-FLUX-v0.1.safetensors"
    dl_civitai "1413133" "$MODELS/unet/ultrarealFineTune_v4.safetensors"
    dl_civitai "2593828" "$MODELS/unet/zEpicrealism_turboV1Fp8.safetensors"

    # CLIP + T5
    dl_hf "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors" \
        "$MODELS/clip/clip_l.safetensors"
    dl_hf "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp8_e4m3fn.safetensors" \
        "$MODELS/clip/t5xxl_fp8_e4m3fn.safetensors"

    # Qwen + ae VAE
    dl_hf "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/text_encoders/qwen_3_4b.safetensors" \
        "$MODELS/text_encoders/qwen_3_4b.safetensors"
    dl_pub "https://huggingface.co/camenduru/FLUX.1-dev-ungated/resolve/main/ae.safetensors" \
        "$MODELS/vae/ae.safetensors"

    # SeedVR2
    dl_hf "https://huggingface.co/numz/SeedVR2_comfyUI/resolve/main/ema_vae_fp16.safetensors" \
        "$MODELS/vae/ema_vae_fp16.safetensors"
    dl_hf "https://huggingface.co/numz/SeedVR2_comfyUI/resolve/main/seedvr2_ema_3b_fp8_e4m3fn.safetensors" \
        "$MODELS/checkpoints/seedvr2_ema_3b_fp8_e4m3fn.safetensors"

    # Upscaler
    dl_pub "https://huggingface.co/LS110824/upscale/resolve/main/4x-ClearRealityV1.pth" \
        "$MODELS/upscale_models/4x-ClearRealityV1.pth"
}
