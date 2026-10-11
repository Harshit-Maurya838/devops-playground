#!/usr/bin/env python3
# ==============================================================================
# DevOps Playground - Level 0: Linux & The Terminal
# UI & Briefing Terminal Renderer (scripts/ui_renderer.py)
# ==============================================================================
import os
import re
import sys
import shutil
import textwrap

# Terminal formatting definitions
RESET = "\033[0m"
BOLD = "\033[1m"
DIM = "\033[2m"
ITALIC = "\033[3m"

# Standard & 256 Colors
CYAN = "\033[36m"
BCYAN = "\033[1;36m"
GREEN = "\033[32m"
BGREEN = "\033[1;32m"
YELLOW = "\033[33m"
BYELLOW = "\033[1;33m"
MAGENTA = "\033[35m"
BMAGENTA = "\033[1;35m"
RED = "\033[31m"
BRED = "\033[1;31m"
WHITE = "\033[37m"
BWHITE = "\033[1;37m"
GRAY = "\033[90m"

# Specialized palette accents
FG_GOLD = "\033[38;5;220m"
FG_SKY = "\033[38;5;75m"
FG_EMERALD = "\033[38;5;48m"
FG_CMD = "\033[38;5;51m"
FG_MUTED = "\033[38;5;245m"
BG_CODE = "\033[48;5;236m"

TARGET_MAP = {
    "01-navigate": "/home/player/mission-01",
    "02-permissions": "/home/player/mission-02",
    "03-text-detective": "/home/player/mission-03",
    "04-processes": "/home/player/mission-04",
    "05-ssh": "/home/player/mission-05",
    "06-services": "/home/player/mission-06",
    "boss-cpu-hog": "System-wide (/etc/cron.d & Processes)",
}

def get_term_width():
    cols = shutil.get_terminal_size((80, 24)).columns
    return max(72, min(cols, 84))

def format_inline(text):
    """Format markdown bold, code ticks, and replace ./play.sh with play."""
    # Remove markdown horizontal rules
    text = re.sub(r'^\s*[-*_]{3,}\s*$', '', text, flags=re.MULTILINE)
    
    # Replace ./play.sh references with play
    text = text.replace("./play.sh", "play")
    
    # Bold **text**
    text = re.sub(r'\*\*(.*?)\*\*', f'{BOLD}\\1{RESET}', text)
    
    # Inline code `code`
    text = re.sub(r'`(.*?)`', f'{BCYAN}\\1{RESET}', text)

    # Italic *text* or _text_
    text = re.sub(r'(?<!\*)\*(?!\*)(.*?)\*', f'{ITALIC}\\1{RESET}', text)
    
    return text

def parse_mission_markdown(filepath):
    """Parses mission.md into title, sections, and hints."""
    if not os.path.isfile(filepath):
        return None
        
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    data = {
        "title": "Mission Briefing",
        "story": "",
        "objectives": [],
        "instructions": "",
        "hints": []
    }

    # Extract Title (# ...)
    title_match = re.search(r'^#\s+(.+)$', content, re.MULTILINE)
    if title_match:
        data["title"] = title_match.group(1).strip()

    # Split into H2 sections
    raw_sections = re.split(r'\n##\s+', content)
    
    for sec in raw_sections[1:]:
        lines = sec.strip().split('\n')
        sec_name = lines[0].strip().lower()
        sec_body = '\n'.join(lines[1:]).strip()
        
        # Strip trailing horizontal rule if present
        sec_body = re.sub(r'\n\s*[-*_]{3,}\s*$', '', sec_body).strip()
        
        if 'story' in sec_name:
            data["story"] = sec_body
        elif 'learning objective' in sec_name:
            data["objectives"] = [
                line.strip().lstrip('-*•').strip()
                for line in sec_body.split('\n')
                if line.strip().startswith(('-', '*', '•')) and line.strip().lstrip('-*•').strip()
            ]
        elif 'instruction' in sec_name:
            data["instructions"] = sec_body
        elif 'hint' in sec_name:
            # Parse individual hints
            hint_blocks = re.split(r'\n###\s+', sec_body)
            for hb in hint_blocks:
                hb = hb.strip()
                if not hb:
                    continue
                hlines = hb.split('\n')
                h_title = hlines[0].strip()
                h_content = '\n'.join(hlines[1:]).strip()
                # Clean any horizontal rules inside hint
                h_content = re.sub(r'\n\s*[-*_]{3,}\s*$', '', h_content).strip()
                data["hints"].append({"title": h_title, "content": h_content})

    return data

