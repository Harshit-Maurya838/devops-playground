# Mission 05: The Bastion Gateway (SSH)

## Story
Security alert! Our infrastructure team has decommissioned password authentication across our staging network in favor of cryptographic key-based SSH authentication.

You need to access our internal staging server (`target-server`) as user `targetuser`. Currently, password login is temporarily permitted for bootstrapping with password `insecure_temp_pass`, but your goal is to:
1. Generate an SSH keypair on your machine.
2. Transfer your public key to the remote server's `~/.ssh/authorized_keys`.
3. Verify passwordless key-based login.
4. Securely download the deployment credential `/opt/tokens/secret_token.txt` to `/home/player/mission-05/secret_token.txt` using `scp`.

---

## Learning Objectives
In this mission, you will learn to:
- Generate asymmetric cryptographic keypairs using `ssh-keygen`.
- Understand the roles of public keys (`.pub`) vs private keys (identity files).
- Install public keys on remote servers with `ssh-copy-id` or manual appending to `~/.ssh/authorized_keys`.
- Connect securely to remote hosts using `ssh`.
- Transfer files securely across the network using `scp`.
- Bypass interactive host verification flags in automated scripts (`BatchMode=yes`, `StrictHostKeyChecking=no`).

---

## Instructions
1. Enter the mission workspace:
   ```bash
   cd /home/player/mission-05
   ```
2. Generate an Ed25519 or RSA SSH keypair (if you don't already have one in `~/.ssh/`):
   ```bash
   ssh-keygen -t ed25519
   ```
   *(Press Enter to accept default location `/home/player/.ssh/id_ed25519` and empty passphrase).*
3. Copy your public key to `target-server`:
   ```bash
   ssh-copy-id targetuser@target-server
   ```
   *(When prompted, accept the host key fingerprint with `yes` and enter initial password `insecure_temp_pass`).*
4. Confirm passwordless login works:
   ```bash
   ssh targetuser@target-server
   ```
   *(You should log in immediately without any password prompt! Type `exit` to return).*
5. Download `/opt/tokens/secret_token.txt` to `/home/player/mission-05/secret_token.txt` using `scp`:
   ```bash
   scp targetuser@target-server:/opt/tokens/secret_token.txt /home/player/mission-05/secret_token.txt
   ```
6. Run the mission check:
   ```bash
   ./play.sh check
   ```

---

## Progressive Hints

### Hint 1: Creating Your Keypair
Never share your private key (`id_ed25519`)! Only the public key (`id_ed25519.pub`) is copied to remote systems.
Generate one without a passphrase for non-interactive learning:
```bash
ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519
```

### Hint 2: Transferring Public Keys
`ssh-copy-id` connects to the target machine via password, ensures the remote `~/.ssh` directory exists with `700` permissions, and appends your public key to `~/.ssh/authorized_keys` with `600` permissions.
Run:
```bash
ssh-copy-id targetuser@target-server
```
Password: `insecure_temp_pass`

### Hint 3: Copying Files Over SSH with `scp`
`scp` uses the SSH protocol underneath. The syntax is:
```bash
scp <user>@<host>:<remote_path> <local_path>
```
For this mission:
```bash
scp targetuser@target-server:/opt/tokens/secret_token.txt /home/player/mission-05/secret_token.txt
```
