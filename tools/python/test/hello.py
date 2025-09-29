#!/usr/bin/env python3
"""Simple Python test script to verify installation."""

import sys
import platform

def main():
    print("Hello from Python!")
    print(f"Python Version: {sys.version}")
    print(f"Platform: {platform.platform()}")
    print(f"Architecture: {platform.machine()}")
    print(f"Python Implementation: {platform.python_implementation()}")

    # Test some standard libraries
    import json
    import datetime
    import pathlib

    print(f"Current time: {datetime.datetime.now()}")
    print(f"Working directory: {pathlib.Path.cwd()}")
    print("✓ Python test successful!")

if __name__ == "__main__":
    main()