def render_section_header(title, icon, width):
    header_text = f"{icon}  {title.upper()}"
    line_len = max(4, width - len(title) - 8)
    line = "─" * line_len
    print(f"\n{BCYAN}{header_text} {GRAY}{line}{RESET}")

def render_code_block(code_lines, width):
    """Renders formatted shell command block."""
    if not code_lines:
        return
    for line in code_lines:
        line_clean = line.strip()
        if not line_clean:
            continue
        line_clean = line_clean.replace("./play.sh", "play")
        if line_clean.startswith("#"):
            print(f"      {GRAY}{line_clean}{RESET}")
        else:
            print(f"      {FG_EMERALD}${RESET} {FG_CMD}{BOLD}{line_clean}{RESET}")

def render_story_block(story_text, width):
    """Renders story section with proper handling of sub-lists and paragraphs."""
    paragraphs = re.split(r'\n\s*\n', story_text)
    for p in paragraphs:
        p = p.strip()
        if not p or re.match(r'^[-*_]{3,}$', p):
            continue
        
        lines = p.split('\n')
        # Check if paragraph contains list items (e.g. numbered 1. 2. or bullets)
        has_list = any(re.match(r'^\s*(\d+\.|[-*•])\s+', l) for l in lines)
        if has_list:
            for l in lines:
                l_strip = l.strip()
                list_match = re.match(r'^(\d+)\.\s+(.*)$', l_strip)
                bullet_match = re.match(r'^[-*•]\s+(.*)$', l_strip)
                if list_match:
                    num = list_match.group(1)
                    item_text = format_inline(list_match.group(2))
                    wrapped = textwrap.wrap(item_text, width=width - 8)
                    if wrapped:
                        print(f"    {BYELLOW}{num}.{RESET} {wrapped[0]}")
                        for extra in wrapped[1:]:
                            print(f"       {extra}")
                elif bullet_match:
                    item_text = format_inline(bullet_match.group(1))
                    wrapped = textwrap.wrap(item_text, width=width - 8)
                    if wrapped:
                        print(f"    {FG_SKY}▸{RESET} {wrapped[0]}")
                        for extra in wrapped[1:]:
                            print(f"      {extra}")
                else:
                    wrapped = textwrap.wrap(format_inline(l_strip), width=width - 4)
                    for w in wrapped:
                        print(f"  {w}")
            print()
        else:
            p_fmt = format_inline(p)
            wrapped = textwrap.wrap(p_fmt, width=width - 4)
            for w in wrapped:
                print(f"  {w}")
            print()

def render_instructions_body(raw_text, width):
    """Renders instruction steps and embedded code blocks cleanly."""
    lines = raw_text.split('\n')
    i = 0
    in_code_block = False
    code_buffer = []
    
    while i < len(lines):
        line = lines[i]
        
        # Check code fence
        if line.strip().startswith("```"):
            if in_code_block:
                render_code_block(code_buffer, width)
                code_buffer = []
                in_code_block = False
            else:
                in_code_block = True
            i += 1
            continue
            
        if in_code_block:
            code_buffer.append(line)
            i += 1
            continue
            
        trimmed = line.strip()
        if not trimmed or re.match(r'^[-*_]{3,}$', trimmed):
            i += 1
            continue
            
        # Check if line is a numbered step (e.g. "1. Navigate to ...")
        step_match = re.match(r'^(\d+)\.\s+(.*)$', trimmed)
        if step_match:
            step_num = step_match.group(1)
            step_desc = format_inline(step_match.group(2))
            wrapped = textwrap.wrap(step_desc, width=width - 8)
            if wrapped:
                print(f"\n  {BYELLOW}[{step_num}]{RESET} {wrapped[0]}")
                for extra in wrapped[1:]:
                    print(f"      {extra}")
        elif trimmed.startswith(('-', '*', '•')):
            sub_bullet = format_inline(trimmed.lstrip('-*•').strip())
            wrapped = textwrap.wrap(sub_bullet, width=width - 8)
            if wrapped:
                print(f"      {GRAY}▸{RESET} {wrapped[0]}")
                for extra in wrapped[1:]:
                    print(f"        {extra}")
        else:
            # Normal text / sub-notes
            desc = format_inline(trimmed)
            wrapped = textwrap.wrap(desc, width=width - 6)
            for w in wrapped:
                print(f"    {w}")
                
        i += 1
    
    if in_code_block and code_buffer:
        render_code_block(code_buffer, width)

