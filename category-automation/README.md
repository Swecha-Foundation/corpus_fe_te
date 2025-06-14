# Category Automation

A Python package for automating category management via REST API.

## Features

- ✅ Category creation and retrieval
- ✅ Batch operations for multiple categories  
- ✅ Configuration management
- ✅ Comprehensive error handling and logging
- ✅ Cross-platform compatibility

## Quick Start

### 1. Setup

```bash
# Clone or download the project
cd category-automation

# Create virtual environment (recommended)
python -m venv venv

# Activate virtual environment
# On Windows:
venv\Scripts\activate
# On macOS/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Setup environment variables
cp .env.example .env
# Edit .env and add your AUTH_TOKEN
```

### 2. Usage

```bash
# Run main script
python src/category_manager.py

# Or use quick scripts
python scripts/create_categories.py
python scripts/get_categories.py

# Run with specific Python version
python3 src/category_manager.py
```

### 3. Environment Variables

Edit `.env` file and set:
- `AUTH_TOKEN`: Your JWT authentication token
- `API_BASE_URL`: API base URL (default: https://backend2.swecha.org/api/v1)

## Project Structure

```
category-automation/
├── src/                    # Source code
├── scripts/               # Quick execution scripts
├── data/                  # Data files and logs
├── tests/                 # Test files
├── docs/                  # Documentation
└── examples/              # Usage examples
```

## Troubleshooting

### Python Command Not Found
```bash
# Try these alternatives:
python3 src/category_manager.py
py src/category_manager.py
python.exe src/category_manager.py

# Check Python installation:
python --version
python3 --version
which python
```

### Permission Issues
```bash
# On Unix systems, make scripts executable:
chmod +x scripts/*.py
chmod +x src/category_manager.py
```

## API Reference

The script interacts with the following endpoints:
- `GET /categories/` - Retrieve all categories
- `POST /categories/` - Create new category

## License

MIT License - see LICENSE file for details.
