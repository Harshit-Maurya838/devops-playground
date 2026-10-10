# Mission 04: Port Bandit (Process Management)

## Story
Our engineering team is trying to launch a new API gateway, but the deployment crashes immediately with:
`Error: listen EADDRINUSE: address already in use 0.0.0.0:8080`.

A rogue background process called `port_bandit` has hijacked TCP port 8080. It runs silently in the background and stubbornly refuses standard graceful shutdowns.

Your mission is to find the rogue process holding port 8080, identify its Process ID (PID), terminate it using the appropriate signal, and verify port 8080 is free for the new gateway.

---

## Learning Objectives
In this mission, you will learn to:
- Inspect active socket connections and listening ports with `ss -tulpn` or `lsof -i :<port>`.
- List running processes with `ps aux` and `pgrep`.
- Monitor system activity interactively with `top`.
- Understand POSIX process termination signals (`SIGTERM` vs `SIGKILL`).
- Terminate unresponsive processes with `kill -9 <PID>` or `pkill`.

---

## Instructions
1. Move to the mission directory:
   ```bash
   cd /home/player/mission-04
   ```
2. Identify the process listening on port 8080 using `ss` or `lsof`.
3. Locate the Process ID (PID) of `port_bandit`.
4. Terminate the process (hint: `port_bandit` traps `SIGTERM`, so you will need `SIGKILL` / signal `9`).
5. Run the new gateway startup script to confirm port 8080 is free:
   ```bash
   ./start_gateway.sh
   ```
6. Run the mission check:
   ```bash
   ./play.sh check
   ```

---

## Progressive Hints

### Hint 1: Locating What Is Holding Port 8080
Use network socket inspection tools to find which process owns port 8080:
```bash
ss -tulpn | grep 8080
# Or using lsof:
lsof -i :8080
```
Look at the output columns for the PID (Process ID).

### Hint 2: Inspecting the Process with `ps`
You can also view the full command-line and user for the process with:
```bash
ps aux | grep port_bandit
```
The second column in `ps aux` output is the PID.

### Hint 3: Sending Termination Signals
If you run `kill <PID>`, `port_bandit` will ignore it because it handles standard `SIGTERM` (signal 15). To forcefully terminate an unresponsive process, send `SIGKILL` (signal 9), which the Linux kernel executes immediately:
```bash
kill -9 <PID>
# Or by process name:
pkill -9 -f port_bandit
```
Once killed, execute `./start_gateway.sh` to confirm the gateway can bind to port 8080.
