# Boss Fight: Solution Guide

> [!CAUTION]
> **SPOILER ALERT!** Only consult this solution if you have given the mission an honest try or want to review the underlying concepts.

---

## Step-by-Step Solution

1. **Observe CPU usage and identify the offenders**:
   ```bash
   top
   ```
   *(Or in batch mode)*:
   ```bash
   ps aux --sort=-%cpu | head -n 10
   ```
   *Notice several `hydra-worker.py` processes utilizing significant CPU cycles.*

2. **Map the process tree**:
   ```bash
   ps -ef --forest
   # Or using pstree:
   pstree -p | grep -B 2 -A 4 hydra
   ```
   *Notice the hierarchy:*
   ```text
   hydra-watchdog.sh (PID: 2841)
     ├── python3 /opt/hydra/hydra-worker.py (PID: 2850)
     ├── python3 /opt/hydra/hydra-worker.py (PID: 2851)
     └── python3 /opt/hydra/hydra-worker.py (PID: 2852)
   ```

3. **Check for persistence triggers (cron)**:
   ```bash
   ls -la /etc/cron.d/
   cat /etc/cron.d/hydra-respawn
   ```

4. **Disable the persistence cron trigger first**:
   ```bash
   sudo rm -f /etc/cron.d/hydra-respawn
   ```

5. **Kill the entire process hierarchy**:
   Using `pkill` with pattern matching and SIGKILL:
   ```bash
   sudo pkill -9 -f hydra
   ```
   *Alternatively, if killing by Process Group ID (PGID):*
   Find the watchdog's PGID with `ps -o pid,pgid,cmd -C hydra-watchdog.sh`, then kill the whole group:
   ```bash
   sudo kill -9 -- -<PGID>
   ```

6. **Confirm zero lingering processes**:
   ```bash
   pgrep -f hydra
   ```
   *(Returns nothing)*

7. **Verify victory**:
   ```bash
   ./play.sh check
   ```

---

## Why This Works (Under the Hood)
- **Supervisors and Watchdogs**: In distributed systems, supervisors monitor worker processes and restart them upon exit. Malicious scripts or rogue daemons can emulate this pattern to avoid simple single-process termination.
- **Process Trees & Groups (PGID)**: When a process forks children, they share a process group unless explicitly detached with `setpgid()`. Sending a signal to a negative PID (e.g. `-PGID`) signals every process in that process group simultaneously, preventing race conditions where parents spawn new children while you kill old ones.
- **Persistence Hooks**: Cron jobs located in `/etc/cron.d/` are polled once every minute by the cron daemon. Disabling the process tree without removing the scheduled cron allows the daemon to re-infect the system on the next minute boundary.
