# Fallback Strategies

## Level 1: Primary Response
Agent attempts to respond using available tools and context.

## Level 2: Missing Data Detection
If parameters are missing:
1. Agent asks clarifying questions
2. Activates appropriate form if needed
3. Stores partial data in context

## Level 3: Database Fallback
If primary function fails:
1. Try alternative lookups (email → reference → name)
2. Search with partial criteria
3. Suggest similar results

## Level 4: Agent Re-routing
If current agent cannot handle:
1. Orchestrator re-evaluates intent
2. Routes to appropriate specialist agent
3. Maintains context during transfer

## Level 5: LLM Direct Response
If no tools work:
1. Use LLM general knowledge
2. Provide estimated/general information
3. Mark response as non-database-backed

## Level 6: Graceful Degradation
If all fails:
1. Acknowledge limitation
2. Offer alternative actions
3. Ask user to rephrase or provide more details
4. Log for improvement

---

## Specific Fallbacks

### Product Search
1. Try exact match
2. Try fuzzy search (keyword)
3. Try category browse
4. Show popular products

### Client Lookup
1. Try reference
2. Try email
3. Try name (fuzzy)
4. Ask for different identifier

### Order Status
1. Try order number
2. Try client context + "last order"
3. Show all client orders
4. Ask for specific order number

### Authentication
1. Try email
2. Try reference
3. Try name matching
4. Request account creation if not found

---

## Error Recovery

### Database Connection Lost
→ Queue requests, use cache, notify user of delay

### Invalid Input
→ Explain format, provide example, activate form

### Ambiguous Request
→ Ask for clarification with options

### No Results
→ Suggest alternatives, broaden search, offer help

---

## Logging

All fallbacks are logged with:
- Original request
- Failed attempt
- Fallback used
- Final outcome
- User satisfaction (implicit)
