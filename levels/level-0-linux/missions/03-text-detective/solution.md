# Mission 03: Solution Guide

> [!CAUTION]
> **SPOILER ALERT!** Only consult this solution if you have given the mission an honest try or want to review the underlying concepts.

---

## Step-by-Step Solution

1. **Enter the mission workspace**:
   ```bash
   cd /home/player/mission-03
   ```

2. **Preview and verify file size**:
   ```bash
   wc -l access.log
   head -n 3 access.log
   ```

3. **Count the occurrences of the critical alert**:
   ```bash
   grep "ALERT_UNAUTHORIZED_DATABASE_DUMP" access.log | wc -l
   ```
   *Output returned:*
   ```text
   17
   ```

4. **Extract the attacker's IP address**:
   View one of the matching lines:
   ```bash
   grep "ALERT_UNAUTHORIZED_DATABASE_DUMP" access.log | head -n 1
   ```
   *Notice the format:*
   `2026-10-11T01:04:00Z IP=10.240.88.199 STATUS=500 MSG="ALERT_UNAUTHORIZED_DATABASE_DUMP..."`

   Extract and deduplicate the IP field using a Unix pipeline:
   ```bash
   grep "ALERT_UNAUTHORIZED_DATABASE_DUMP" access.log | awk '{print $2}' | cut -d'=' -f2 | sort | uniq
   ```
   *Output returned:*
   ```text
   10.240.88.199
   ```

5. **Generate the incident report**:
   ```bash
   cat <<'EOF' > investigation.txt
   ROGUE_IP=10.240.88.199
   OCCURRENCE_COUNT=17
   EOF
   ```

6. **Verify your solution**:
   ```bash
   ./play.sh check
   ```

---

## Why This Works (Under the Hood)
- **Unix Philosophy**: Unix tools follow the philosophy of doing one thing well and composing together via text streams.
- **Pipes (`|`)**: A pipeline passes the standard output (stdout) of one process directly into the standard input (stdin) of the next without writing temporary files to disk.
- **`sort | uniq` Idiom**: `uniq` only merges adjacent duplicate lines. Sorting first ensures identical records are grouped together so `uniq` eliminates all duplicates across the stream.
- **`cut` & `awk`**: Stream parsing tools. `cut -d'=' -f2` splits a key-value token by `=` and yields the second field (`10.240.88.199`).
