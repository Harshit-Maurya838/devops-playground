# Mission 01: The Lost Artifact (Navigation)

## Story
Welcome aboard, Cadet! An emergency alert just flashed from our mainframe. An ancient deployment authorization key was archived somewhere inside a deeply nested filesystem maze in `/home/player/mission-01`. 

The legacy developer left dozens of decoy directories and hidden archives. Your objective is to locate the hidden credential file, read its secret token, and submit it to complete the mission.

---

## Learning Objectives
In this mission, you will learn to:
- Print your current location with `pwd`.
- Inspect visible and hidden files (dotfiles) with `ls -la`.
- Traverse directories using relative and absolute paths with `cd`.
- Search through entire directory trees efficiently with `find`.
- Display file contents using `cat`.
- Write/redirect command output to a file using `>`.

---

## Instructions
1. Navigate to the mission directory:
   ```bash
   cd /home/player/mission-01
   ```
2. Explore the directory structure. Somewhere inside this labyrinth is a hidden file named `.credential_key`.
3. Locate `.credential_key` and inspect its contents.
4. Extract the token and save it into a new file named `/home/player/mission-01/solution.txt`.
5. Run the mission check:
   ```bash
   ./play.sh check
   ```

---

## Progressive Hints

### Hint 1: Revealing Hidden Files
Normal `ls` only shows regular, visible files. In Linux, any file or directory starting with a dot (`.`) is hidden by default. Use `ls -a` or `ls -la` to see everything in a directory.

### Hint 2: Using the `find` Command
Manually `cd`-ing through dozens of nested directories is slow and error-prone. The `find` command can search through all subdirectories at once:
```bash
find /home/player/mission-01 -name ".credential_key"
```

### Hint 3: Reading and Redirecting
Once `find` gives you the full path to `.credential_key`, read it with `cat <full-path>`. You can copy its contents or redirect it directly into `solution.txt`:
```bash
cat <full-path> > /home/player/mission-01/solution.txt
```
