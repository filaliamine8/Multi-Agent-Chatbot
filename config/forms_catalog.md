# Forms Catalog

## Available Forms

### 1. Client Reference Form
**ID**: `client_reference_form`
**Purpose**: Collect 13-digit client reference
**Fields**:
- `client_reference` (text, regex: `^\d{13}$`)

### 2. Order Number Form
**ID**: `order_number_form`
**Purpose**: Collect order number
**Fields**:
- `order_number` (text, regex: `^CMD-\d{4}-\d{4}$`)

### 3. Email Form
**ID**: `email_form`
**Purpose**: Collect email address
**Fields**:
- `email` (email, regex: email validation)

### 4. Client Name Form
**ID**: `client_name_form`
**Purpose**: Collect full name
**Fields**:
- `full_name` (text, min 3 chars)

### 5. Date Range Form
**ID**: `date_range_form`
**Purpose**: Collect date range
**Fields**:
- `start_date` (date)
- `end_date` (date)

### 6. Product Search Form
**ID**: `product_search_form`
**Purpose**: Collect product search criteria
**Fields**:
- `category` (optional)
- `min_price` (number, optional)
- `max_price` (number, optional)
- `brand` (optional)

### 7. Password Authentication Form
**ID**: `password_auth`
**Purpose**: Secure password input
**Fields**:
- `password` (password, masked)

### 8. Name Authentication Form
**ID**: `name_auth`
**Purpose**: Full name for authentication
**Fields**:
- `full_name` (text, min 5 chars)

### 9. Card Payment Form
**ID**: `card_payment`
**Purpose**: Secure card payment
**Fields**:
- `card_number` (text, 16 digits)
- `expiry` (text, MM/YY format)
- `cvv` (text, 3-4 digits)

---

## Form Flow Examples

### Scenario 1: Check Order Status
1. User: "check my order"
2. Bot: Activates `order_number_form`
3. User: "CMD-2026-0005"
4. Bot: Validates, fetches data, responds

### Scenario 2: Product Search
1. User: "find smartphones"
2. Bot: Activates `product_search_form`
3. User provides category, price range
4. Bot: Searches, displays results

### Scenario 3: Authentication
1. User: "view my orders"
2. Bot: Activates `name_auth`
3. User: "Alice Martin"
4. Bot: Activates `password_auth`
5. User: enters password
6. Bot: Authenticates, displays orders

---

## Form Validation

All forms support:
- Regex validation
- Required/optional fields
- Min/max length
- Custom error messages
- French language prompts