def render_briefing(mission_dir, mission_id, xp="50"):
    width = get_term_width()
    md_file = os.path.join(mission_dir, "mission.md")
    data = parse_mission_markdown(md_file)
    
    if not data:
        print(f"{RED}❌ Mission briefing not found for {mission_id}.{RESET}")
        return

    # Extract category/tag from title if present
    title_raw = data["title"]
    category = "Core Linux"
    m_name = title_raw
    cat_match = re.search(r'\((.*?)\)', title_raw)
    if cat_match:
        category = cat_match.group(1).strip()
        m_name = re.sub(r'\(.*?\)', '', title_raw).strip()
    
    m_name = re.sub(r'^#*\s*(Mission\s+\d+:|Boss\s+Fight:)\s*', '', m_name, flags=re.IGNORECASE).strip()
    target_path = TARGET_MAP.get(mission_id, f"/home/player/{mission_id}")

    # Top Mission Banner
    sep_double = "═" * width
    print(f"\n{BCYAN}{sep_double}{RESET}")
    print(f"  {BOLD}🕹️  MISSION BRIEFING :: {YELLOW}{mission_id.upper()}{RESET} {BOLD}[ REWARD: {FG_GOLD}+{xp} XP{RESET}{BOLD} ]{RESET}")
    print(f"  {BWHITE}{m_name}{RESET}")
    print(f"  {GRAY}Domain: {category}  •  Target: {target_path}{RESET}")
    print(f"{BCYAN}{sep_double}{RESET}")

    # 1. Situation Report (Story)
    if data["story"]:
        render_section_header("Incident Intelligence (Story)", "📜", width)
        render_story_block(data["story"], width)

    # 2. Learning Objectives
    if data["objectives"]:
        render_section_header("Core Objectives & Skills", "🎯", width)
        for obj in data["objectives"]:
            obj_fmt = format_inline(obj)
            wrapped = textwrap.wrap(obj_fmt, width=width - 8)
            if wrapped:
                print(f"  {FG_SKY}◈{RESET} {wrapped[0]}")
                for extra in wrapped[1:]:
                    print(f"    {extra}")
        print()

    # 3. Action Protocol (Instructions)
    if data["instructions"]:
        render_section_header("Mission Protocol (Instructions)", "⚡", width)
        render_instructions_body(data["instructions"], width)
        print()

    # 4. Progressive Hints Notice (Spoiler-Free!)
    render_section_header("Classified Intel & Hints", "💡", width)
    print(f"  {GRAY}Progressive hints are concealed so you can solve this challenge yourself.{RESET}")
    print(f"  {BWHITE}Stuck? Request hints one at a time without spoiling the rest:{RESET}")
    print(f"    {FG_EMERALD}👉 Run:{RESET} {BGREEN}{BOLD}play hint{RESET}  {GRAY}(3 progressive hints available){RESET}")
    print()

    # Footer
    print(f"{BCYAN}{sep_double}{RESET}")
    print(f"  {BWHITE}🎯 Target Dir:{RESET} {target_path}")
    print(f"  {BGREEN}✔  Verify:{RESET}  {BOLD}play check{RESET}    {BYELLOW}💡 Hints:{RESET} {BOLD}play hint{RESET}    {BCYAN}📖 Info:{RESET} {BOLD}play briefing{RESET}")
    print(f"{BCYAN}{sep_double}{RESET}\n")

def render_hint(mission_dir, mission_id, hint_num):
    width = get_term_width()
    md_file = os.path.join(mission_dir, "mission.md")
    data = parse_mission_markdown(md_file)
    
    if not data or not data["hints"]:
        print(f"{RED}❌ No hints found for {mission_id}.{RESET}")
        return

    hint_idx = hint_num - 1
    if hint_idx < 0:
        hint_idx = 0
    if hint_idx >= len(data["hints"]):
        hint_idx = len(data["hints"]) - 1
        
    hint_obj = data["hints"][hint_idx]
    hint_title = hint_obj["title"]
    # Clean hint title prefix and markdown hashes
    hint_title = re.sub(r'^[#\s]*Hint\s+\d+:\s*', '', hint_title, flags=re.IGNORECASE).strip()
    hint_title = hint_title.lstrip('#').strip()
    hint_title = format_inline(hint_title)

    sep_double = "═" * width
    print(f"\n{BYELLOW}{sep_double}{RESET}")
    print(f"  {BOLD}💡 PROGRESSIVE HINT [{hint_num} of 3] :: {YELLOW}{mission_id}{RESET}")
    print(f"  {BWHITE}{hint_title}{RESET}")
    print(f"{BYELLOW}{sep_double}{RESET}\n")

    render_instructions_body(hint_obj["content"], width)

    print(f"\n{GRAY}{'─' * width}{RESET}")
    if hint_num < 3:
        next_hint = hint_num + 1
        print(f"  👉 Need more help? Run {BGREEN}{BOLD}play hint{RESET} again to reveal Hint {next_hint} of 3.")
    else:
        print(f"  💡 All 3 hints revealed! If you are still stuck, view the full walkthrough:")
        print(f"     Run: {BRED}{BOLD}play solution{RESET}")
    print(f"{BYELLOW}{sep_double}{RESET}\n")

