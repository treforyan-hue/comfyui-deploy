#!/usr/bin/env bash
# OFM NSFW++ — INSTARAW photorealism pipeline
# GPU: 16GB+ | Models: ~30GB | Time: ~90 min
# Source: 10.Команды для JupyterTerminal.txt + universal install.sh

models_ofm_nsfw() {
    section "Models: NSFW++ (INSTARAW pipeline)"

    # Z-Image-Turbo base
    dl_hf "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/diffusion_models/z_image_turbo_bf16.safetensors" \
        "$MODELS/unet/z_image_turbo_bf16.safetensors"
    dl_hf "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/text_encoders/qwen_3_4b.safetensors" \
        "$MODELS/text_encoders/qwen_3_4b.safetensors"
    dl_pub "https://huggingface.co/camenduru/FLUX.1-dev-ungated/resolve/main/ae.safetensors" \
        "$MODELS/vae/ae.safetensors"

    # SDXL checkpoint (CivitAI)
    dl_civitai "2155386" "$MODELS/checkpoints/lustifySDXLNSFW_ggwpV7.safetensors"

    # ControlNet SDXL Union
    dl_hf "https://huggingface.co/xinsir/controlnet-union-sdxl-1.0/resolve/main/diffusion_pytorch_model_promax.safetensors" \
        "$MODELS/controlnet/controlnet-union-sdxl-promax.safetensors"

    # DMD2 LoRA
    dl_hf "https://huggingface.co/tianweiy/DMD2/resolve/main/dmd2_sdxl_4step_lora_fp16.safetensors" \
        "$MODELS/loras/dmd2_sdxl_4step_lora_fp16.safetensors"

    # Upscalers
    dl_pub "https://huggingface.co/Kim2091/UltraSharpV2/resolve/main/4x-UltraSharpV2.pth" \
        "$MODELS/upscale_models/4x-UltraSharpV2.pth"
    dl_pub "https://huggingface.co/uwg/upscaler/resolve/main/ESRGAN/1x-ITF-SkinDiffDetail-Lite-v1.pth" \
        "$MODELS/upscale_models/1x-ITF-SkinDiffDetail-Lite-v1.pth"
    dl_pub "https://huggingface.co/gemasai/4x_NMKD-Superscale-SP_178000_G/resolve/main/4x_NMKD-Superscale-SP_178000_G.pth" \
        "$MODELS/upscale_models/4x_NMKD-Superscale-SP_178000_G.pth"

    # Depth Anything V2
    dl_hf "https://huggingface.co/depth-anything/Depth-Anything-V2-Large/resolve/main/depth_anything_v2_vitl.pth" \
        "$MODELS/checkpoints/depth_anything_v2_vitl.pth"

    # SAM
    dl_pub "https://dl.fbaipublicfiles.com/segment_anything/sam_vit_b_01ec64.pth" \
        "$MODELS/sams/sam_vit_b_01ec64.pth"

    # CivitAI LoRA
    dl_civitai "368603" "$MODELS/loras/Detailed_Nipples_XL_v1.0.safetensors"
}
