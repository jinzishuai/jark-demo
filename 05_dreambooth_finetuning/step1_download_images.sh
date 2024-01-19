#!/bin/bash
# shellcheck disable=SC2086

set -xe

# Step 0
pushd dreambooth || true

# Step 0 cont
# __preparation_start__
# TODO: If running on multiple nodes, change this path to a shared directory (ex: NFS)
export DATA_PREFIX="/home/ray/efs/src/jark-demo/05_dreambooth_finetuning/data" # EFS is mounted at /home/ray/efs on all Ray nodes
# export ORIG_MODEL_NAME="CompVis/stable-diffusion-v1-4"
# export ORIG_MODEL_HASH="b95be7d6f134c3a9e62ee616f310733567f069ce" # Jul 5, 2023 https://huggingface.co/CompVis/stable-diffusion-v1-4/discussions/216
export ORIG_MODEL_NAME="stabilityai/stable-diffusion-2-1"
export ORIG_MODEL_HASH="5cae40e6a2745ae2b01ad92ae5043f95f23644d6" # July 5, 2023
export ORIG_MODEL_DIR="$DATA_PREFIX/model-orig"
export ORIG_MODEL_PATH="$ORIG_MODEL_DIR/models--${ORIG_MODEL_NAME/\//--}/snapshots/$ORIG_MODEL_HASH"
export TUNED_MODEL_DIR="$DATA_PREFIX/model-tuned"
export IMAGES_REG_DIR="$DATA_PREFIX/images-reg"
export IMAGES_OWN_DIR="$DATA_PREFIX/images-own"
export IMAGES_NEW_DIR="$DATA_PREFIX/images-new"
# TODO: Add more worker nodes and increase NUM_WORKERS for more data-parallelism
export NUM_WORKERS=1

# mkdir -p $ORIG_MODEL_DIR $TUNED_MODEL_DIR $IMAGES_REG_DIR $IMAGES_OWN_DIR $IMAGES_NEW_DIR
for ray_dir in $ORIG_MODEL_DIR $TUNED_MODEL_DIR $IMAGES_REG_DIR $IMAGES_OWN_DIR $IMAGES_NEW_DIR
do
    jovyan_dir=$(echo ${ray_dir} | sed 's/ray/jovyan/')
    mkdir -p ${jovyan_dir} #create the folder on the Juyper notebook
done


# Unique token to identify our subject (e.g., a random dog vs. our unqtkn dog)
export UNIQUE_TOKEN="[v]"

# Step 1
# __cache_model_start__
# python cache_model.py --model_dir=$ORIG_MODEL_DIR --model_name=$ORIG_MODEL_NAME --revision=$ORIG_MODEL_HASH
ORIG_MODEL_DIR_JOVYAN=$(echo $ORIG_MODEL_DIR | sed 's/ray/jovyan/')
python cache_model.py --model_dir=$ORIG_MODEL_DIR_JOVYAN --model_name=$ORIG_MODEL_NAME --revision=$ORIG_MODEL_HASH
# __cache_model_end__


# Step 2
# __supply_own_images_start__
# Only uncomment one of the following:

# Option 1: Use the dog dataset ---------
export CLASS_NAME="dog"
python download_example_dataset.py ./images/dog
export INSTANCE_DIR=./images/dog
# ---------------------------------------

# Option 2: Use the lego car dataset ----
# export CLASS_NAME="car"
# export INSTANCE_DIR=./images/lego-car
# ---------------------------------------

# Option 3: Use your own images ---------
# export CLASS_NAME="<class-of-your-subject>"
# export INSTANCE_DIR="/path/to/images/of/subject"
# ---------------------------------------

# Copy own images into IMAGES_OWN_DIR
IMAGES_OWN_DIR_JOVYAN=$(echo $IMAGES_OWN_DIR | sed 's/ray/jovyan/')
cp -rf $INSTANCE_DIR/* "$IMAGES_OWN_DIR_JOVYAN/"
# __supply_own_images_end__

# Clear reg dir
rm -rf "$IMAGES_REG_DIR"/*.jpg

# Step 3: START
ray job submit -- python  ${PROJECT_ROOT}/dreambooth/generate.py \
--model_dir=$ORIG_MODEL_PATH \
--output_dir=$IMAGES_REG_DIR \
--prompts="photo of a $CLASS_NAME" \
--num_samples_per_prompt=200 \
--use_ray_data
# Step 3: END




# Exit
popd || true
