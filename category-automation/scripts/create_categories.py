#!/usr/bin/env python3
"""
Quick script to create categories
Usage: python scripts/create_categories.py
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from src.category_manager import CategoryManager
from src.config import Config

def main():
    print("🚀 Quick Category Creation Script")
    print("="*40)
    
    # Get auth token
    auth_token = input("🔐 Enter your admin authorization token: ").strip()
    if not auth_token:
        print("❌ Auth token required for category creation!")
        return
    
    # Initialize manager
    manager = CategoryManager(Config.API_BASE_URL, auth_token)
    
    # Create categories
    print(f"\n📝 Creating {len(Config.DEFAULT_CATEGORIES)} categories...")
    results = manager.create_categories_batch(Config.DEFAULT_CATEGORIES)
    
    # Show results
    successful = sum(1 for r in results if r["result"]["success"])
    failed = len(results) - successful
    
    print(f"\n📈 Summary: {successful} successful, {failed} failed")

if __name__ == "__main__":
    main()