#!/bin/bash

##### SET FOLLOWING VARS #####
SERVER_ADDR="0.0.0.0"
SERVER_PORT=7870
CLONE_DIR="Mangio-RVC-v23.7.0"
CONDA_DIR="/home/$USER/src/miniconda3"
###### END OF VARIABLES ######



# source base conda env in this script's subshell
# https://github.com/conda/conda/issues/7980
source $CONDA_DIR/etc/profile.d/conda.sh

# set working dir to this script's location:
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CONDA_ENV_DIR="$SCRIPT_DIR/conda_env"

available() { command -v $1 >/dev/null; }

cd $SCRIPT_DIR

# check if miniconda already installed
if ! available conda; then
    echo "miniconda is not yet installed. Install it first."
    exit 0
fi

# check if conda env already exists, create if not yet done
if [ ! -d "$CONDA_ENV_DIR" ]; then
    conda create --no-shortcuts -y -k --prefix "$CONDA_ENV_DIR" python=3.9
    $CONDA_ENV_DIR/bin/python -m pip install pip==23.2.1
fi

# confirm if conda env is actually created
if [ ! -f "$CONDA_ENV_DIR/bin/python" ]; then
    echo "python is not found in $CONDA_ENV_DIR/bin"
    echo "exiting."
    exit 0
fi

# activate conda env
conda activate $CONDA_ENV_DIR || echo "Miniconda hook not found."

# check if install dir already exists
if [ ! -d "$CLONE_DIR" ]; then
    echo "Downloading Mangio-RVC-Fork package..."
    echo ""
    wget --inet4-only https://huggingface.co/MangioRVC/Mangio-RVC-Huggingface/resolve/main/Mangio-RVC-v23.7.0_INFER_TRAIN.7z
    7z x Mangio-RVC-v23.7.0_INFER_TRAIN.7z
    rm -vf Mangio-RVC-v23.7.0_INFER_TRAIN.7z
    cd $CLONE_DIR 
    pip install -r requirements.txt
fi

cd $CLONE_DIR
$CONDA_ENV_DIR/bin/python infer-web.py --pycmd python --port $SERVER_PORT
