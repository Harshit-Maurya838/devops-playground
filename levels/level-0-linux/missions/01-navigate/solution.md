# Mission 01: Solution Guide

> [!CAUTION]
> **SPOILER ALERT!** Only consult this solution if you have given the mission an honest try or want to review the underlying concepts.

---

## Step-by-Step Solution

1. **Enter the mission workspace**:
   ```bash
   cd /home/player/mission-01
   ```

2. **Search for the hidden key**:
   Use `find` to recursively scan all directories starting from the current directory (`.`):
   ```bash
   find . -name ".credential_key"
   ```
   *Output returned:*
   ```text
   ./sector_charlie/.deep_vault/archive/legacy_storage/.credential_key
   ```

3. **Inspect the file**:
   ```bash
   cat ./sector_charlie/.deep_vault/archive/legacy_storage/.credential_key
   ```
   *Output returned:*
   ```text
   TOKEN{lost_in_th3_sh3ll_found_by_f1nd_9921}
   ```

4. **Save it to the solution file**:
   Using output redirection (`>`):
   ```bash
   cat ./sector_charlie/.deep_vault/archive/legacy_storage/.credential_key > solution.txt
   ```

5. **Verify your solution**:
   ```bash
   ./play.sh check
   ```

---

## Why This Works (Under the Hood)
- **Dotfiles**: Files beginning with a dot (`.`) are treated as hidden by convention in Unix-like operating systems. Standard tools like `ls` hide them unless given the `-a` (all) flag.
- **The `find` utility**: `find` recursively crawls directories using filesystem system calls (`opendir`, `readdir`). Matching against `-name` evaluates each filename in the directory tree without loading the file contents.
- **Redirection (`>`)**: The shell operator `>` opens or creates `solution.txt` for writing (overwriting if it already exists) and connects the standard output (stdout) of `cat` to that file descriptor.
