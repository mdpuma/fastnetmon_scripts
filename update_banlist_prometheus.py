#!/usr/bin/env python3

import subprocess
import time

# Constants
COMMAND = ["/usr/bin/fastnetmon_api_client", "get_banlist"]
EXPORT_PATH = "/tmp/node_exporter/fastnetmon_banned_ips.prom"
METRIC_NAME = "fastnetmon_banned_ip"

def get_banned_ips():
    try:
        result = subprocess.run(COMMAND, capture_output=True, text=True, check=True)
        lines = result.stdout.strip().splitlines()

        # Filter out lines that look like IP addresses
        banned_ips = [line.strip() for line in lines if line.strip() and "." in line]
        return banned_ips

    except subprocess.CalledProcessError as e:
        print(f"Command failed: {e}")
        return []

def write_prometheus_file(banned_ips):
    try:
        lines = [
            f"# HELP {METRIC_NAME} IP addresses banned by FastNetMon",
            f"# TYPE {METRIC_NAME} gauge"
        ]
        timestamp = int(time.time())

        for ip in banned_ips:
            line = f'{METRIC_NAME}{{ip="{ip}"}} 1'
            lines.append(line)

        with open(EXPORT_PATH, "w") as f:
            f.write("\n".join(lines) + "\n")

        print(f"Written {len(banned_ips)} banned IPs to {EXPORT_PATH}")
    except Exception as e:
        print(f"Error writing Prometheus file: {e}")

def main():
    banned_ips = get_banned_ips()
    write_prometheus_file(banned_ips)

if __name__ == "__main__":
    main()
