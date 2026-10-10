# Mission 06: Service Doctor (systemd & journalctl)

## Story
A high-priority incident was just escalated to on-call! Our core backend service, `order-processor.service`, crashed and refuses to start. Customer orders are failing, and the deployment orchestrator marked the node as degraded.

Your mission is to inspect the service using Linux service management tools, inspect the logs, identify the root cause in the service configuration, fix the configuration, and bring the service back to an `active (running)` state.

---

## Learning Objectives
In this mission, you will learn to:
- Check service health and state with `systemctl status <service>`.
- Start, stop, and restart services with `systemctl start|restart <service>`.
- Inspect aggregated service log streams with `journalctl -u <service>`.
- Understand systemd unit files located in `/etc/systemd/system/`.
- Diagnose application environment issues via `EnvironmentFile` configuration.

---

## Instructions
1. Check the status of the failing service:
   ```bash
   systemctl status order-processor
   ```
2. Read the latest diagnostic logs using `journalctl`:
   ```bash
   journalctl -u order-processor
   ```
3. Locate the error message in the logs. Notice the configuration error in `/etc/order-processor/config.env`.
4. Edit `/etc/order-processor/config.env` using `sudo nano` or `sudo vim` (or a script/sed) to set a valid port (e.g. `PORT=5000`).
5. Restart the service:
   ```bash
   sudo systemctl restart order-processor
   ```
6. Verify the service is now `active (running)`:
   ```bash
   systemctl status order-processor
   ```
7. Run the mission check:
   ```bash
   ./play.sh check
   ```

---

## Progressive Hints

### Hint 1: Checking Service Status
Run:
```bash
systemctl status order-processor
```
Notice whether the service is `inactive (dead)` or `failed`. Look at the `Process: ExecStart=... (code=exited, status=1/FAILURE)` line.

### Hint 2: Reading Service Logs with `journalctl`
In systemd-managed systems, application output is forwarded to the journal. To read logs for a specific unit:
```bash
journalctl -u order-processor -n 20
```
Read the line marked `[CRITICAL]`. It points to an invalid value in `/etc/order-processor/config.env`.

### Hint 3: Fixing the Config & Restarting
Open `/etc/order-processor/config.env` with root privileges:
```bash
sudo nano /etc/order-processor/config.env
```
Fix the invalid `PORT` setting by changing `PORT=INVALID_STRING` to `PORT=5000`. Save the file, then restart the service:
```bash
sudo systemctl restart order-processor
```
Check `systemctl status order-processor` to verify it is healthy!
