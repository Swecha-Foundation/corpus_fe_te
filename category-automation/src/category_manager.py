# src/category_manager.py
"""
Category Management System
Handles category creation, retrieval, and batch operations
"""

import requests
import json
import time
import logging
import os
from datetime import datetime
from typing import List, Dict, Any, Optional
from colorama import init, Fore, Style
from tabulate import tabulate

from config import Config

# Initialize colorama for cross-platform colored output
init(autoreset=True)

class CategoryManager:
    """Main class for managing categories via API"""
    
    def __init__(self, base_url: str, auth_token: Optional[str] = None):
        self.base_url = base_url.rstrip('/')
        self.auth_token = auth_token
        self.session = requests.Session()
        
        # Setup headers
        self.session.headers.update({
            'Content-Type': 'application/json',
            'User-Agent': 'CategoryManager/1.0'
        })
        
        if self.auth_token:
            self.session.headers.update({
                'Authorization': f'Bearer {self.auth_token}'
            })
        
        # Setup logging
        self._setup_logging()
        
        self.logger.info("CategoryManager initialized")
    
    def _setup_logging(self):
        """Setup logging configuration"""
        # Create logs directory if it doesn't exist
        log_dir = os.path.dirname(Config.LOG_FILE)
        if log_dir and not os.path.exists(log_dir):
            os.makedirs(log_dir, exist_ok=True)
        
        # Configure logging
        self.logger = logging.getLogger(__name__)
        self.logger.setLevel(getattr(logging, Config.LOG_LEVEL.upper()))
        
        # File handler
        if Config.LOG_FILE:
            file_handler = logging.FileHandler(Config.LOG_FILE)
            file_handler.setLevel(logging.DEBUG)
            file_formatter = logging.Formatter(
                '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
            )
            file_handler.setFormatter(file_formatter)
            self.logger.addHandler(file_handler)
        
        # Console handler
        if Config.ENABLE_CONSOLE_LOGGING:
            console_handler = logging.StreamHandler()
            console_handler.setLevel(getattr(logging, Config.LOG_LEVEL.upper()))
            console_formatter = logging.Formatter('%(levelname)s - %(message)s')
            console_handler.setFormatter(console_formatter)
            self.logger.addHandler(console_handler)
    
    def _make_request(self, method: str, endpoint: str, data: Dict = None, retries: int = None) -> Dict[str, Any]:
        """Make HTTP request with retry logic"""
        if retries is None:
            retries = Config.MAX_RETRIES
        
        url = f"{self.base_url}/{endpoint.lstrip('/')}"
        
        for attempt in range(retries + 1):
            try:
                self.logger.debug(f"Making {method} request to {url} (attempt {attempt + 1})")
                
                if method.upper() == 'GET':
                    response = self.session.get(url, timeout=Config.REQUEST_TIMEOUT)
                elif method.upper() == 'POST':
                    response = self.session.post(url, json=data, timeout=Config.REQUEST_TIMEOUT)
                else:
                    raise ValueError(f"Unsupported HTTP method: {method}")
                
                # Log response details
                self.logger.debug(f"Response status: {response.status_code}")
                self.logger.debug(f"Response headers: {dict(response.headers)}")
                
                # Handle response
                if response.status_code == 200:
                    try:
                        json_data = response.json()
                        return {"success": True, "data": json_data, "status_code": response.status_code}
                    except json.JSONDecodeError:
                        return {"success": True, "data": response.text, "status_code": response.status_code}
                
                elif response.status_code == 201:
                    try:
                        json_data = response.json()
                        return {"success": True, "data": json_data, "status_code": response.status_code}
                    except json.JSONDecodeError:
                        return {"success": True, "data": "Created successfully", "status_code": response.status_code}
                
                else:
                    error_msg = f"HTTP {response.status_code}: {response.text}"
                    self.logger.warning(error_msg)
                    
                    if attempt < retries:
                        wait_time = (attempt + 1) * Config.REQUEST_DELAY
                        self.logger.info(f"Retrying in {wait_time} seconds...")
                        time.sleep(wait_time)
                        continue
                    
                    return {
                        "success": False, 
                        "error": error_msg, 
                        "status_code": response.status_code
                    }
            
            except requests.exceptions.Timeout:
                error_msg = f"Request timeout after {Config.REQUEST_TIMEOUT} seconds"
                self.logger.error(error_msg)
                if attempt < retries:
                    time.sleep(Config.REQUEST_DELAY)
                    continue
                return {"success": False, "error": error_msg}
            
            except requests.exceptions.ConnectionError:
                error_msg = "Connection error - check your internet connection and API URL"
                self.logger.error(error_msg)
                if attempt < retries:
                    time.sleep(Config.REQUEST_DELAY * 2)
                    continue
                return {"success": False, "error": error_msg}
            
            except Exception as e:
                error_msg = f"Unexpected error: {str(e)}"
                self.logger.error(error_msg)
                return {"success": False, "error": error_msg}
        
        return {"success": False, "error": "Max retries exceeded"}
    
    def get_categories(self) -> Dict[str, Any]:
        """Retrieve all categories"""
        self.logger.info("Retrieving categories...")
        result = self._make_request('GET', '/categories/')
        
        if result["success"]:
            categories = result["data"]
            self.logger.info(f"Successfully retrieved {len(categories)} categories")
        else:
            self.logger.error(f"Failed to retrieve categories: {result.get('error')}")
        
        return result
    
    def create_category(self, category_data: Dict[str, Any]) -> Dict[str, Any]:
        """Create a single category"""
        if not self.auth_token:
            return {"success": False, "error": "Authentication token required for category creation"}
        
        self.logger.info(f"Creating category: {category_data.get('name', 'Unknown')}")
        result = self._make_request('POST', '/categories/', category_data)
        
        if result["success"]:
            self.logger.info(f"Successfully created category: {category_data.get('name')}")
        else:
            self.logger.error(f"Failed to create category {category_data.get('name')}: {result.get('error')}")
        
        return result
    
    def create_categories_batch(self, categories: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Create multiple categories"""
        if not categories:
            print("❌ No categories to create!")
            return []
        
        print(f"\n🚀 Starting batch creation of {len(categories)} categories...")
        results = []
        
        for i, category in enumerate(categories, 1):
            print(f"\n📝 Creating category {i}/{len(categories)}: {category.get('name', 'Unknown')}")
            
            result = self.create_category(category)
            results.append({
                "category": category,
                "result": result
            })
            
            # Show immediate feedback
            if result["success"]:
                print(f"   ✅ Success: {category.get('title', category.get('name'))}")
            else:
                print(f"   ❌ Failed: {result.get('error', 'Unknown error')}")
            
            # Delay between requests
            if i < len(categories):
                time.sleep(Config.REQUEST_DELAY)
        
        return results
    
    def display_categories(self, categories: List[Dict[str, Any]]):
        """Display categories in a formatted table"""
        if not categories:
            print("📭 No categories found!")
            return
        
        print(f"\n📋 Found {len(categories)} categories:")
        print("=" * 80)
        
        # Prepare table data
        table_data = []
        for category in categories:
            table_data.append([
                category.get('rank', 'N/A'),
                category.get('name', 'N/A'),
                category.get('title', 'N/A'),
                category.get('description', 'N/A')[:50] + '...' if len(category.get('description', '')) > 50 else category.get('description', 'N/A'),
                '✅' if category.get('published', False) else '❌'
            ])
        
        # Sort by rank
        table_data.sort(key=lambda x: int(x[0]) if str(x[0]).isdigit() else float('inf'))
        
        headers = ['Rank', 'Name', 'Title', 'Description', 'Published']
        print(tabulate(table_data, headers=headers, tablefmt='grid'))
    
    def display_batch_results(self, results: List[Dict[str, Any]]):
        """Display batch operation results"""
        if not results:
            return
        
        successful = []
        failed = []
        
        for result in results:
            if result["result"]["success"]:
                successful.append(result)
            else:
                failed.append(result)
        
        print("\n📊 Batch Operation Summary")
        print("=" * 40)
        print(f"✅ Successful: {len(successful)}")
        print(f"❌ Failed: {len(failed)}")
        print(f"📈 Success Rate: {len(successful)/len(results)*100:.1f}%")
        
        if failed:
            print("\n❌ Failed Categories:")
            for result in failed:
                category_name = result["category"].get("name", "Unknown")
                error = result["result"].get("error", "Unknown error")
                print(f"   • {category_name}: {error}")

def main():
    """Main function"""
    print(f"{Fore.CYAN}🚀 Category Automation System{Style.RESET_ALL}")
    print("=" * 50)
    
    # Show configuration
    Config.print_config()
    
    # Check if categories are loaded
    if not Config.DEFAULT_CATEGORIES:
        print(f"\n{Fore.YELLOW}⚠️  No categories loaded!{Style.RESET_ALL}")
        print("Please ensure your categories.json file exists and contains valid data.")
        return
    
    print(f"\n{Fore.GREEN}📋 Ready to work with {len(Config.DEFAULT_CATEGORIES)} categories{Style.RESET_ALL}")
    
    # Show menu
    while True:
        print(f"\n{Fore.CYAN}🔧 Main Menu{Style.RESET_ALL}")
        print("-" * 20)
        print("1. 📋 View all existing categories")
        print("2. 📝 Create all categories (requires auth)")
        print("3. ⚙️  Show configuration")
        print("4. 🧪 Test API connection")
        print("5. ❌ Exit")
        
        choice = input(f"\n{Fore.YELLOW}Select option (1-5): {Style.RESET_ALL}").strip()
        
        if choice == "1":
            manager = CategoryManager(Config.API_BASE_URL)
            result = manager.get_categories()
            if result["success"]:
                manager.display_categories(result["data"])
            else:
                print(f"{Fore.RED}❌ Error: {result.get('error')}{Style.RESET_ALL}")
        
        elif choice == "2":
            auth_token = Config.AUTH_TOKEN
            if not auth_token:
                auth_token = input(f"{Fore.YELLOW}🔐 Enter admin token: {Style.RESET_ALL}").strip()
            
            if auth_token:
                manager = CategoryManager(Config.API_BASE_URL, auth_token)
                results = manager.create_categories_batch(Config.DEFAULT_CATEGORIES)
                manager.display_batch_results(results)
            else:
                print(f"{Fore.RED}❌ Auth token required!{Style.RESET_ALL}")
        
        elif choice == "3":
            Config.print_config()
        
        elif choice == "4":
            print(f"\n{Fore.CYAN}🧪 Testing API Connection...{Style.RESET_ALL}")
            manager = CategoryManager(Config.API_BASE_URL)
            result = manager.get_categories()
            if result["success"]:
                print(f"{Fore.GREEN}✅ API connection successful!{Style.RESET_ALL}")
                print(f"📊 Found {len(result['data'])} existing categories")
            else:
                print(f"{Fore.RED}❌ API connection failed!{Style.RESET_ALL}")
                print(f"Error: {result.get('error', 'Unknown error')}")
        
        elif choice == "5":
            print(f"{Fore.GREEN}👋 Goodbye!{Style.RESET_ALL}")
            break
        
        else:
            print(f"{Fore.RED}❌ Invalid option! Please select 1-5.{Style.RESET_ALL}")

if __name__ == "__main__":
    main()