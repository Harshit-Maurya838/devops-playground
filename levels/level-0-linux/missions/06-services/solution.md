# Mission 06: Solution Guide

> [!CAUTION]
> **SPOILER ALERT!** Only consult this solution if you have given the mission an honest try or want to review the underlying concepts.

---

## Step-by-Step Solution

1. **Check the status of the broken service**:
   ```bash
   systemctl status order-processor
   ```
   *Notice the output shows:*
   `Active: failed (Result: exit-code)`
   `Process: ExecStart=/usr/local/bin/order-processor (code=exited, status=1/FAILURE)`

2. **Inspect the service logs with `journalctl`**:
   ```bash
   journalctl -u order-processor
   ```
   *Read the critical error:*
   ```text
   [CRITICAL] Configuration parse error: PORT must be a valid integer between 1024 and 65535. Current value: 'INVALID_PORT_ABC'
   [CRITICAL] Service failed to bind to configured socket. Aborting startup.
   ```

3. **Inspect the unit file to find the environment configuration**:
   ```bash
   cat /etc/systemd/system/order-processor.service
   ```
   *Notice the line:*
   `EnvironmentFile=/etc/order-processor/config.env`

4. **Fix the configuration file**:
   Edit `/etc/order-processor/config.env` using your editor of choice:
   ```bash
   nano /etc/order-processor/config.env
   ```
   Change line:
   ```text
   PORT=INVALID_PORT_ABC
   ```
   To:
   ```text
   PORT=5000
   ```
   Save and exit (`Ctrl+O`, Enter, `Ctrl+X` in nano).

5. **Restart the service**:
   ```bash
   sudo systemctl restart order-processor
   ```

6. **Verify the service status**:
   ```bash
   systemctl status order-processor
   ```
   *You should see:*
   ```text
   ● order-processor.service - Order Processing Backend Service
        Loaded: loaded (/etc/systemd/system/order-processor.service; enabled)
        Active: active (running)
   ```

7. **Verify the mission**:
   ```bash
   ./play.sh check
   ```

---

## Why This Works (Under the Hood)
- **Unit Files**: Systemd organizes services through declarative `.service` configuration files. `EnvironmentFile` directs systemd to load environment variables into the process's execution context before calling `ExecStart`.
- **`systemctl status`**: Queries the service state, PID, memory/CPU usage, and prints the tail of the journal log for rapid triage.
- **`journalctl`**: Reads the system journal. Specifying `-u <unit>` filters log events matching the specific systemd unit identifier without having to search through `/var/log/syslog`.
