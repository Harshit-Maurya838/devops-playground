# Mission 04: Solution Guide

> [!CAUTION]
> **SPOILER ALERT!** Only consult this solution if you have given the mission an honest try or want to review the underlying concepts.

---

## Step-by-Step Solution

1. **Enter the mission workspace**:
   ```bash
   cd /home/player/mission-04
   ```

2. **Discover the process holding port 8080**:
   ```bash
   ss -tulpn | grep 8080
   # Or using lsof:
   lsof -i :8080
   ```
   *You will see `python3` or `port_bandit.py` bound to `0.0.0.0:8080` along with its PID (Process ID).*

3. **Check the process details**:
   ```bash
   ps aux | grep port_bandit
   ```

4. **Attempt graceful termination (and see why it fails)**:
   ```bash
   kill <PID>
   ```
   *`port_bandit` catches signal 15 (`SIGTERM`) and refuses to exit.*

5. **Forcefully terminate with `SIGKILL` (signal 9)**:
   ```bash
   kill -9 <PID>
   # Or kill directly by name:
   pkill -9 -f port_bandit
   ```

6. **Confirm port 8080 is freed and start the gateway**:
   ```bash
   ./start_gateway.sh
   ```
   *Output returned:*
   ```text
   🚀 Attempting to initialize API Gateway on port 8080...
   ✅ Port 8080 is FREE! Gateway socket initialized successfully.
   ```

7. **Verify your solution**:
   ```bash
   ./play.sh check
   ```

---

## Why This Works (Under the Hood)
- **Sockets & File Descriptors**: In Linux, network sockets are represented as file descriptors. A TCP port can typically only be bound by one process at a time without `SO_REUSEPORT`.
- **`SIGTERM` vs `SIGKILL`**:
  - `SIGTERM` (signal 15) is the default termination request sent by `kill`. It allows applications to perform graceful cleanup (saving state, closing DB connections), but applications can intercept, ignore, or block it.
  - `SIGKILL` (signal 9) CANNOT be caught, blocked, or ignored by user-space applications. The Linux kernel immediately unschedules and reaps the process.
