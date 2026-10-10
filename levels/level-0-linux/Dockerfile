# ==============================================================================
# DevOps Playground - Level 0: Linux & The Terminal Sandbox
# Base Dockerfile: Ubuntu 22.04 LTS
# ==============================================================================

FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install essential command-line tools for Level 0 missions
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Core utilities
    bash \
    coreutils \
    findutils \
    grep \
    sed \
    gawk \
    tar \
    gzip \
    tree \
    file \
    # Process and system inspection
    procps \
    psmisc \
    htop \
    lsof \
    # Networking and ports
    iproute2 \
    net-tools \
    socat \
    curl \
    # SSH tools
    openssh-client \
    openssh-server \
    sshpass \
    # Editors and conveniences
    nano \
    vim \
    less \
    jq \
    sudo \
    cron \
    ca-certificates \
    # Python for lightweight daemons & test utilities
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Create non-root player user with sudo privileges
RUN groupadd -g 1000 player && \
    useradd -u 1000 -g player -m -s /bin/bash player && \
    echo "player ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Copy game files to template location and default /game
COPY --chown=player:player . /opt/game_template
COPY --chown=player:player . /game

# Ensure permissions
RUN chown -R player:player /game /opt/game_template

# Create entrypoint script to populate /game if mounted from an unshared host path
RUN echo '#!/usr/bin/env bash\n\
set -e\n\
if [ ! -f /game/play.sh ]; then\n\
    cp -a /opt/game_template/. /game/\n\
fi\n\
chown -R player:player /game 2>/dev/null || true\n\
chown -R player:player /home/player 2>/dev/null || true\n\
exec "$@"\n' > /usr/local/bin/entrypoint.sh && chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /game
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["sleep", "infinity"]
