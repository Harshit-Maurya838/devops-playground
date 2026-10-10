# Testing Guide: Level 0 (Linux & The Terminal)

This document provides a systematic test protocol to verify that each mission:
1. **Fails correctly** in its initial broken state.
2. **Passes cleanly** when the correct commands are executed.
3. **Is idempotent**: re-running `setup.sh` resets the environment without error.

---

## 🧪 Quick Test Protocol

Run these tests inside the `devops-sandbox` container (`docker compose exec -u player sandbox bash`).

---

### Mission 01: `01-navigate`

```bash
# 1. Setup mission
./play.sh start 01

# 2. Verify initial check FAILS
./play.sh check
# Expected: Exits non-zero with "Missing file: ... solution.txt was not found."

# 3. Solve mission
find /home/player/mission-01 -name ".credential_key" -exec cat {} + > /home/player/mission-01/solution.txt

# 4. Verify check SUCCEEDS
./play.sh check
# Expected: Exits 0 with "SUCCESS! You mastered file navigation..." and awards 50 XP.

# 5. Idempotency test
./play.sh reset
# Environment is safely wiped and rebuilt back to broken state.
```

---

### Mission 02: `02-permissions`

```bash
# 1. Setup mission
./play.sh start 02

# 2. Verify initial check FAILS
./play.sh check
# Expected: Exits non-zero with "Fail: ... deploy.sh does not have execute permissions (+x)."

# 3. Solve mission
chmod +x /home/player/mission-02/deploy.sh
chmod 600 /home/player/mission-02/secret_vault.env
/home/player/mission-02/deploy.sh

# 4. Verify check SUCCEEDS
./play.sh check
# Expected: Exits 0 with "SUCCESS! You mastered file permissions..." and awards 50 XP.

# 5. Idempotency test
./play.sh reset
```

---

### Mission 03: `03-text-detective`

```bash
# 1. Setup mission
./play.sh start 03

# 2. Verify initial check FAILS
./play.sh check
# Expected: Exits non-zero with "Fail: ... investigation.txt not found."

# 3. Solve mission
cat <<'EOF' > /home/player/mission-03/investigation.txt
ROGUE_IP=10.240.88.199
OCCURRENCE_COUNT=17
EOF

# 4. Verify check SUCCEEDS
./play.sh check
# Expected: Exits 0 with "SUCCESS! You mastered text filtering..." and awards 50 XP.

# 5. Idempotency test
./play.sh reset
```

---

### Mission 04: `04-processes`

```bash
# 1. Setup mission
./play.sh start 04

# 2. Verify initial check FAILS
./play.sh check
# Expected: Exits non-zero with "Fail: The 'port_bandit' process is still alive and running!"

# 3. Solve mission
pkill -9 -f port_bandit
/home/player/mission-04/start_gateway.sh

# 4. Verify check SUCCEEDS
./play.sh check
# Expected: Exits 0 with "SUCCESS! You mastered process inspection..." and awards 50 XP.

# 5. Idempotency test
./play.sh reset
```

---

### Mission 05: `05-ssh`

*(Requires both `sandbox` and `ssh-target` containers active in compose)*

```bash
# 1. Setup mission
./play.sh start 05

# 2. Verify initial check FAILS
./play.sh check
# Expected: Exits non-zero with "Fail: No SSH keypair found" or "Passwordless SSH login failed".

# 3. Solve mission
if [ ! -f ~/.ssh/id_ed25519 ]; then
    ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519
fi
sshpass -p insecure_temp_pass ssh-copy-id -o StrictHostKeyChecking=no targetuser@target-server
scp targetuser@target-server:/opt/tokens/secret_token.txt /home/player/mission-05/secret_token.txt

# 4. Verify check SUCCEEDS
./play.sh check
# Expected: Exits 0 with "SUCCESS! You mastered SSH key generation..." and awards 50 XP.

# 5. Idempotency test
./play.sh reset
```

---

### Mission 06: `06-services`

```bash
# 1. Setup mission
./play.sh start 06

# 2. Verify initial check FAILS
./play.sh check
# Expected: Exits non-zero with "Fail: PORT in ... is still invalid" or "service is not active".

# 3. Solve mission
sed -i 's/PORT=INVALID_PORT_ABC/PORT=5000/' /etc/order-processor/config.env
sudo systemctl restart order-processor

# 4. Verify check SUCCEEDS
./play.sh check
# Expected: Exits 0 with "SUCCESS! You diagnosed the service failure..." and awards 50 XP.

# 5. Idempotency test
./play.sh reset
```

---

### Boss Fight: `boss-cpu-hog`

```bash
# 1. Setup mission
./play.sh start boss

# 2. Verify initial check FAILS
./play.sh check
# Expected: Exits non-zero with "Fail: The persistence mechanism is still active at /etc/cron.d/hydra-respawn!"

# 3. Solve mission
sudo rm -f /etc/cron.d/hydra-respawn
sudo pkill -9 -f hydra

# 4. Verify check SUCCEEDS
./play.sh check
# Expected: Exits 0 with "VICTORY! You completely eradicated the Hydra process tree..." and awards 150 XP.

# 5. Idempotency test
./play.sh reset
```

---

## 🤖 Full Automated Test Suite

To run all pass/fail tests in a single automated pass, run:
```bash
./scripts/run_automated_tests.sh
```
*(This script exercises both failure and success states for all 7 missions in sequence).*
