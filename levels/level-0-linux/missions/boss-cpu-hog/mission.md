# Boss Fight: The Hydra Protocol (CPU Hog)

## Story
🚨 **RED ALERT!** An unauthorized cryptographic process tree—code-named **The Hydra**—has infected our container.

Our system metrics show severe CPU contention: multiple rogue worker processes (`hydra-worker`) are pegging processor cores. When our automated monitors kill one worker, the parent watchdog (`hydra-watchdog`) immediately spawns another. Even if you kill the watchdog, a persistent cron mechanism restarts the entire infection!

You must use your terminal diagnostic mastery to:
1. Locate the runaway processes and measure their CPU load.
2. Trace the parent-child process relationship to find the root controller.
3. Terminate the entire process family (`kill`/`pkill`).
4. Neutralize the persistence mechanism so the Hydra cannot resurrect.
5. Prove the system is restored to normal.

Defeat the Hydra to earn **150 XP** and conquer Level 0!

---

## Learning Objectives
In this boss fight, you will synthesize everything you've learned:
- Find high-CPU consumers using `top` and `ps aux --sort=-%cpu`.
- Visualize process hierarchies with `ps -ef --forest` or `pstree -p`.
- Understand parent processes (PPID), child processes (PID), and process groups (PGID).
- Terminate process trees using `pkill -9` or signals to process group IDs (`kill -- -PGID`).
- Inspect and remove automated persistence jobs in `/etc/cron.d/` and `crontab`.

---

## Instructions
1. Run `top` or `ps aux --sort=-%cpu | head -n 10` to observe the CPU consumption and identify the rogue processes.
2. Run `ps -ef --forest | grep hydra` or `pstree -p` to map out the parent watchdog and its child workers.
3. Observe what happens if you kill a single worker PID—watch how the parent resurrects it!
4. Kill all Hydra processes simultaneously (`pkill -9 -f hydra`).
5. Inspect `/etc/cron.d/` to find and eliminate the persistence trigger: `/etc/cron.d/hydra-respawn`.
6. Run the mission check:
   ```bash
   ./play.sh check
   ```

---

## Progressive Hints

### Hint 1: Viewing the CPU Consumers
Run:
```bash
top
```
*(Press `q` to quit).*
Alternatively, sort all running processes by CPU usage without entering interactive mode:
```bash
ps aux --sort=-%cpu | head -n 10
```
Notice multiple `hydra-worker` processes burning CPU cycles.

### Hint 2: Tracing the Process Hierarchy
To see who is spawning the workers, view the process tree:
```bash
ps -ef --forest
```
Notice `hydra-watchdog` is the parent process (PPID) of the `hydra-worker` children. Killing only a child causes `hydra-watchdog` to spawn a new replacement immediately!

### Hint 3: Killing the Tree & Removing Cron Persistence
1. Terminate all related processes at once using pattern matching:
   ```bash
   sudo pkill -9 -f hydra
   ```
2. Neutralize the auto-restart cron job:
   ```bash
   sudo rm -f /etc/cron.d/hydra-respawn
   ```
3. Verify with `pgrep -f hydra` that no processes remain!
