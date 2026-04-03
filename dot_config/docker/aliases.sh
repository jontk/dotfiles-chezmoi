# shellcheck shell=bash
# Docker aliases and functions
# Source this file in your shell configuration

# Docker aliases
alias d='docker'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dlog='docker logs'
alias dlogf='docker logs -f'
alias drm='docker rm'
alias drmi='docker rmi'
alias dstop='docker stop'
alias dstart='docker start'
alias drestart='docker restart'
alias dpull='docker pull'
alias dpush='docker push'
alias dbuild='docker build'
alias dtag='docker tag'
alias drun='docker run'
alias drunit='docker run -it --rm'
alias dcp='docker cp'
alias dinspect='docker inspect'
alias dstats='docker stats'
alias dtop='docker top'
alias dport='docker port'
alias dnetwork='docker network'
alias dvolume='docker volume'
alias dsystem='docker system'
alias dprune='docker system prune -a'
alias ddf='docker system df'
alias dinfo='docker info'
alias dversion='docker version'

# Docker Compose aliases (if using v2)
alias dc='docker compose'
alias dcup='docker compose up'
alias dcupd='docker compose up -d'
alias dcdown='docker compose down'
alias dcdownv='docker compose down -v'
alias dcps='docker compose ps'
alias dclogs='docker compose logs'
alias dclogsf='docker compose logs -f'
alias dcexec='docker compose exec'
alias dcbuild='docker compose build'
alias dcpull='docker compose pull'
alias dcrestart='docker compose restart'
alias dcstop='docker compose stop'
alias dcstart='docker compose start'

# Docker run helpers
alias dalpine='docker run -it --rm alpine:latest sh'
alias dubuntu='docker run -it --rm ubuntu:latest bash'
alias ddebian='docker run -it --rm debian:latest bash'
alias dcentos='docker run -it --rm centos:latest bash'
alias dbusybox='docker run -it --rm busybox:latest sh'

# Functions

# Remove all stopped containers
dclean() {
    echo "Removing stopped containers..."
    docker container prune -f
}

# Remove all unused images
diclean() {
    echo "Removing unused images..."
    docker image prune -a -f
}

# Remove all unused volumes
dvclean() {
    echo "Removing unused volumes..."
    docker volume prune -f
}

# Clean everything
dcleanall() {
    echo "WARNING: This will delete ALL unused Docker resources including volumes!"
    read -p "Are you sure? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Cleaning all Docker resources..."
        docker system prune -a --volumes -f
    else
        echo "Cancelled."
    fi
}

# Get container IP address
dip() {
    local container="${1}"
    if [[ -z "$container" ]]; then
        echo "Usage: dip <container_name_or_id>"
        return 1
    fi
    docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$container"
}

# Enter a running container
denter() {
    local container="${1}"
    local shell="${2:-/bin/bash}"
    
    if [[ -z "$container" ]]; then
        echo "Usage: denter <container_name_or_id> [shell]"
        return 1
    fi
    
    docker exec -it "$container" "$shell" || docker exec -it "$container" /bin/sh
}

# Show container environment variables
denv() {
    local container="${1}"
    if [[ -z "$container" ]]; then
        echo "Usage: denv <container_name_or_id>"
        return 1
    fi
    docker exec "$container" env | sort
}

# Follow logs for multiple containers
dmultilogs() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: dmultilogs <container1> <container2> ..."
        return 1
    fi
    
    local containers=("$@")
    local pids=()
    
    # Start following logs for each container in background
    for container in "${containers[@]}"; do
        docker logs -f "$container" 2>&1 | sed "s/^/[$container] /" &
        pids+=($!)
    done
    
    # Wait for Ctrl+C
    trap 'kill ${pids[*]}' INT
    wait
}

# Docker build with automatic tag
dbuildtag() {
    local tag="${1}"
    local context="${2:-.}"
    
    if [[ -z "$tag" ]]; then
        echo "Usage: dbuildtag <tag> [context]"
        return 1
    fi
    
    docker build -t "$tag" "$context"
}

# Run a temporary container with current directory mounted
drunhere() {
    local image="${1:-alpine}"
    local cmd="${2:-sh}"
    
    docker run -it --rm -v "$(pwd)":/workspace -w /workspace "$image" "$cmd"
}

# Show docker disk usage in a nice format
ddisk() {
    echo "Docker Disk Usage:"
    echo "=================="
    docker system df
    echo
    echo "Top 10 Images by Size:"
    docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" | head -n 11
}

# Stop all running containers
dstopall() {
    local containers
    containers=$(docker ps -q)
    if [[ -n "$containers" ]]; then
        echo "Stopping all containers..."
        echo "$containers" | xargs docker stop
    else
        echo "No running containers"
    fi
}

# Remove all containers (including running)
drmall() {
    local containers
    containers=$(docker ps -aq)
    if [[ -n "$containers" ]]; then
        echo "WARNING: This will force remove ALL containers (including running ones)!"
        read -p "Are you sure? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Removing all containers..."
            echo "$containers" | xargs docker rm -f
        else
            echo "Cancelled."
        fi
    else
        echo "No containers to remove"
    fi
}

