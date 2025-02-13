# Docker aliases
alias d='docker'
alias dc='docker compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dv='docker volume'
alias dn='docker network'

# Docker containers
alias dstart='docker start'
alias dstop='docker stop'
alias drestart='docker restart'
alias drm='docker rm'
alias drmi='docker rmi'
alias dlogs='docker logs'
alias dexec='docker exec -it'

# Docker Compose
alias dcu='docker compose up'
alias dcud='docker compose up -d'
alias dcd='docker compose down'
alias dcr='docker compose restart'
alias dcps='docker compose ps'
alias dclogs='docker compose logs'

# Docker cleanup functions
function dprune() {
    echo "Removing all stopped containers..."
    docker container prune -f
    echo "Removing all unused images..."
    docker image prune -f
    echo "Removing all unused volumes..."
    docker volume prune -f
    echo "Removing all unused networks..."
    docker network prune -f
}

# Enter container shell
function dsh() {
    if [ -z "$1" ]; then
        echo "Please provide a container name or ID"
        return 1
    fi
    docker exec -it "$1" sh -c "if command -v bash >/dev/null 2>&1; then bash; else sh; fi"
}

# Show container IP
function dip() {
    docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$1"
}

# Show container logs with timestamps
function dlogt() {
    docker logs -f --timestamps "$1"
}

# Stop all running containers
function dstopall() {
    docker stop $(docker ps -q)
}

# Remove all containers
function drmall() {
    docker rm $(docker ps -a -q)
}