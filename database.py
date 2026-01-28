import sqlite3
import os

DB_NAME = "ecommerce.db"

def init_db():
    if os.path.exists(DB_NAME):
        os.remove(DB_NAME)
        
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()
    
    # 1. Products
    cursor.execute('''
    CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT,
        price REAL,
        stock INTEGER,
        promo_code TEXT
    )
    ''')
    
    # 2. Clients
    cursor.execute('''
    CREATE TABLE clients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        email TEXT,
        password_hash TEXT
    )
    ''')
    
    # 3. Orders
    cursor.execute('''
    CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        client_id INTEGER,
        status TEXT,
        total_amount REAL,
        items TEXT,
        FOREIGN KEY(client_id) REFERENCES clients(id)
    )
    ''')
    
    # Seed Data
    products = [
        ('iPhone 15', 'Smartphone', 999.99, 10, 'APPLE10'),
        ('Samsung Galaxy S24', 'Smartphone', 899.99, 15, 'SAM20'),
        ('MacBook Pro M3', 'Laptop', 1999.99, 5, 'MAC5'),
        ('Sony WH-1000XM5', 'Headphones', 349.99, 20, 'SONY15'),
        ('Nike Air Jordan', 'Clothing', 120.00, 50, 'NIKE10')
    ]
    cursor.executemany('INSERT INTO products (name, category, price, stock, promo_code) VALUES (?, ?, ?, ?, ?)', products)
    
    clients = [
        ('alice', 'alice@example.com', 'hashed_pw_1'),
        ('bob', 'bob@example.com', 'hashed_pw_2')
    ]
    cursor.executemany('INSERT INTO clients (username, email, password_hash) VALUES (?, ?, ?)', clients)
    
    orders = [
        (1, 'Shipped', 1119.99, 'iPhone 15, Case'),
        (1, 'Processing', 349.99, 'Sony WH-1000XM5'),
        (2, 'Delivered', 120.00, 'Nike Air Jordan')
    ]
    cursor.executemany('INSERT INTO orders (client_id, status, total_amount, items) VALUES (?, ?, ?, ?)', orders)
    
    conn.commit()
    conn.close()
    print(f"Database {DB_NAME} initialized successfully with seed data.")

if __name__ == "__main__":
    init_db()
