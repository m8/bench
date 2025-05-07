#!/usr/bin/env python3
import os
import subprocess
from pathlib import Path
import json
import re
from collections import defaultdict
import sys

def read_file(path, require_sudo=False):
    try:
        if require_sudo:
            return subprocess.check_output(f"sudo cat {path}", shell=True, text=True).strip()
        return Path(path).read_text().strip()
    except Exception:
        return "N/A"

def run_cmd(cmd):
    try:
        return subprocess.check_output(cmd, shell=True, text=True).strip()
    except Exception:
        return "N/A"

def get_machine_info():
    return {
        "host": run_cmd("hostname"),
        "cpu_model": run_cmd("lscpu | grep 'Model name' | cut -d':' -f2 | xargs"),
        "cpu_cores": run_cmd("nproc"),
        "kernel": run_cmd("uname -r"),
        "memory": run_cmd("free -h | grep Mem | awk '{print $2}'"),
        "governor": read_file("/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"),
        "scaling_min_freq": read_file("/sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq"),
        "scaling_max_freq": read_file("/sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq"),
        "numa_info": parse_numa_info(run_cmd("numactl --hardware")),
        "prefetchers": run_cmd("sudo rdmsr 0x1a4"),
    }

def get_generic_info():
    return {
        "vmstat": run_cmd("vmstat -a"),
        "free": run_cmd("free"),
        "meminfo": read_file("/proc/meminfo"),
    }

def get_numa_balancing_info():
    return {
        "numa_balancing": read_file("/proc/sys/kernel/numa_balancing"),
        "demotion_enabled": read_file("/sys/kernel/mm/numa/demotion_enabled"),
        "zone_reclaim_mode": read_file("/proc/sys/vm/zone_reclaim_mode"),
        "lru_gen_enabled": read_file("/sys/kernel/mm/lru_gen/enabled"),
    }

def get_hugepage_info():
    return {
        "thp_enabled": read_file("/sys/kernel/mm/transparent_hugepage/enabled"),
        "thp_defrag": read_file("/sys/kernel/mm/transparent_hugepage/defrag"),
        "khugepaged_defrag": read_file("/sys/kernel/mm/transparent_hugepage/khugepaged/defrag"),
    }

def get_swap_info():
    return {
        "swappiness": read_file("/proc/sys/vm/swappiness"),
        "dirty_ratio": read_file("/proc/sys/vm/dirty_ratio"),
        "dirty_background_ratio": read_file("/proc/sys/vm/dirty_background_ratio"),
    }

def get_watermark_info():
    return {
        "min_free_kbytes": read_file("/proc/sys/vm/min_free_kbytes"),
        "watermark_scale_factor": read_file("/proc/sys/vm/watermark_scale_factor"),
        "watermark_boost_factor": read_file("/proc/sys/vm/watermark_boost_factor"),
    }

def get_fragmentation_info():
    return {
        "compaction_proactiveness": read_file("/proc/sys/vm/compaction_proactiveness"),
        "buddyinfo": read_file("/proc/buddyinfo"),
        "extfrag_index": parse_extfrag_index(read_file("/sys/kernel/debug/extfrag/extfrag_index", require_sudo=True)),
        "unusable_index": read_file("/sys/kernel/debug/extfrag/unusable_index"),
        "extfrag_threshold": read_file("/proc/sys/vm/extfrag_threshold"),
    }

def get_vmstats():
    raw_vmstat = read_file("/proc/vmstat")
    # zoneinfo = parse_zoneinfo(run_cmd("cat /proc/zoneinfo"))
    return {
        "vmstat": parse_vmstat(raw_vmstat),
        # "zoneinfo": zoneinfo
    }

def parse_extfrag_index(raw_text):
    result = {}
    for line in raw_text.strip().splitlines():
        parts = line.split()
        if len(parts) >= 5:
            node = parts[1].rstrip(",")
            zone = parts[3]
            values = parts[4:]
            try:
                values = [float(v) for v in values]
            except ValueError:
                continue

            key = f"node{node}_{zone}"
            result[key] = {f"order_{i}": val for i, val in enumerate(values)}
    return result

