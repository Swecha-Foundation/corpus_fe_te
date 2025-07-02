#!/usr/bin/env python3
"""
Cross-platform script runner
Automatically detects Python and runs the main script
"""

import sys
import os
import subprocess

def find_python():
    """Find available Python executable"""
    python_commands = ['python', 'python3', 'py', 'python.exe']
    
    for cmd in python_commands:
        try:
            result = subprocess.run([cmd, '--version'], 
                                  capture_output=True, text=True)
            if result.returncode == 0:
                print(f"✅ Found Python: {cmd}")
                print(f"Version: {result.stdout.strip()}")
                return cmd
        except FileNotFoundError:
            continue
    
    return None

def main():
    print("🔍 Looking for Python installation...")
    
    python_cmd = find_python()
    if not python_cmd:
        print("❌ Python not found!")
        print("Please install Python from https://python.org")
        return
    
    # Get script directory
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_dir = os.path.dirname(script_dir)
    main_script = os.path.join(project_dir, 'src', 'category_manager.py')
    
    if not os.path.exists(main_script):
        print(f"❌ Main script not found: {main_script}")
        return
    
    print(f"🚀 Running: {python_cmd} {main_script}")
    
    try:
        subprocess.run([python_cmd, main_script])
    except KeyboardInterrupt:
        print("\n👋 Script interrupted by user")
    except Exception as e:
        print(f"❌ Error running script: {e}")

if __name__ == "__main__":
    main()