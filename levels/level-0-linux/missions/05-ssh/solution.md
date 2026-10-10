# Mission 05: Solution Guide

> [!CAUTION]
> **SPOILER ALERT!** Only consult this solution if you have given the mission an honest try or want to review the underlying concepts.

---

## Step-by-Step Solution

1. **Enter the mission workspace**:
   ```bash
   cd /home/player/mission-05
   ```

2. **Generate an SSH keypair**:
   ```bash
   ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519
   ```
   *This creates:*
   - `~/.ssh/id_ed25519` (your secret private key)
   - `~/.ssh/id_ed25519.pub` (your public key)

3. **Install the public key on the remote server**:
   ```bash
   ssh-copy-id targetuser@target-server
   ```
   *When prompted, type `yes` to accept the fingerprint, then enter password:*
   ```text
   insecure_temp_pass
   ```

4. **Verify passwordless login**:
   ```bash
   ssh targetuser@target-server
   ```
   *(Notice that you are logged in directly without a password prompt! Type `exit` to return to `devops-sandbox`).*

5. **Download the secret token via `scp`**:
   ```bash
   scp targetuser@target-server:/opt/tokens/secret_token.txt /home/player/mission-05/secret_token.txt
   ```

6. **Verify the downloaded token**:
   ```bash
   cat /home/player/mission-05/secret_token.txt
   ```
   *Output returned:*
   ```text
   SECRET_FLAG{ssh_k3y_auth_mast3r_2026}
   ```

7. **Verify the mission**:
   ```bash
   ./play.sh check
   ```

---

## Why This Works (Under the Hood)
- **Public Key Cryptography**: SSH uses asymmetric cryptography. The public key is placed in `~/.ssh/authorized_keys` on the target server. During handshake, the server encrypts a challenge using your public key, which only your local private key can decrypt and sign.
- **`ssh-copy-id`**: Under the hood, `ssh-copy-id` connects over SSH, checks that `~/.ssh` has mode `700`, and appends the specified `.pub` file to `~/.ssh/authorized_keys` with mode `600`.
- **`scp`**: Secure Copy Protocol operates over an encrypted SSH connection. It initializes an SSH session and invokes `scp -t` (target) or `scp -f` (from) on the remote machine to transfer byte streams.
