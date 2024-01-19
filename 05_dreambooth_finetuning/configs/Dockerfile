# Run `docker build` with this from the 05_dreambooth_finetuning directory
FROM rayproject/ray-ml:2.9.0-py310-gpu

ENV DEBIAN_FRONTEND=noninteractive
# RUN sudo rm -f /var/lib/apt/lists/lock
RUN sudo apt update 
RUN sudo apt install -y vim psmisc

COPY ./requirements.txt ./
ADD dreambooth/requirements.txt ./dreambooth/requirements.txt

RUN pip uninstall -y mlflow
RUN pip install --no-cache-dir -U -r requirements.txt

RUN echo "Testing Ray Import..." && python -c "import ray"
RUN ray --version
RUN python --version