def render_solution(mission_dir, mission_id):
    width = get_term_width()
    sol_file = os.path.join(mission_dir, "solution.md")
    if not os.path.isfile(sol_file):
        print(f"{RED}❌ Solution file not found for {mission_id}.{RESET}")
        return

    with open(sol_file, 'r', encoding='utf-8') as f:
        content = f.read()

    sep_double = "═" * width
    print(f"\n{BMAGENTA}{sep_double}{RESET}")
    print(f"  {BOLD}📖 CLASSIFIED SOLUTION GUIDE :: {MAGENTA}{mission_id.upper()}{RESET}")
    print(f"{BMAGENTA}{sep_double}{RESET}")

    lines = content.split('\n')
    i = 0
    in_code_block = False
    code_buffer = []

    while i < len(lines):
        line = lines[i]
        trimmed = line.strip()

        if trimmed.startswith("```"):
            if in_code_block:
                render_code_block(code_buffer, width)
                code_buffer = []
                in_code_block = False
            else:
                in_code_block = True
            i += 1
            continue

        if in_code_block:
            code_buffer.append(line)
            i += 1
            continue

        if re.match(r'^[-*_]{3,}$', trimmed):
            i += 1
            continue

        # Check GitHub alert blocks, e.g. > [!CAUTION]
        if trimmed.startswith(">"):
            alert_text = trimmed.lstrip(">").strip()
            if "[!CAUTION]" in alert_text or "[!WARNING]" in alert_text:
                print(f"\n  {BRED}⚠️  CAUTION: SPOILER ALERT!{RESET}")
            elif alert_text:
                wrapped = textwrap.wrap(format_inline(alert_text), width=width - 6)
                for w in wrapped:
                    print(f"     {GRAY}{w}{RESET}")
            i += 1
            continue

        if trimmed.startswith("# "):
            print(f"\n{BOLD}{BWHITE}{trimmed.lstrip('#').strip()}{RESET}\n")
        elif trimmed.startswith("## "):
            h2 = trimmed.lstrip('#').strip()
            render_section_header(h2, "◈", width)
        elif trimmed.startswith("### "):
            h3 = trimmed.lstrip('#').strip()
            print(f"\n  {BCYAN}{BOLD}{h3}{RESET}")
        elif trimmed.startswith(('-', '*', '•')):
            bullet = format_inline(trimmed.lstrip('-*•').strip())
            wrapped = textwrap.wrap(bullet, width=width - 6)
            if wrapped:
                print(f"  {FG_SKY}•{RESET} {wrapped[0]}")
                for extra in wrapped[1:]:
                    print(f"    {extra}")
        elif re.match(r'^\d+\.\s+', trimmed):
            step_match = re.match(r'^(\d+)\.\s+(.*)$', trimmed)
            step_num = step_match.group(1)
            step_desc = format_inline(step_match.group(2))
            wrapped = textwrap.wrap(step_desc, width=width - 8)
            if wrapped:
                print(f"\n  {BYELLOW}[{step_num}]{RESET} {wrapped[0]}")
                for extra in wrapped[1:]:
                    print(f"      {extra}")
        elif trimmed:
            desc = format_inline(trimmed)
            wrapped = textwrap.wrap(desc, width=width - 4)
            for w in wrapped:
                print(f"  {w}")
        else:
            print()
        i += 1

    print(f"\n{BMAGENTA}{sep_double}{RESET}\n")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: ui_renderer.py [briefing|hint|solution] <mission_dir> [mission_id] [extra]")
        sys.exit(1)

    cmd = sys.argv[1]
    m_dir = sys.argv[2]
    m_id = sys.argv[3] if len(sys.argv) > 3 else os.path.basename(m_dir)

    if cmd == "briefing":
        xp_val = sys.argv[4] if len(sys.argv) > 4 else "50"
        render_briefing(m_dir, m_id, xp_val)
    elif cmd == "hint":
        h_lvl = int(sys.argv[4]) if len(sys.argv) > 4 else 1
        render_hint(m_dir, m_id, h_lvl)
    elif cmd == "solution":
        render_solution(m_dir, m_id)
    else:
        print(f"Unknown action: {cmd}")
        sys.exit(1)
