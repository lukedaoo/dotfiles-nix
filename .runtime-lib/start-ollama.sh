docker run -d -v $HOME/.ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama

docker run -d -p 5002:8080 --gpus all --add-host=host.docker.internal:host-gateway \
    -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:cuda
