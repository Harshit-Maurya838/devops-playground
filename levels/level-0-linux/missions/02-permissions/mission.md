# Mission 02: The Lockdown Incident (Permissions)

## Story
Alert, DevOps Engineer! The staging deployment failed. An automated CI/CD pipeline script (`deploy.sh`) in `/home/player/mission-02` won't execute, throwing `Permission denied`.

To make matters worse, an infrastructure audit revealed that a confidential credential file, `secret_vault.env`, has broken permissions: it is currently locked down completely (`----------`), making it impossible for the deployment script to read the required secrets.

Security compliance requires that:
1. `deploy.sh` must be executable by the `player` user.
2. `secret_vault.env` must be readable and writable ONLY by its owner (`player`), with strict `0600` permissions (`-rw-------`). Any group or public access is a compliance violation.

Once you fix the permissions, run `./deploy.sh` to trigger the deployment.

---

## Learning Objectives
In this mission, you will learn to:
- Inspect file permissions and ownership using `ls -l`.
- Understand the Linux permission model: Read (`r=4`), Write (`w=2`), Execute (`x=1`).
- Understand user classes: User/Owner (`u`), Group (`g`), Others/World (`o`).
- Modify permissions using symbolic mode (`chmod +x`, `chmod u+rw`) and octal mode (`chmod 600`, `chmod 755`).
- Run local scripts using relative execution path (`./deploy.sh`).

---

## Instructions
1. Move to the mission directory:
   ```bash
   cd /home/player/mission-02
   ```
2. Inspect the current permissions of all files:
   ```bash
   ls -la
   ```
3. Fix the permissions of `deploy.sh` so it can be executed.
4. Set the permissions of `secret_vault.env` to strictly `0600` (read/write for owner, no access for anyone else).
5. Execute the deployment script:
   ```bash
   ./deploy.sh
   ```
6. Run the mission check:
   ```bash
   ./play.sh check
   ```

---

## Progressive Hints

### Hint 1: Viewing the Permission String
Run `ls -l`. The 10-character string at the beginning represents file type and permissions:
- `-rwxr-xr-x` = regular file, owner has `rwx`, group has `r-x`, others have `r-x`.
- If `deploy.sh` has `-rw-r--r--`, the `x` (execute) bit is missing!
- If `secret_vault.env` has `----------`, all read/write bits are disabled.

### Hint 2: Granting Execute Permissions
To add execute permission to a file for its owner or user, you can use symbolic mode:
```bash
chmod +x deploy.sh
```
Or octal mode:
```bash
chmod 755 deploy.sh
```

### Hint 3: Securing the Vault File
For sensitive credentials, security compliance requires owner-only access:
- Read (`4`) + Write (`2`) = `6` for owner.
- `0` for group.
- `0` for others.
Apply octal mode `600`:
```bash
chmod 600 secret_vault.env
```
After fixing both, run `./deploy.sh` to generate the deployment verification!
