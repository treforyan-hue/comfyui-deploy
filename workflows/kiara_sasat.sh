#!/usr/bin/env bash
# Kiara Sasat Image — SDXL reference image gen
# GPU: 16GB+ | Models: ~15GB | Time: ~45 min

models_kiara_sasat() {
    section "Models: Kiara Sasat (SDXL)"

    # SDXL checkpoint (CivitAI)
    dl_civitai "2368123" "$MODELS/checkpoints/gonzalomoXLFluxPony_v60PhotoXLDMD.safetensors"

    # Realism LoRA (CivitAI)
    dl_civitai "2074888" "$MODELS/loras/Realism_Lora_By_Stable_Yogi_V3_Lite.safetensors"

    # Upscaler
    dl_pub "https://huggingface.co/uwg/upscaler/resolve/main/ESRGAN/4x-UltraSharp.pth" \
        "$MODELS/upscale_models/4x-UltraSharp.pth"

    # Impact Pack models (auto-download on first use: face_yolov8m, hand_yolov8s, sam_vit_b)
    log "Impact Pack detection models will auto-download on first use"
}
