# src/config.py
"""
Configuration settings for the Category Management System
"""

import os
import json
from typing import List, Dict, Any
from pathlib import Path

class Config:
    """Configuration class with all settings"""
    
    # API Configuration
    API_BASE_URL = os.getenv('API_BASE_URL', 'https://backend2.swecha.org/api/v1')
    AUTH_TOKEN = os.getenv('AUTH_TOKEN', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NDk5MDM1MDUsInN1YiI6ImI1ZjYyOTk3LWE1YmUtNDcxNi1iMzk4LWYzOTFmZmQyODE5MyJ9.hCpDbXXh33U-NO99o2imrEEcfIr1z6fTiQZrDaaVyGY')
    
    # Request Configuration
    REQUEST_TIMEOUT = 30
    MAX_RETRIES = 3
    REQUEST_DELAY = 1.0  # Delay between requests in seconds
    
    # Logging Configuration
    LOG_LEVEL = os.getenv('LOG_LEVEL', 'INFO')
    LOG_FILE = 'logs/category_manager.log'
    ENABLE_CONSOLE_LOGGING = True
    
    # Data Configuration
    CATEGORIES_FILE = 'categories.json'
    
    # Load default categories
    DEFAULT_CATEGORIES: List[Dict[str, Any]] = []
    
    @classmethod
    def load_categories(cls):
        """Load categories from JSON file"""
        try:
            # Get the project root directory (where this script is running from)
            current_dir = Path.cwd()
            
            # Try multiple possible locations
            possible_paths = [
                current_dir / cls.CATEGORIES_FILE,  # Current working directory
                Path(__file__).parent.parent / cls.CATEGORIES_FILE,  # Project root (relative to this file)
                current_dir.parent / cls.CATEGORIES_FILE,  # Parent directory
                Path(__file__).parent / cls.CATEGORIES_FILE,  # Same directory as config.py
            ]
            
            categories_path = None
            for path in possible_paths:
                if path.exists():
                    categories_path = path
                    break
            
            if categories_path and categories_path.exists():
                with open(categories_path, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                    cls.DEFAULT_CATEGORIES = data.get('categories', [])
                    print(f"✅ Loaded {len(cls.DEFAULT_CATEGORIES)} categories from {categories_path}")
            else:
                print(f"⚠️  Categories file not found: {cls.CATEGORIES_FILE}")
                print("Searched in the following locations:")
                for path in possible_paths:
                    print(f"   - {path}")
                print("Please ensure categories.json exists in one of these locations")
        except Exception as e:
            print(f"❌ Error loading categories: {e}")
            cls.DEFAULT_CATEGORIES = []
    
    @classmethod
    def print_config(cls):
        """Print current configuration"""
        print("\n⚙️  Current Configuration:")
        print("=" * 40)
        print(f"📡 API Base URL: {cls.API_BASE_URL}")
        print(f"🔐 Auth Token: {'Set' if cls.AUTH_TOKEN else 'Not set'}")
        print(f"⏱️  Request Timeout: {cls.REQUEST_TIMEOUT}s")
        print(f"🔄 Max Retries: {cls.MAX_RETRIES}")
        print(f"⏰ Request Delay: {cls.REQUEST_DELAY}s")
        print(f"📝 Log Level: {cls.LOG_LEVEL}")
        print(f"📁 Log File: {cls.LOG_FILE}")
        print(f"📋 Categories Loaded: {len(cls.DEFAULT_CATEGORIES)}")

# Load categories when module is imported
Config.load_categories()