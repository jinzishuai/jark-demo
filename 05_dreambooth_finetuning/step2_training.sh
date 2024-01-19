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



# Option 1: Use the dog dataset ---------
export CLASS_NAME="dog"
export INSTANCE_DIR=./images/dog
# ---------------------------------------

 

# Skip step 2 and 3 if skip_image_setup=true

if $skip_image_setup; then
  echo "Skipping image downloading..."
else
  download_image
fi

if [ "$use_lora" = false ]; then
  echo "Start full-finetuning..."
  # Step 4: START
  ray job submit -- python $(pwd)/train.py \
    --model_dir=$ORIG_MODEL_PATH \
    --output_dir=$TUNED_MODEL_DIR \
    --instance_images_dir=$IMAGES_OWN_DIR \
    --instance_prompt="photo of $UNIQUE_TOKEN $CLASS_NAME" \
    --class_images_dir=$IMAGES_REG_DIR \
    --class_prompt="photo of a $CLASS_NAME" \
    --train_batch_size=2 \
    --lr=5e-6 \
    --num_epochs=4 \
    --max_train_steps=200 \
    --num_workers $NUM_WORKERS
  # Step 4: END
else
  echo "Start LoRA finetuning..."
  ray job submit -- python $(pwd)/train.py \
  --use_lora \
  --model_dir=$ORIG_MODEL_PATH \
  --output_dir=$TUNED_MODEL_DIR \
  --instance_images_dir=$IMAGES_OWN_DIR \
  --instance_prompt="photo of $UNIQUE_TOKEN $CLASS_NAME" \
  --class_images_dir=$IMAGES_REG_DIR \
  --class_prompt="photo of a $CLASS_NAME" \
  --train_batch_size=2 \
  --lr=1e-4 \
  --num_epochs=4 \
  --max_train_steps=200 \
  --num_workers $NUM_WORKERS
fi

# Exit
popd || true
