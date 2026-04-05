#!/usr/bin/env bash
# Kiara Sasat Image — SDXL + Flux Klein 4B reference image gen
# GPU: 16GB+ | Models: ~15GB | Time: ~45 min
# Source: kiara_setup.py original models list

models_kiara_sasat() {
    section "Models: Kiara Sasat (SDXL + Flux Klein 4B)"

    # SDXL checkpoint (CivitAI)
    dl_civitai "2368123" "$MODELS/checkpoints/gonzalomoXLFluxPony_v60PhotoXLDMD.safetensors"

    # LoRAs (CivitAI)
    dl_civitai "2074888" "$MODELS/loras/Realism_Lora_By_Stable_Yogi_V3_Lite.safetensors"
    dl_civitai "1089573" "$MODELS/loras/super_skin_detailer.safetensors"

    # Flux Klein 4B (Stage II)
    dl_hf "https://huggingface.co/Comfy-Org/flux2-klein-4B/resolve/main/split_files/diffusion_models/flux-2-klein-4b.safetensors" \
        "$MODELS/diffusion_models/flux-2-klein-4b.safetensors"
    dl_hf "https://huggingface.co/Comfy-Org/flux2-klein-4B/resolve/main/split_files/text_encoders/qwen_3_4b.safetensors" \
        "$MODELS/text_encoders/qwen_3_4b.safetensors"
    dl_hf "https://huggingface.co/Comfy-Org/flux2-klein-4B/resolve/main/split_files/vae/flux2-vae.safetensors" \
        "$MODELS/vae/flux2-vae.safetensors"

    # Upscaler
    dl_pub "https://huggingface.co/uwg/upscaler/resolve/main/ESRGAN/4x-UltraSharp.pth" \
        "$MODELS/upscale_models/4x-UltraSharp.pth"

    # SAM
    dl_pub "https://dl.fbaipublicfiles.com/segment_anything/sam_vit_b_01ec64.pth" \
        "$MODELS/sams/sam_vit_b_01ec64.pth"

    # Impact Pack detection models — explicit download (not relying on auto-download)
    dl_pub "https://huggingface.co/Bingsu/adetailer/resolve/main/face_yolov8m.pt" \
        "$MODELS/ultralytics/bbox/face_yolov8m.pt"
    dl_pub "https://huggingface.co/Bingsu/adetailer/resolve/main/hand_yolov8s.pt" \
        "$MODELS/ultralytics/bbox/hand_yolov8s.pt"
    dl_pub "https://huggingface.co/Bingsu/adetailer/resolve/main/person_yolov8m-seg.pt" \
        "$MODELS/ultralytics/segm/person_yolov8m-seg.pt"
}