# Remove all images
drmiall() {
    local images
    images=$(docker images -q)
    if [[ -n "$images" ]]; then
        echo "WARNING: This will force remove ALL Docker images!"
        read -p "Are you sure? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Removing all images..."
            echo "$images" | xargs docker rmi -f
        else
            echo "Cancelled."
        fi
    else
        echo "No images to remove"
    fi
}

# Docker stats with better formatting
dstatsf() {
    docker stats --format "table {{.Container}}\t{{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"
}

# Search Docker Hub
dhubsearch() {
    local term="${1}"
    if [[ -z "$term" ]]; then
        echo "Usage: dhubsearch <search_term>"
        return 1
    fi
    docker search "$term" --format "table {{.Name}}\t{{.Description}}\t{{.Stars}}\t{{.Official}}"
}

# Show container resource limits
dlimits() {
    local container="${1}"
    if [[ -z "$container" ]]; then
        echo "Usage: dlimits <container_name_or_id>"
        return 1
    fi
    
    echo "Resource Limits for $container:"
    docker inspect "$container" | jq '.[0] | {
        Memory: .HostConfig.Memory,
        MemorySwap: .HostConfig.MemorySwap,
        CpuShares: .HostConfig.CpuShares,
        CpuQuota: .HostConfig.CpuQuota,
        CpuPeriod: .HostConfig.CpuPeriod,
        CpusetCpus: .HostConfig.CpusetCpus
    }'
}

# Export/Import functions
dexport() {
    local container="${1}"
    local filename="${2}"
    
    if [[ -z "$container" ]] || [[ -z "$filename" ]]; then
        echo "Usage: dexport <container_name_or_id> <output_file.tar>"
        return 1
    fi
    
    docker export "$container" > "$filename"
    echo "Container exported to $filename"
}

dimport() {
    local filename="${1}"
    local image="${2}"
    
    if [[ -z "$filename" ]] || [[ -z "$image" ]]; then
        echo "Usage: dimport <input_file.tar> <image_name:tag>"
        return 1
    fi
    
    docker import "$filename" "$image"
}

# Save/Load image functions
dsave() {
    local image="${1}"
    local filename="${2:-${image//[\/:]/_}.tar}"
    
    if [[ -z "$image" ]]; then
        echo "Usage: dsave <image_name:tag> [output_file.tar]"
        return 1
    fi
    
    docker save "$image" > "$filename"
    echo "Image saved to $filename"
}

dload() {
    local filename="${1}"
    
    if [[ -z "$filename" ]]; then
        echo "Usage: dload <input_file.tar>"
        return 1
    fi
    
    docker load < "$filename"
}

# Docker layer visualization
dlayers() {
    local image="${1}"
    if [[ -z "$image" ]]; then
        echo "Usage: dlayers <image_name:tag>"
        return 1
    fi
    
    docker history --no-trunc "$image" | \
        awk '{
            if (NR==1) {
                printf "%-12s %-20s %10s  %s\n", "IMAGE", "CREATED", "SIZE", "COMMAND"
                print "=================================================================================="
            } else {
                cmd = substr($0, index($0, $7))
                if (length(cmd) > 60) cmd = substr(cmd, 1, 57) "..."
                printf "%-12s %-20s %10s  %s\n", $1, $4" "$5" "$6, $NF, cmd
            }
        }'
}

# Docker health check
dhealthcheck() {
    local container="${1}"
    if [[ -z "$container" ]]; then
        echo "Usage: dhealthcheck <container_name_or_id>"
        return 1
    fi
    
    docker inspect "$container" --format='{{json .State.Health}}' | jq '.'
}

# Wait for container to be healthy
dwait() {
    local container="${1}"
    local timeout="${2:-30}"
    
    if [[ -z "$container" ]]; then
        echo "Usage: dwait <container_name_or_id> [timeout_seconds]"
        return 1
    fi
    
    echo "Waiting for $container to be healthy (timeout: ${timeout}s)..."
    
    local count=0
    while [[ $count -lt $timeout ]]; do
        local health
        health=$(docker inspect "$container" --format='{{.State.Health.Status}}' 2>/dev/null)
        if [[ "$health" == "healthy" ]]; then
            echo "Container $container is healthy!"
            return 0
        fi
        sleep 1
        ((count++))
        echo -ne "."
    done
    
    echo
    echo "Timeout waiting for $container to be healthy"
    return 1
}

# Show Docker info summary
dinfo-summary() {
    echo "Docker System Summary"
    echo "===================="
    docker version --format 'Server Version: {{.Server.Version}}'
    docker info --format 'Containers: {{.Containers}} (Running: {{.ContainersRunning}}, Stopped: {{.ContainersStopped}})'
    docker info --format 'Images: {{.Images}}'
    echo "Storage Driver: $(docker info --format '{{.Driver}}')"
    echo "Docker Root Dir: $(docker info --format '{{.DockerRootDir}}')"
    echo
    docker system df
}