def parse_vmstat(raw_text):
    data = {}
    for line in raw_text.strip().splitlines():
        parts = line.strip().split()
        if len(parts) == 2:
            key, value = parts
            try:
                data[key] = int(value)
            except ValueError:
                data[key] = value
    return data

def parse_numa_info(raw_text):
    data = {
        "available_nodes": None,
        "nodes": {},
        "node_distances": []
    }

    lines = raw_text.strip().splitlines()
    current_node = None

    for line in lines:
        if m := re.match(r"available:\s*(\d+)", line):
            data["available_nodes"] = int(m.group(1))

        elif m := re.match(r"node (\d+) cpus:\s*(.*)", line):
            current_node = f"node_{m.group(1)}"
            cpus = list(map(int, m.group(2).split())) if m.group(2) else []
            data["nodes"].setdefault(current_node, {})["cpus"] = cpus

        elif m := re.match(r"node (\d+) size:\s*(\d+)", line):
            current_node = f"node_{m.group(1)}"
            data["nodes"].setdefault(current_node, {})["size_MB"] = int(m.group(2))

        elif m := re.match(r"node (\d+) free:\s*(\d+)", line):
            current_node = f"node_{m.group(1)}"
            data["nodes"].setdefault(current_node, {})["free_MB"] = int(m.group(2))

        elif line.strip().startswith("node distances:"):
            data["node_distances"] = []

        elif re.match(r"^\s*\d+:\s+", line):  # matrix row
            row = list(map(int, line.strip().split(":")[1].split()))
            data["node_distances"].append(row)

    return data

def parse_zoneinfo(raw_text):
    data = defaultdict(lambda: defaultdict(dict))
    current_node = None
    current_zone = None

    for line in raw_text.splitlines():
        node_match = re.match(r"Node\s+(\d+),\s+zone\s+(\w+)", line)
        if node_match:
            current_node = f"Node_{node_match.group(1)}"
            current_zone = node_match.group(2)
            continue

        kv_match = re.match(r"\s*(\w+):\s+(.+)", line)
        if kv_match and current_node and current_zone:
            key = kv_match.group(1)
            val = kv_match.group(2).strip()

            if val.startswith("(") and val.endswith(")"):
                try:
                    parsed_val = tuple(map(int, val[1:-1].split(",")))
                except ValueError:
                    parsed_val = val
            else:
                try:
                    parsed_val = int(val)
                except ValueError:
                    parsed_val = val

            data[current_node][current_zone][key] = parsed_val

    return data

# prefixes=("vm.", "kernel.", "fs.", "net.", "user.")
# network-related ones can be added later
# for my casem, i need mostly vm.* and kernel.*
def collect_sysctl(prefixes=("vm.", "kernel.", "fs.", "user.")):
    output = run_cmd("sysctl -a")
    result = {}
    for line in output.splitlines():
        if any(line.startswith(p) for p in prefixes):
            if "=" in line:
                key, val = map(str.strip, line.split("=", 1))
                result[key] = val
    return result


def collect_all():
    return {
        "report_meta": {
            "generated_at": run_cmd("date"),
            "hostname": run_cmd("hostname"),
            "uname": run_cmd("uname -a"),
            "user": run_cmd("whoami")
        },
        "machine": get_machine_info(),
        "generic": get_generic_info(),
        "numa_balancing": get_numa_balancing_info(),
        "hugepages": get_hugepage_info(),
        "swap": get_swap_info(),
        "watermarks": get_watermark_info(),
        "fragmentation": get_fragmentation_info(),
        "vmstats": get_vmstats(),
        "sysctl": collect_sysctl(),
    }

if __name__ == "__main__":
    output_file = sys.argv[1] if len(sys.argv) > 1 else "stats.json"
    data = collect_all()
    with open(output_file, "w") as f:
        json.dump(data, f, indent=2)