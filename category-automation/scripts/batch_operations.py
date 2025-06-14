#!/usr/bin/env python3
"""
Batch operations script with menu
Usage: python scripts/batch_operations.py
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from src.category_manager import CategoryManager
from src.config import Config

def show_menu():
    print("\n🔧 Batch Operations Menu")
    print("="*30)
    print("1. 📝 Create all categories")
    print("2. 🔍 View all categories")
    print("3. ⚙️  Show configuration")
    print("4. 🧪 Test API connection")
    print("5. ❌ Exit")
    return input("\nSelect option (1-5): ").strip()

def test_connection():
    """Test API connection"""
    print("\n🧪 Testing API Connection...")
    manager = CategoryManager(Config.API_BASE_URL)
    result = manager.get_categories()
    
    if result["success"]:
        print("✅ API connection successful!")
        print(f"📊 Found {len(result['data'])} categories")
    else:
        print("❌ API connection failed!")
        print(f"Error: {result.get('error', 'Unknown error')}")

def main():
    print("🚀 Category Automation - Batch Operations")
    
    while True:
        choice = show_menu()
        
        if choice == "1":
            auth_token = input("\n🔐 Enter admin token: ").strip()
            if auth_token:
                manager = CategoryManager(Config.API_BASE_URL, auth_token)
                results = manager.create_categories_batch(Config.DEFAULT_CATEGORIES)
                successful = sum(1 for r in results if r["result"]["success"])
                print(f"\n📈 Created {successful}/{len(results)} categories")
            else:
                print("❌ Auth token required!")
                
        elif choice == "2":
            manager = CategoryManager(Config.API_BASE_URL)
            result = manager.get_categories()
            if result["success"]:
                manager.display_categories(result["data"])
            else:
                print(f"❌ Error: {result.get('error')}")
                
        elif choice == "3":
            Config.print_config()
            
        elif choice == "4":
            test_connection()
            
        elif choice == "5":
            print("👋 Goodbye!")
            break
            
        else:
            print("❌ Invalid option! Please select 1-5.")

if __name__ == "__main__":
    main()