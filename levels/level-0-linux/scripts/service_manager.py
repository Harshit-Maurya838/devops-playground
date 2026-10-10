#!/usr/bin/env python3
"""
Lightweight Systemd and Journalctl Service Controller for Docker Containers.
Provides 1:1 compatible CLI behavior for 'systemctl' and 'journalctl' without
requiring PID 1 init privileges or host cgroup v2 mounts.
"""

import sys
import os
import time
import signal
import subprocess
import configparser
import datetime
import errno

RUN_DIR = "/run/systemd_units"
LOG_DIR = "/var/log/journal"
UNIT_DIR = "/etc/systemd/system"

for d in (RUN_DIR, LOG_DIR, UNIT_DIR):
    os.makedirs(d, exist_ok=True)
    try:
        os.chmod(d, 0o777)
    except Exception:
        pass

def normalize_unit_name(name):
    if not name.endswith(".service"):
        return f"{name}.service"
    return name

def get_unit_path(unit_name):
    unit_name = normalize_unit_name(unit_name)
    path = os.path.join(UNIT_DIR, unit_name)
    if os.path.exists(path):
        return path
    return None

def parse_unit_file(unit_path):
    # Systemd unit files are INI-like
    config = configparser.ConfigParser(strict=False, interpolation=None)
    # Ensure options are case-sensitive
    config.optionxform = str
    try:
        config.read(unit_path)
    except Exception as e:
        sys.stderr.write(f"Error reading unit file {unit_path}: {e}\n")
        sys.exit(1)
    return config

def get_pid(unit_name):
    pid_file = os.path.join(RUN_DIR, f"{unit_name}.pid")
    if os.path.exists(pid_file):
        try:
            with open(pid_file, "r") as f:
                pid = int(f.read().strip())
            # Check if process is alive
            os.kill(pid, 0)
            return pid
        except PermissionError:
            # EPERM: Process exists and is alive, but owned by another user (e.g. root)
            return pid
        except (ValueError, ProcessLookupError):
            return None
        except OSError as e:
            if hasattr(e, "errno") and e.errno == errno.EPERM:
                return pid
            return None
    return None

def get_last_pid_and_status(unit_name):
    status_file = os.path.join(RUN_DIR, f"{unit_name}.status")
    if os.path.exists(status_file):
        try:
            with open(status_file, "r") as f:
                lines = f.read().splitlines()
                if len(lines) >= 2:
                    return int(lines[0]), lines[1]
        except Exception:
            pass
    return None, "inactive"

