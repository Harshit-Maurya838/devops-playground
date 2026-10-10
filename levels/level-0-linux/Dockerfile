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
    top \
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

# Create standard working directories
WORKDIR /game

# Ensure ssh client directory exists with correct permissions
RUN mkdir -p /home/player/.ssh && \
    chown -R player:player /home/player/.ssh && \
    chmod 700 /home/player/.ssh

# Configure friendly shell prompt for learner
RUN echo 'export PS1="\[\033[01;32m\]player@devops-sandbox\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "' >> /home/player/.bashrc && \
    echo 'echo -e "\033[1;36mWelcome to DevOps Playground - Level 0!\033[0m Run \033[1;33m./play.sh\033[0m to view your active mission."' >> /home/player/.bashrc

# Ensure /game is accessible by player
RUN chown -R player:player /game

USER player
CMD ["/bin/bash"]
