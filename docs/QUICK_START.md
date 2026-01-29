# 📋 Quick Reference - Multi-Agent Chatbot

## 🚀 Getting Started (5 Minutes)

### Start the System
```bash
# 1. Start MySQL
docker-compose up -d

# 2. Run server
python server.py

# 3. Open browser
http://localhost:5000
```

### Run Tests
```bash
python tests/test_all_scenarios.py
```

## 📁 Where to Find Things

| What you need | Location |
|---------------|----------|
| **Start server** | `python server.py` |
| **Main agents** | `agents/sales_robust.py`, `agents/support_robust.py` |
| **Database functions** | `core/database_mysql.py` (17 functions) |
| **Test scenarios** | `tests/scenarios.json` |
| **Run tests** | `tests/test_all_scenarios.py` |
| **Test results** | `evidence/evidence_test_*.json` |
| **All documentation** | `docs/` folder |
| **Installation guide** | `docs/INSTALL.md` |
| **Architecture docs** | `docs/ARCHITECTURE_ADVANCED.md` |
| **Chat interface** | `templates/index.html` |

## 🔧 Common Tasks

### Add a New Test Scenario

1. Edit `tests/scenarios.json` - Add new scenario
2. Edit `tests/test_all_scenarios.py` - Add to `french_scenarios` list
3. Run: `python tests/test_all_scenarios.py`
4. Check results in `evidence/` folder

### Add a New Database Function

1. Add function to `core/database_mysql.py`
2. Register as tool in `agents/sales_robust.py` or `support_robust.py`
3. Add to agent's `self.tools` list
4. Document in `config/database_functions.md`
5. Test with a scenario

### Modify Agent Behavior

- Edit prompts in `agents/sales_robust.py` (system_msg variable)
- Edit prompts in `agents/support_robust.py` (system_msg variable)
- Change rules, examples, or guidelines

### Check System Health

```bash
curl http://localhost:5000/api/health
```

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| Port 5000 in use | `taskkill /F /IM python.exe` (Windows) |
| MySQL not connecting | `docker ps` to check container |
| Groq API error | Check `.env` has `GROQ_API_KEY` |
| Tests failing | Ensure server is running first |
| Import errors | Check you're in project root |

## 📊 Project Statistics

- **Agents**: 3 files (sales, support, orchestrator)
- **DB Functions**: 17 total
- **Test Scenarios**: 15 (100% passing)
- **Documentation**: 17 MD files
- **Languages**: Python, SQL, JavaScript
- **Framework**: Flask + LangChain

## 📚 Documentation Index

| Document | Purpose |
|----------|---------|
| `README.md` | Complete overview & installation |
| `docs/PROJECT_STRUCTURE.md` | Directory organization |
| `docs/ARCHITECTURE_ADVANCED.md` | System architecture |
| `docs/INSTALL.md` | Detailed installation |
| `docs/VALIDATION_FINALE.md` | Latest test results |
| `docs/EVIDENCE_PACKAGE.md` | Evidence for submission |
| `config/database_functions.md` | All 17 DB functions |
| `config/agent_scenarios.md` | 30+ test scenarios |

## 🎯 Key Commands

```bash
# Development
python server.py                      # Start server
python tests/test_all_scenarios.py    # Run tests
docker-compose up -d                  # Start MySQL
docker-compose down                   # Stop MySQL

# Database
docker exec -i mysql-ecommerce mysql -uroot -proot ecommerce < ecommerce.sql

# Testing
curl -X POST http://localhost:5000/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"bonjour"}'
```

## ✅ System Checklist

Before deploying, ensure:
- [ ] `.env` file has `GROQ_API_KEY`
- [ ] MySQL Docker container running
- [ ] Database imported (`ecommerce.sql`)
- [ ] All tests pass (15/15)
- [ ] Server starts without errors
- [ ] Chat interface loads at `localhost:5000`

---

**Last Updated**: 2026-01-29  
**Status**: Production Ready ✅
