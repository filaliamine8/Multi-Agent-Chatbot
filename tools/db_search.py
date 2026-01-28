import sqlite3
import os

DB_NAME = "ecommerce.db"

def get_db_connection():
    conn = sqlite3.connect(DB_NAME)
    conn.row_factory = sqlite3.Row
    return conn

def search_products(query=""):
    """Search for products by name or category."""
    conn = get_db_connection()
    if query:
        products = conn.execute('SELECT * FROM products WHERE name LIKE ? OR category LIKE ?', 
                              ('%' + query + '%', '%' + query + '%')).fetchall()
    else:
        products = conn.execute('SELECT * FROM products').fetchall()
    conn.close()
    return [dict(p) for p in products]

def get_order_status(order_id):
    """Get status of an order."""
    conn = get_db_connection()
    order = conn.execute('SELECT * FROM orders WHERE id = ?', (order_id,)).fetchone()
    conn.close()
    return dict(order) if order else None

def get_client_info(username):
    """Get basic client info."""
    conn = get_db_connection()
    client = conn.execute('SELECT * FROM clients WHERE username = ?', (username,)).fetchone()
    conn.close()
    return dict(client) if client else None