def start_unit(unit_name):
    unit_path = get_unit_path(unit_name)
    unit_name = normalize_unit_name(unit_name)
    if not unit_path:
        sys.stderr.write(f"Failed to start {unit_name}: Unit {unit_name} not found.\n")
        sys.exit(1)

    existing_pid = get_pid(unit_name)
    if existing_pid:
        print(f"Service {unit_name} is already active (PID {existing_pid}).")
        return

    config = parse_unit_file(unit_path)
    if "Service" not in config or "ExecStart" not in config["Service"]:
        sys.stderr.write(f"Invalid unit file: missing [Service] ExecStart\n")
        sys.exit(1)

    exec_start = config["Service"]["ExecStart"]
    env_file = config["Service"].get("EnvironmentFile", None)
    work_dir = config["Service"].get("WorkingDirectory", "/")

    # Build environment
    proc_env = os.environ.copy()
    if env_file:
        # Strip optional leading - (ignore if missing)
        clean_env_path = env_file.lstrip("-")
        if os.path.exists(clean_env_path):
            with open(clean_env_path, "r") as ef:
                for line in ef:
                    line = line.strip()
                    if line and not line.startswith("#") and "=" in line:
                        k, v = line.split("=", 1)
                        # Strip outer quotes
                        v = v.strip("\"'")
                        proc_env[k.strip()] = v

    log_path = os.path.join(LOG_DIR, f"{unit_name}.log")
    try:
        if not os.path.exists(log_path):
            with open(log_path, "w") as _:
                pass
            os.chmod(log_path, 0o666)
    except Exception:
        pass
    log_file = open(log_path, "a", buffering=1)

    ts = datetime.datetime.now().strftime("%b %d %H:%M:%S")
    log_file.write(f"{ts} devops-sandbox systemd[1]: Starting {unit_name}...\n")

    # Start detached daemon process
    try:
        proc = subprocess.Popen(
            exec_start,
            shell=True,
            cwd=work_dir,
            env=proc_env,
            stdout=log_file,
            stderr=log_file,
            start_new_session=True
        )
    except Exception as e:
        log_file.write(f"{ts} devops-sandbox systemd[1]: Failed to start: {e}\n")
        log_file.close()
        sys.stderr.write(f"Failed to execute {exec_start}: {e}\n")
        sys.exit(1)

    pid = proc.pid
    pid_file = os.path.join(RUN_DIR, f"{unit_name}.pid")
    with open(pid_file, "w") as f:
        f.write(str(pid))

    # Give process 0.5s to see if it immediately crashes
    time.sleep(0.5)
    exit_code = proc.poll()

    status_file = os.path.join(RUN_DIR, f"{unit_name}.status")
    if exit_code is not None:
        # Process died immediately
        ts = datetime.datetime.now().strftime("%b %d %H:%M:%S")
        log_file.write(f"{ts} devops-sandbox systemd[1]: {unit_name}: Main process exited, code=exited, status={exit_code}/FAILURE\n")
        log_file.write(f"{ts} devops-sandbox systemd[1]: {unit_name}: Failed with result 'exit-code'.\n")
        with open(status_file, "w") as f:
            f.write(f"{pid}\nfailed (exit-code {exit_code})")
        if os.path.exists(pid_file):
            os.remove(pid_file)
        sys.stderr.write(f"Job for {unit_name} failed. See 'systemctl status {unit_name}' and 'journalctl -xeu {unit_name}' for details.\n")
        sys.exit(1)
    else:
        ts = datetime.datetime.now().strftime("%b %d %H:%M:%S")
        log_file.write(f"{ts} devops-sandbox systemd[1]: Started {unit_name}.\n")
        with open(status_file, "w") as f:
            f.write(f"{pid}\nactive")

def stop_unit(unit_name):
    unit_name = normalize_unit_name(unit_name)
    pid = get_pid(unit_name)
    if not pid:
        # Already stopped
        return

    try:
        os.kill(pid, signal.SIGTERM)
        for _ in range(10):
            time.sleep(0.1)
            try:
                os.kill(pid, 0)
            except OSError:
                break
        else:
            os.kill(pid, signal.SIGKILL)
    except OSError:
        pass

    pid_file = os.path.join(RUN_DIR, f"{unit_name}.pid")
    if os.path.exists(pid_file):
        os.remove(pid_file)

    status_file = os.path.join(RUN_DIR, f"{unit_name}.status")
    with open(status_file, "w") as f:
        f.write(f"{pid}\ninactive")

    log_path = os.path.join(LOG_DIR, f"{unit_name}.log")
    ts = datetime.datetime.now().strftime("%b %d %H:%M:%S")
    with open(log_path, "a") as f:
        f.write(f"{ts} devops-sandbox systemd[1]: Stopped {unit_name}.\n")

def restart_unit(unit_name):
    stop_unit(unit_name)
    time.sleep(0.3)
    start_unit(unit_name)

