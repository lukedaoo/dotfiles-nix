docker run -d -p 5002:8080 \
    --gpus=all -v $HOME/.ollama:/root/.ollama \
    -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:ollama

