#!/usr/bin/env bash
# OFM I2V Gen3 — Dasiwa Wan 2.2 Image-to-Video
# GPU: 24GB+ | Models: ~30GB | Time: ~90 min
# Source: 8.Команды JupyterTerminal.txt

models_ofm_i2v_gen3() {
    section "Models: I2V Gen3 (Dasiwa Wan 2.2)"

    # VAE + text encoder
    dl_hf "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors" \
        "$MODELS/vae/wan_2.1_vae.safetensors"
    dl_hf "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors" \
        "$MODELS/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors"

    # Dasiwa models (Low + High noise variants)
    dl_hf "https://huggingface.co/m33nt0r/DASIWA/resolve/main/DasiwaWAN22I2V14BLightspeed_synthseductionLowV9.safetensors" \
        "$MODELS/unet/DasiwaWAN22I2V14BLightspeed_synthseductionLowV9.safetensors"
    dl_hf "https://huggingface.co/m33nt0r/DASIWA/resolve/main/DasiwaWAN22I2V14BLightspeed_synthseductionHighV9.safetensors" \
        "$MODELS/unet/DasiwaWAN22I2V14BLightspeed_synthseductionHighV9.safetensors"

    # Upscaler
    dl_pub "https://huggingface.co/ai-forever/RealESRGAN/resolve/main/RealESRGAN_x2.pth" \
        "$MODELS/upscale_models/RealESRGAN_x2.pth"

    # LoRAs
    dl_hf "https://huggingface.co/m33nt0r/DASIWA/resolve/main/WAN-2.2-I2V-BreastPlay-HIGH-v2.safetensors" \
        "$MODELS/loras/WAN-2.2-I2V-BreastPlay-HIGH-v2.safetensors"
    dl_hf "https://huggingface.co/m33nt0r/DASIWA/resolve/main/wan22_i2v_shake_high_v2.safetensors" \
        "$MODELS/loras/wan22_i2v_shake_high_v2.safetensors"
}
