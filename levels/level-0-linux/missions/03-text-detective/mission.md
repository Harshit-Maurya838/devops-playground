# Mission 03: Text Detective (Log Sleuthing)

## Story
Late last night, a distributed attack hit our payment gateway, flooding our logging cluster. Our monitoring system captured a massive 50,000-line server log: `/home/player/mission-03/access.log`.

Amidst tens of thousands of regular web requests, a rogue actor triggered a critical security alert:
`ALERT_UNAUTHORIZED_DATABASE_DUMP`.

Your mission as the DevOps on-call engineer is to parse through this mountain of data using Unix text-processing utilities, identify the attacker's IP address, count the exact number of breach attempts, and write your incident report.

---

## Learning Objectives
In this mission, you will learn to:
- Inspect file beginnings and endings with `head` and `tail`.
- Count lines, words, and characters with `wc -l`.
- Search for specific patterns with `grep`.
- Chain commands together using Unix pipes (`|`).
- Organize and deduplicate output streams using `sort` and `uniq`.
- Extract specific columns with `cut` or `awk`.

---

## Instructions
1. Navigate to the mission directory:
   ```bash
   cd /home/player/mission-03
   ```
2. Inspect `access.log` using `wc -l` to verify its line count, and preview the structure using `head` or `tail`.
3. Filter the log for the critical error event: `ALERT_UNAUTHORIZED_DATABASE_DUMP`.
4. Determine:
   - The attacker's IP address (`ROGUE_IP`).
   - The total number of alert occurrences (`OCCURRENCE_COUNT`).
5. Create an incident report file `/home/player/mission-03/investigation.txt` with the following format:
   ```text
   ROGUE_IP=<extracted_ip>
   OCCURRENCE_COUNT=<total_count>
   ```
6. Run the mission check:
   ```bash
   ./play.sh check
   ```

---

## Progressive Hints

### Hint 1: Inspecting the Log File
Don't open a 50,000-line file directly in a text editor—it will be slow and overwhelming. Instead, preview the first few lines:
```bash
head -n 5 access.log
```
Check how many total lines exist:
```bash
wc -l access.log
```

### Hint 2: Filtering with `grep` and Counting with `wc`
Find lines containing the breach keyword:
```bash
grep "ALERT_UNAUTHORIZED_DATABASE_DUMP" access.log
```
Pipe (`|`) the matching output into `wc -l` to get the exact count:
```bash
grep "ALERT_UNAUTHORIZED_DATABASE_DUMP" access.log | wc -l
```

### Hint 3: Isolating the Attacker's IP
To isolate the IP address, extract the field with `cut` or `awk`, then use `sort` and `uniq` to find the unique culprit:
```bash
grep "ALERT_UNAUTHORIZED_DATABASE_DUMP" access.log | awk '{print $2}' | sort | uniq
```
(Assuming the IP field looks like `IP=10.240.88.199`, strip `IP=` to get `10.240.88.199` and write to `investigation.txt`).