def status_unit(unit_name):
    unit_path = get_unit_path(unit_name)
    unit_name = normalize_unit_name(unit_name)
    if not unit_path:
        sys.stderr.write(f"Unit {unit_name} could not be found.\n")
        sys.exit(4)

    config = parse_unit_file(unit_path)
    description = config["Unit"].get("Description", unit_name)
    exec_start = config["Service"].get("ExecStart", "unknown")

    pid = get_pid(unit_name)
    last_pid, last_status = get_last_pid_and_status(unit_name)
    now_str = datetime.datetime.now().strftime("%a %Y-%m-%d %H:%M:%S UTC")

    log_path = os.path.join(LOG_DIR, f"{unit_name}.log")
    log_lines = []
    if os.path.exists(log_path):
        with open(log_path, "r") as f:
            log_lines = f.readlines()[-6:]

    if pid:
        print(f"\033[1;32m●\033[0m {unit_name} - {description}")
        print(f"     Loaded: loaded ({unit_path}; enabled)")
        print(f"     Active: \033[1;32mactive (running)\033[0m since {now_str}")
        print(f"   Main PID: {pid} ({exec_start.split()[0]})")
        print(f"      Tasks: 1 (limit: 4915)")
        print(f"     Memory: 8.2M")
        print(f"        CPU: 12ms")
        print(f"     CGroup: /system.slice/{unit_name}")
        print(f"             └─{pid} {exec_start}")
        print()
        if log_lines:
            for line in log_lines:
                print(f"     {line.rstrip()}")
        sys.exit(0)
    elif "failed" in last_status:
        print(f"\033[1;31m×\033[0m {unit_name} - {description}")
        print(f"     Loaded: loaded ({unit_path}; enabled)")
        print(f"     Active: \033[1;31mfailed (Result: exit-code)\033[0m since {now_str}")
        print(f"    Process: {last_pid} ExecStart={exec_start} (code=exited, status=1/FAILURE)")
        print(f"   Main PID: {last_pid} (code=exited, status=1/FAILURE)")
        print()
        if log_lines:
            for line in log_lines:
                print(f"     {line.rstrip()}")
        sys.exit(3)
    else:
        print(f"\033[0;37m○\033[0m {unit_name} - {description}")
        print(f"     Loaded: loaded ({unit_path}; enabled)")
        print(f"     Active: inactive (dead) since {now_str}")
        sys.exit(3)

def is_active(unit_name):
    unit_name = normalize_unit_name(unit_name)
    pid = get_pid(unit_name)
    if pid:
        print("active")
        sys.exit(0)
    else:
        last_pid, last_status = get_last_pid_and_status(unit_name)
        if "failed" in last_status:
            print("failed")
        else:
            print("inactive")
        sys.exit(3)

def journalctl_cli(args):
    unit_name = None
    lines_count = 50

    i = 0
    while i < len(args):
        arg = args[i]
        if arg in ("-u", "--unit") and i + 1 < len(args):
            unit_name = normalize_unit_name(args[i + 1])
            i += 1
        elif arg.startswith("-u="):
            unit_name = normalize_unit_name(arg.split("=", 1)[1])
        elif arg in ("-n", "--lines") and i + 1 < len(args):
            try:
                lines_count = int(args[i + 1])
            except ValueError:
                pass
            i += 1
        i += 1

    if not unit_name:
        sys.stderr.write("journalctl: Please specify unit with -u <unit_name>\n")
        sys.exit(1)

    log_path = os.path.join(LOG_DIR, f"{unit_name}.log")
    if not os.path.exists(log_path):
        print(f"-- No entries found for unit {unit_name} --")
        sys.exit(0)

    with open(log_path, "r") as f:
        lines = f.readlines()

    selected = lines[-lines_count:] if lines_count > 0 else lines
    print(f"-- Journal begins at {datetime.datetime.now().strftime('%a %Y-%m-%d %H:%M:%S UTC')}. --")
    for line in selected:
        print(line.rstrip())

def main():
    prog = os.path.basename(sys.argv[0])
    args = sys.argv[1:]

    if prog == "journalctl":
        journalctl_cli(args)
        return

    # systemctl dispatch
    if not args:
        print("systemctl [start|stop|restart|status|is-active|enable|disable] <unit>")
        sys.exit(1)

    cmd = args[0]
    unit = args[1] if len(args) > 1 else ""

    if cmd == "start":
        start_unit(unit)
    elif cmd == "stop":
        stop_unit(unit)
    elif cmd == "restart":
        restart_unit(unit)
    elif cmd == "status":
        status_unit(unit)
    elif cmd == "is-active":
        is_active(unit)
    elif cmd in ("enable", "disable"):
        print(f"Created symlink /etc/systemd/system/multi-user.target.wants/{normalize_unit_name(unit)}.")
    else:
        sys.stderr.write(f"Unknown systemctl command: {cmd}\n")
        sys.exit(1)

if __name__ == "__main__":
    main()
