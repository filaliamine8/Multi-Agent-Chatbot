import os
import signal
import subprocess
import time
import sys

def kill_process_on_port(port):
    print(f"Checking for processes on port {port}...")
    try:
        # Run netstat to find PID
        result = subprocess.check_output(f"netstat -ano | findstr :{port}", shell=True).decode()
        lines = result.strip().split('\n')
        for line in lines:
            if "LISTENING" in line:
                parts = line.split()
                pid = parts[-1]
                print(f"Killing PID {pid} on port {port}...")
                subprocess.call(f"taskkill /F /PID {pid}", shell=True)
                return True
    except subprocess.CalledProcessError:
        pass # No process found
    return False

def start_server():
    print("Starting server.py...")
    print("--------------------------------------------------")
    print("LOGS ACTIFS : Vous verrez les messages ici.")
    print("Faites CTRL+C pour arrêter.")
    print("--------------------------------------------------")
    # Using subprocess.run keeps the process ATTACHED to this terminal
    # So you can see print() statements and errors
    try:
        subprocess.run([sys.executable, "server.py"])
    except KeyboardInterrupt:
        print("\nStopping server...")

if __name__ == "__main__":
    kill_process_on_port(5000)
    time.sleep(1)
    start_server()
