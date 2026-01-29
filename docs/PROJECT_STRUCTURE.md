# Project Structure Documentation

## Directory Organization

```
Multi-Agent-Chatbot/
├── agents/                    # AI Agents (Core Intelligence)
│   ├── sales_robust.py        # Sales agent with 5 DB tools
│   ├── support_robust.py      # Support agent with 7 DB tools
│   ├── orchestrator_robust.py # Intelligent message router
│   └── __pycache__/           # Python cache (gitignored)
│
├── core/                      # Business Logic Layer
│   ├── database_mysql.py      # 17 database functions
│   ├── smart_extractor.py     # Intelligent data extraction
│   ├── auth_system.py         # Authentication system
│   ├── context_manager.py     # Conversation context tracking
│   └── __init__.py            # Package marker
│
├── forms/                     # Form Management
│   ├── form_manager.py        # Form handler and templates
│   ├── secure_forms.py        # Secure input validation
│   └── __init__.py            # Package marker
│
├── config/                    # Configuration & Catalogs
│   ├── database_functions.md  # All 17 DB functions documented
│   ├── forms_catalog.md       # 9 available forms
│   ├── fallback_strategies.md # 6-level error handling
│   └── agent_scenarios.md     # 30+ test scenarios
│
├── docs/                      # Documentation
│   ├── ARCHITECTURE_ADVANCED.md
│   ├── DATABASE_COMPLETE.md
│   ├── INSTALL.md
│   ├── QUICKSTART.md
│   ├── VALIDATION_FINALE.md   # Latest test results
│   ├── PRODUCTION_STATUS.md
│   ├── EVIDENCE_PACKAGE.md
│   └── TEST_RESULTS.md
│
├── tests/                     # Automated Testing
│   ├── test_all_scenarios.py  # Main test suite
│   └── scenarios.json         # 15 test scenarios
│
├── evidence/                  # Test Evidence
│   └── evidence_test_*.json   # Generated test results
│
├── static/                    # Web Assets
│   ├── css/                   # Stylesheets
│   └── js/
│       └── script.js          # Chat interface logic
│
├── templates/                 # HTML Templates
│   └── index.html             # Main chat interface
│
├── db_data/                   # MySQL Docker volume
│   └── ecommerce/             # Database files
│
├── .git/                      # Version control
├── __pycache__/               # Python cache
│
├── server.py                  # Flask API server (main)
├── ecommerce.sql              # MySQL schema & sample data
├── requirements.txt           # Python dependencies
├── docker-compose.yml         # Docker configuration
├── .env                       # Environment variables
├── .gitignore                 # Git ignore rules
└── README.md                  # Main documentation
```

## File Purposes

### Root Files
- **server.py** - Main Flask application (start here!)
- **ecommerce.sql** - Complete MySQL database schema
- **requirements.txt** - All Python dependencies
- **docker-compose.yml** - MySQL + app containerization
- **.env** - Environment configuration (GROQ_API_KEY, MySQL)
- **README.md** - Complete project documentation

### Agents (Intelligence Layer)
- **sales_robust.py** - Handles product queries, recommendations, stock
- **support_robust.py** - Manages orders, returns, complaints
- **orchestrator_robust.py** - Routes messages to correct agent

### Core (Business Logic)
- **database_mysql.py** - All database operations
- **smart_extractor.py** - Extracts entities from user input
- **auth_system.py** - User authentication & verification
- **context_manager.py** - Tracks conversation history

### Forms (Data Collection)
- **form_manager.py** - Manages form templates and validation
- **secure_forms.py** - Secure input forms (password, payment)

### Tests
- **test_all_scenarios.py** - Automated test runner
- **scenarios.json** - Test case definitions

### Evidence
- **evidence_test_*.json** - Timestamped test results showing 100% pass rate

## Data Flow

```
User Message
    ↓
server.py (Flask API)
    ↓
orchestrator_robust.py (Router)
    ↓
┌─────────────┬──────────────┐
│             │              │
sales_robust  support_robust  other
    ↓             ↓
database_mysql.py (17 functions)
    ↓
MySQL Database (Docker)
    ↓
Response back to user
```

## Key Integration Points

1. **Server → Orchestrator**: Routes all messages
2. **Orchestrator → Agents**: Selects sales/support based on intent
3. **Agents → Database**: Call specific tools (search, track, etc.)
4. **Database → MySQL**: Execute queries via mysql-connector
5. **Response → Server → User**: Clean French responses

## Removed Files (Cleanup History)

- ❌ `ecommerce.db` - Old SQLite, now using MySQL
- ❌ `nul` - Temporary file
- ❌ Root duplicates of core/ and forms/ files
- ❌ `agent_tools.py`, `data_repository.py` - Old architecture
- ❌ `conversational_orchestrator.py` - Replaced by robust agents

## File Counts

- **Agents**: 3 files
- **Core**: 4 modules + __init__
- **Forms**: 2 modules + __init__
- **Config**: 4 markdown docs
- **Docs**: 10+ documentation files
- **Tests**: 2 files (script + scenarios)
- **Evidence**: Generated JSON files
- **Total Python**: ~15 core modules

## Maintenance Notes

- Keep `core/`, `forms/`, `agents/` organized
- All MD docs go in `docs/` (except README.md)
- Test files in `tests/`
- Evidence in `evidence/`
- Static web assets in `static/` and `templates/`
- Never commit `__pycache__`, `.env`, `.evidence/`, `db_data/`

---

Last Updated: 2026-01-29
