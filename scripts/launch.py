#!/usr/bin/env python3

import argparse
import os
import subprocess
import time
import signal
import threading
import json
import re
import sys
import psutil
import random
import string

CONFIG_SYSTEM_STATE = True

if CONFIG_SYSTEM_STATE:
    import sysls


PERF="/home/unal/sandbox/linux/tools/perf/perf"

def get_total_cpu_count(): return os.cpu_count()

def parse_perf_output(output: str) -> dict:
    result = {}
    
    perf_line_pattern = re.compile(r'^\s*([\d,\.]+)\s+([\w\-\.]+)(?:\s+#.*)?$')
    
    for line in output.splitlines():
        match = perf_line_pattern.match(line)
        if match:
            raw_value, counter_name = match.groups()
            try:
                value = int(raw_value.replace(',', ''))
            except ValueError:
                value = float(raw_value.replace(',', ''))

            result[counter_name] = value
    
    return result

class BenchArgs:
    def __init__(self, name, command, args, bench_threads, numa_mem, numa_cpu, perf_counters=None):
        self.name = name
        self.command = command
        self.args = args
        self.bench_threads = bench_threads
        self.numa_mem = numa_mem
        self.numa_cpu = numa_cpu
        self.perf_counters = perf_counters
        self.exec_cmd = None
        self.set_exec_cmd()

    def set_exec_cmd(self):
        cmd = []

        if self.perf_counters:
            cmd.append(PERF)
            cmd.append("stat")
            cmd.append("-e")
            cmd.append(self.perf_counters)


        cmd.append("taskset")
        cmd.append("-c")
        if self.bench_threads > 1:
            cmd.append(f"0-{self.bench_threads - 1}")
        else:
            cmd.append("0")

        if self.numa_mem is not None or self.numa_cpu is not None:
            cmd.append("numactl")
            if self.numa_mem is not None:
                cmd.extend(["--membind", str(self.numa_mem)])
            if self.numa_cpu is not None:
                cmd.extend(["--cpunodebind", str(self.numa_cpu)])

        cmd.append(self.command)
        if self.args:
            cmd.extend(self.args)

        self.exec_cmd = cmd

    def print_args(self):
        print(f"Benchmark Name: {self.name}")
        print(f"Command: {self.command}")
        print(f"Arguments: {self.args}")
        print(f"Threads: {self.bench_threads}")
        print(f"NUMA Memory: {self.numa_mem}")
        print(f"NUMA CPU: {self.numa_cpu}")
        print(f"Perf Counters: {self.perf_counters}")
        print(f"Execution Command: {' '.join(self.exec_cmd)}")

class Benchmark:
    def __init__(self, bench_args):
        self.bench_args = bench_args
        self.results = None
        self.error = None
        self.start_time = None
        self.stat_perf = None
        self.end_time = None
        self.duration = None
        self.status = None
        self.output = None
    
    def run(self):
        cmd = self.bench_args.exec_cmd
        self.start_time = time.time()
        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                check=False
            )
            self.output = result.stdout
            self.results = check_for_common_results(result.stdout)
            self.error = result.stderr
            if self.bench_args.perf_counters:
                self.stat_perf = parse_perf_output(result.stderr)

            self.status = result.returncode
        except Exception as e:
            self.error = str(e)
            self.status = -1
        self.end_time = time.time()
        self.duration = self.end_time - self.start_time

    def generate_report(self):
        report = {
            "name": self.bench_args.name,
            "system": {
                "machine": sysls.get_machine_info()
                if CONFIG_SYSTEM_STATE else {},
                "numa_balancing": sysls.get_numa_balancing_info()
                if CONFIG_SYSTEM_STATE else {},
                "hugepage": sysls.get_hugepage_info()
                if CONFIG_SYSTEM_STATE else {},
                "sysctl": sysls.collect_sysctl()
                if CONFIG_SYSTEM_STATE else {},
            },
            "numa config": {
                "numa_mem": self.bench_args.numa_mem,
                "numa_cpu": self.bench_args.numa_cpu
            },
            "command": self.bench_args.command,
            "args": self.bench_args.args,
            "bench_threads": self.bench_args.bench_threads,
            "exec_cmd": self.bench_args.exec_cmd,
            "status": self.status,
            "duration": self.duration,
            "perf_counters": self.bench_args.perf_counters,
            "perf_output": self.stat_perf,
            "start_time": self.start_time,
            "end_time": self.end_time,
            "results": self.results,
            "output": self.output,
            "error": self.error
        }
        return report

    def save_report(self, filename="report.json"):
        report = self.generate_report()
        with open(filename, "w") as f:
            json.dump(report, f, indent=4)      
    

#    printf( "\n\n" );
#     printf("==============\n")
#     printf("== mbench ==\n");
#     printf("==============\n");
#     printf("secs: %f\n", t);
#     printf("work: %f\n", mops);
#     printf("work_type: MOP/s\n");
#     printf("===============\n");
#     printf("===============\n");
def check_for_common_results(output):
    # Check for common results in the output
    if "mbench" in output:
        work = re.search(r"work:\s*([\d\.]+)", output)
        secs = re.search(r"secs:\s*([\d\.]+)", output)
        work_type = re.search(r"work_type:\s*([\w\/]+)", output)
        if work and secs and work_type:
            return {
                "work": float(work.group(1)),
                "secs": float(secs.group(1)),
                "work_type": work_type.group(1)
            }
    return None


def parse_args():
    parser = argparse.ArgumentParser(description="Benchmark Launcher")
    parser.add_argument("--numa_mem", type=str, help="NUMA memory node", default="0")
    parser.add_argument("--numa_cpu", type=str, help="NUMA CPU node", default="0")
    parser.add_argument("--bench_name", type=str, help="Benchmark name")
    parser.add_argument("--bench_threads", type=int, help="Number of benchmark threads", default=1)
    parser.add_argument("--bench_cmd", type=str, help="Benchmark command")
    parser.add_argument("--bench_args", type=str, help="Benchmark arguments")
    parser.add_argument("--bench_timeout", type=int, help="Benchmark timeout in seconds", default=60)
    parser.add_argument("--perf", type=str, help="Pass perf counters", default="false")
    return parser.parse_args()

if __name__ == "__main__":
    args = parse_args()
    perf_counters = []
    if args.perf.lower() == "true":
        perf_counters = get_perf_counter("")
        
    bench_args = BenchArgs(
        name=args.bench_name,
        command=args.bench_cmd,
        args=args.bench_args.split() if args.bench_args else [],
        bench_threads=args.bench_threads,
        numa_mem=args.numa_mem,
        numa_cpu=args.numa_cpu,
        perf_counters=""
    )

    # "cycles,instructions,cache-references,cache-misses"

    bench_args.print_args()

    benchmark = Benchmark(bench_args)
    benchmark.run()
    
    benchmark.save_report("benchmark_report.json")
