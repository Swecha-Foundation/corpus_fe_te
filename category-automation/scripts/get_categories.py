#!/usr/bin/env python3
"""
Quick script to get categories
Usage: python scripts/get_categories.py
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from src.category_manager import CategoryManager
from src.config import Config

def main():
    print("🔍 Quick Categories Retrieval Script")
    print("="*40)
    
    # Initialize manager (no auth needed for GET)
    manager = CategoryManager(Config.API_BASE_URL)
    
    # Get categories
    result = manager.get_categories()
    
    if result["success"]:
        manager.display_categories(result["data"])
    else:
        print(f"❌ Failed to retrieve categories: {result.get('error', 'Unknown error')}")

if __name__ == "__main__":
    main()