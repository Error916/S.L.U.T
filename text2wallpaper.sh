#!/bin/bash

# Variables
DEEP_AI_TEXT_2_IMAGE_API_KEY="${DEEP_AI_TEXT_2_IMAGE_API_KEY:-quickstart-QUdJIGlzIGNvbWluZy4uLi4K}"
DEEP_AI_TORCH_SRGAN_API_KEY="${DEEP_AI_TORCH_SRGAN_API_KEY:-quickstart-QUdJIGlzIGNvbWluZy4uLi4K}"
DEEP_API_URL="https://api.deepai.org/api"
XWALLPAPER_OPTIONS="--zoom"
IMAGE_DIR="${IMAGE_DIR:-$HOME/.cache/text2wallpaper}"

# Check Dependencies
check_dependency() {
  command -v "$1" >/dev/null 2>&1 || { echo >&2 "$1 is required but not installed. Aborting."; exit 1; }
}
check_dependency curl
check_dependency jq
check_dependency xwallpaper

# Create image directory
mkdir -p "$IMAGE_DIR"

# Get text input using the selected prompt
USER_INPUT=$@

# Generate image with DeepAI API
RESPONSE=$(curl -s \
  -F "text=$USER_INPUT" \
  -F "grid_size=1" \
  -H "api-key:$DEEP_AI_TEXT_2_IMAGE_API_KEY" \
  "$DEEP_API_URL/text2img")
IMAGE_URL=$(echo "$RESPONSE" | jq -r .output_url)
if [ "$IMAGE_URL" == "null" ]; then
  echo "API Error: Could not generate image"
  exit 1
else
  echo "Generated Image $IMAGE_URL"
fi

# Upscale image with DeepAI API
RESPONSE=$(curl -s \
  -X POST \
  -H "api-key:$DEEP_AI_TORCH_SRGAN_API_KEY" \
  -H "content-type: multipart/form-data" \
  -F "image=$IMAGE_URL" \
  "$DEEP_API_URL/torch-srgan")
IMAGE_URL=$(echo "$RESPONSE" | jq -r .output_url)
if [ "$IMAGE_URL" == "null" ]; then
  echo "API Error: Could not upscale image"
  exit 1
else
  echo "Upscaled Image $IMAGE_URL"
fi

IMAGE_PATH="$IMAGE_DIR/$(date +%s).jpg"

# Download the image
curl -s "$IMAGE_URL" -o "$IMAGE_PATH"

# Set the wallpaper with xwallpaper
xwallpaper "$XWALLPAPER_OPTIONS" "$IMAGE_PATH"

