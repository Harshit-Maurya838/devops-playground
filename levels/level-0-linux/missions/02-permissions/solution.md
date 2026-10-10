# Mission 02: Solution Guide

> [!CAUTION]
> **SPOILER ALERT!** Only consult this solution if you have given the mission an honest try or want to review the underlying concepts.

---

## Step-by-Step Solution

1. **Enter the mission workspace**:
   ```bash
   cd /home/player/mission-02
   ```

2. **Inspect current file modes**:
   ```bash
   ls -la
   ```
   *Notice `deploy.sh` is `-rw-r--r--` (no execute `x` bit) and `secret_vault.env` is `----------` (mode `0000`).*

3. **Make `deploy.sh` executable**:
   ```bash
   chmod +x deploy.sh
   # Or using octal representation:
   chmod 755 deploy.sh
   ```

4. **Lock down `secret_vault.env` to owner read/write only**:
   ```bash
   chmod 600 secret_vault.env
   ```

5. **Execute the deployment script**:
   ```bash
   ./deploy.sh
   ```
   *You should see:*
   ```text
   🚀 Starting automated deployment...
   📦 Injecting environment credentials...
   ✅ Verification passed. Generating deployment record...
   🎉 Deployment successfully completed!
   ```

6. **Verify the mission**:
   ```bash
   ./play.sh check
   ```

---

## Why This Works (Under the Hood)
- **Linux File Permissions (POSIX)**: Each file has 9 permission bits grouped into three triads: `[User/Owner] [Group] [Others]`. Each triad contains `r` (read = 4), `w` (write = 2), and `x` (execute = 1).
- **Octal `600`**: `6` (`4+2`, read and write) for the owner; `0` (no permissions) for group; `0` (no permissions) for world. In DevOps, secret files (SSH private keys, API credentials, certificates) must strictly be `600` or `400` so unprivileged local accounts cannot read them.
- **The Shebang & Executable Bit**: When you run `./deploy.sh`, the Linux kernel checks the execute bit (`x`). If present, it reads the shebang (`#!/usr/bin/env bash`) on the first line and invokes the specified interpreter with the script path.
