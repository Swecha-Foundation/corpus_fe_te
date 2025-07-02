#!/bin/bash
# Complete Category Automation Project Setup Script

echo "🚀 Setting up Category Automation Project..."

# Create main directory structure
mkdir -p category-automation/{src,scripts,data/logs,tests,docs/screenshots,examples}

cd category-automation

# Create __init__.py files
touch src/__init__.py
touch tests/__init__.py

# Create placeholder files
touch data/logs/.gitkeep

echo "📁 Directory structure created!"

# Create requirements.txt
cat > requirements.txt << 'EOF'
requests>=2.31.0
python-dotenv>=1.0.0
pytest>=7.4.0
colorama>=0.4.6
tabulate>=0.9.0
EOF

# Create .env.example
cat > .env.example << 'EOF'
# API Configuration
API_BASE_URL=https://backend2.swecha.org/api/v1
AUTH_TOKEN=your_jwt_token_here

# Request Settings
REQUEST_TIMEOUT=30
REQUEST_DELAY=0.5
MAX_RETRIES=3

# Logging
LOG_LEVEL=INFO
LOG_FILE=data/logs/category_automation.log
ENABLE_CONSOLE_LOGGING=true

# Data Files
CATEGORIES_DATA_FILE=data/categories.json
SAMPLE_RESPONSE_FILE=data/sample_response.json
EOF

# Create .gitignore
cat > .gitignore << 'EOF'
# Environment files
.env
*.env

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# Virtual environments
env/
venv/
ENV/
env.bak/
venv.bak/

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# Logs
*.log
logs/
data/logs/*.log

# OS
.DS_Store
Thumbs.db

# Testing
.coverage
htmlcov/
.tox/
.cache
nosetests.xml
coverage.xml
*.cover
.hypothesis/
.pytest_cache/

# Jupyter Notebook
.ipynb_checkpoints

# pyenv
.python-version
EOF

echo "📄 Configuration files created!"

# Create README.md
cat > README.md << 'EOF'
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
EOF

echo "📚 README.md created!"

echo "✅ Project setup complete!"
echo ""
echo "Next steps:"
echo "1. cd category-automation"
echo "2. python -m venv venv"
echo "3. Activate virtual environment:"
echo "   Windows: venv\\Scripts\\activate"
echo "   macOS/Linux: source venv/bin/activate"
echo "4. pip install -r requirements.txt"
echo "5. cp .env.example .env"
echo "6. Edit .env and add your AUTH_TOKEN"
echo "7. Run: python src/category_manager.py"