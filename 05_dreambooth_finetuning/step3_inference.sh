#!/bin/bash
# shellcheck disable=SC2086

set -xe

# Step 0
pushd dreambooth || true

# Step 0 cont
# __preparation_start__
# TODO: If running on multiple nodes, change this path to a shared directory (ex: NFS)
export DATA_PREFIX="/data/tmp"
export ORIG_MODEL_NAME="CompVis/stable-diffusion-v1-4"
export ORIG_MODEL_HASH="b95be7d6f134c3a9e62ee616f310733567f069ce"
export ORIG_MODEL_DIR="$DATA_PREFIX/model-orig"
export ORIG_MODEL_PATH="$ORIG_MODEL_DIR/models--${ORIG_MODEL_NAME/\//--}/snapshots/$ORIG_MODEL_HASH"
export TUNED_MODEL_DIR="$DATA_PREFIX/model-tuned"
export IMAGES_REG_DIR="$DATA_PREFIX/images-reg"
export IMAGES_OWN_DIR="$DATA_PREFIX/images-own"
export IMAGES_NEW_DIR="$DATA_PREFIX/images-new"
# TODO: Add more worker nodes and increase NUM_WORKERS for more data-parallelism
export NUM_WORKERS=4

mkdir -p $ORIG_MODEL_DIR $TUNED_MODEL_DIR $IMAGES_REG_DIR $IMAGES_OWN_DIR $IMAGES_NEW_DIR
# __preparation_end__

# Unique token to identify our subject (e.g., a random dog vs. our unqtkn dog)
export UNIQUE_TOKEN="unqtkn"

skip_image_setup=true
use_lora=false
# parse args
for arg in "$@"; do
  case $arg in
    --skip_image_setup)
      echo "Option --skip_image_setup is set"
      skip_image_setup=true
      ;;
    --lora)
      echo "Option --lora is set"
      use_lora=true
      ;;
    *)
      echo "Invalid option: $arg"
      ;;
  esac
done


export CLASS_NAME="dog"
export INSTANCE_DIR=./images/dog



# Clear new dir
rm -rf "$IMAGES_NEW_DIR"/*.jpg

if [ "$use_lora" = false ]; then
  # Step 5: START
  ray job submit -- python $(pwd)/generate.py \
    --model_dir=$TUNED_MODEL_DIR \
    --output_dir=$IMAGES_NEW_DIR \
    --prompts="photo of a $UNIQUE_TOKEN $CLASS_NAME in a bucket" \
    --num_samples_per_prompt=5
  # Step 5: END
else
  python generate.py \
  --model_dir=$ORIG_MODEL_PATH \
  --lora_weights_dir=$TUNED_MODEL_DIR \
  --output_dir=$IMAGES_NEW_DIR \
  --prompts="photo of a $UNIQUE_TOKEN $CLASS_NAME in a bucket" \
  --num_samples_per_prompt=5
fi

# Save artifact
mkdir -p /data/tmp/artifacts
cp -f "$IMAGES_NEW_DIR"/0-*.jpg /data/tmp/artifacts/example_out.jpg

# Exit
popd || true
