# Level 0: Linux & The Terminal

> *"Every journey in DevOps begins where the cloud touches the metal: the Linux command line."*

Welcome to **Level 0** of **DevOps Playground**. This level transforms the intimidating black screen of the Linux terminal into an interactive, game-like arena where you solve real infrastructure incidents using standard shell tooling.

---

## 🎯 Level Goals & Overview
By completing Level 0, you will master the foundational skills every DevOps and Cloud Engineer relies on daily:
1. **Filesystem Navigation**: Navigate deep directories, uncover hidden files (dotfiles), and locate assets with `find`.
2. **Permissions & Security**: Master POSIX read/write/execute permissions, numeric modes (`600`, `755`), ownership, and file lockdown.
3. **Log & Text Sleuthing**: Filter, count, slice, and deduplicate mountains of real-world server logs using the Unix pipeline (`grep`, `awk`, `cut`, `sort`, `uniq`, `wc`).
4. **Process & Port Management**: Track background processes, identify socket collisions (`ss`, `lsof`), and terminate stuck daemons with signals (`SIGTERM` vs `SIGKILL`).
5. **Remote Access & SSH**: Generate cryptographic keypairs (`ssh-keygen`), configure passwordless public-key authentication (`authorized_keys`), and transfer files across servers (`scp`).
6. **Service Management**: Inspect service states (`systemctl status`), examine log streams (`journalctl -u`), and troubleshoot systemd service unit configurations.
7. **Boss Fight — The Hydra Protocol**: Unmask and eradicate a multi-tier CPU-eating process tree, terminate rogue process hierarchies, and neutralize crontab persistence.

---

## 🏆 XP Progression Table

| Mission | Name | Key Concepts | XP Award | Total XP |
| :--- | :--- | :--- | :--- | :--- |
| **01** | The Lost Artifact | `pwd`, `ls -la`, `cd`, `find`, `cat`, `>` | 50 XP | 50 XP |
| **02** | The Lockdown Incident | `chmod`, `chown`, `rwx`, octal `600`/`755` | 50 XP | 100 XP |
| **03** | Log Sleuth | `grep`, `head`, `tail`, `wc`, `|`, `sort`, `uniq` | 50 XP | 150 XP |
| **04** | Port Bandit | `ps aux`, `top`, `ss -tulpn`, `lsof`, `kill -9` | 50 XP | 200 XP |
| **05** | The Bastion Gateway | `ssh-keygen`, `ssh-copy-id`, `ssh`, `scp` | 50 XP | 250 XP |
| **06** | Service Doctor | `systemctl`, `journalctl`, systemd unit files | 50 XP | 300 XP |
| **BOSS** | The Hydra Protocol | `ps --forest`, `pstree`, `pkill`, `cron`, PGID | 150 XP | **450 XP** |

---

## 🚀 How to Start Playing

### Prerequisites
- [Docker](https://docs.docker.com/get-docker/) & [Docker Compose](https://docs.docker.com/compose/) installed on your machine.

### Step 1: Start the Sandbox
From the `levels/level-0-linux/` directory, spin up the sandboxed environment:
```bash
docker compose up -d --build
```
This launches two isolated containers on a private bridge network:
- `devops-sandbox`: Your playground terminal running Ubuntu as non-root user `player`.
- `target-server`: A simulated remote staging host running SSH.

### Step 2: Enter the Player Shell
Attach your terminal into the sandbox:
```bash
docker compose exec -u player sandbox bash
```
*(Alternatively, you can run `./play.sh shell` from your host).*

### Step 3: Run the Game CLI
Inside the container, run the global `play` command from any directory:
```bash
play
```
*(You can also use `./play.sh` from `/game`, but `play` is globally accessible anywhere!)*

This displays your mission dashboard, current XP, and available tasks!

```bash
# Start your first mission:
play start 01

# Review mission intel & instructions at any time (from any folder):
play briefing

# Test your solution when you think you've solved it (runs from anywhere):
play check

# If you get stuck, unlock progressive hints without spoilers:
play hint

# Need to start fresh? Reset the mission:
play reset
```

---

## ⚙️ Architectural Decisions: Service Management in Docker

A common challenge when teaching DevOps inside Docker is **Systemd**.

### The Challenge with Native Systemd in Docker
In standard Linux systems, `systemd` runs as **PID 1** (the initial boot process). However, running real `systemd` inside Docker requires:
1. Running containers in `--privileged` mode or mounting host `/sys/fs/cgroup`.
2. Mounting tmpfs filesystems on `/run` and `/run/lock`.
3. Overriding the container's entrypoint with `/sbin/init` or `/lib/systemd/systemd`.

This creates major drawbacks for an open-source educational repo:
- **Security risk**: `--privileged` containers grant root capabilities to the host kernel.
- **Portability issues**: Fails unpredictably on macOS and Windows hosts running Docker Desktop or WSL2 with cgroup v1/v2 mismatches.
- **Poor UX**: If PID 1 is `/sbin/init`, learners cannot easily run `docker run -it` without complex multi-terminal exec sessions.

### The Solution: Drop-in Systemctl & Journalctl Controller
In Level 0, we provide a clean, dedicated service controller (`scripts/service_manager.py`) installed at `/usr/local/bin/systemctl` and `/usr/local/bin/journalctl`.

- **Identical CLI Experience**: Learners run the real commands: `systemctl status <unit>`, `systemctl restart <unit>`, `systemctl is-active <unit>`, and `journalctl -u <unit> -n 20`.
- **Authentic Systemd Unit Files**: Reads standard `/etc/systemd/system/*.service` files (`[Unit]`, `[Service]`, `ExecStart`, `EnvironmentFile`, `Restart`).
- **Real-Time Journal Logs**: Captures application stdout/stderr streams with formatted timestamps and color-coded statuses.
- **Zero Host Privileges**: Completely safe, runs 100% in user space, and launches instantly on any OS or Docker version.

---

## 📁 Repository Structure
```text
levels/level-0-linux/
├── README.md               # You are here!
├── Dockerfile              # Sandbox Ubuntu image with tools & player user
├── docker-compose.yml      # Starts sandbox & ssh-target services
├── play.sh                 # Interactive CLI game engine
├── progress.json           # Local progress and XP tracker
├── TESTING.md              # Automated & manual test verification guide
├── scripts/
│   └── service_manager.py  # Drop-in systemctl & journalctl service runner
└── missions/
    ├── 01-navigate/        # Directory navigation & find
    ├── 02-permissions/     # File permissions & chmod lockdown
    ├── 03-text-detective/  # Log stream parsing & Unix pipes
    ├── 04-processes/       # Socket/port inspection & signal killing
    ├── 05-ssh/             # SSH keypair generation, auth & scp
    ├── 06-services/        # Service failure diagnosis & unit configs
    └── boss-cpu-hog/       # Boss fight: process hierarchy & cron persistence
```

Each mission folder strictly follows the contract:
- `mission.md`: Story narrative, learning objectives, instructions, and 3 progressive hints.
- `setup.sh`: Idempotent script that provisions the starting/broken state.
- `check.sh`: Verifies the actual system state, exiting `0` on success and non-zero on failure.
- `solution.md`: Complete explanation and walkthrough, guarded by a spoiler alert.
