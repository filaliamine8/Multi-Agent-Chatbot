-- ========================================
-- COMPREHENSIVE ELECTRONIC STORE DATABASE
-- ========================================

USE ecommerce;

SET FOREIGN_KEY_CHECKS = 0;

-- ========================================
-- 1. USERS (Employee/Admin accounts)
-- ========================================
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255),
    role ENUM('admin', 'manager', 'sales', 'support') DEFAULT 'support',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================
-- 2. CLIENTS (Customers)
-- ========================================
CREATE TABLE IF NOT EXISTS clients (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(20),
    address TEXT,
    city VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100) DEFAULT 'France',
    date_naissance DATE,
    client_type ENUM('particulier', 'professionnel', 'premium') DEFAULT 'particulier',
    points_fidelite INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_client_type (client_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================
-- 3. CATEGORIES
-- ========================================
CREATE TABLE IF NOT EXISTS categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    parent_id INT NULL,
    image_url VARCHAR(255),
    FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================
-- 4. FOURNISSEURS (Suppliers)
-- ========================================
CREATE TABLE IF NOT EXISTS fournisseurs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    contact_name VARCHAR(100),
    email VARCHAR(255),
    phone VARCHAR(20),
    address TEXT,
    city VARCHAR(100),
    country VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================
-- 5. PRODUITS (Products)
-- ========================================
CREATE TABLE IF NOT EXISTS produits (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category_id INT,
    fournisseur_id INT,
    prix_achat DECIMAL(10, 2),
    prix_vente DECIMAL(10, 2) NOT NULL,
    sku VARCHAR(100) UNIQUE,
    barcode VARCHAR(100),
    brand VARCHAR(100),
    model VARCHAR(100),
    warranty_months INT DEFAULT 24,
    image_url VARCHAR(255),
    specifications JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
    FOREIGN KEY (fournisseur_id) REFERENCES fournisseurs(id) ON DELETE SET NULL,
    INDEX idx_category (category_id),
    INDEX idx_price (prix_vente)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================
-- 6. STOCK
-- ========================================
CREATE TABLE IF NOT EXISTS stock (
    id INT AUTO_INCREMENT PRIMARY KEY,
    produit_id INT NOT NULL,
    quantity INT DEFAULT 0,
    reserved INT DEFAULT 0,
    disponible INT GENERATED ALWAYS AS (quantity - reserved) STORED,
    location VARCHAR(100),
    last_restock TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    min_stock INT DEFAULT 5,
    max_stock INT DEFAULT 100,
    FOREIGN KEY (produit_id) REFERENCES produits(id) ON DELETE CASCADE,
    INDEX idx_disponible (disponible)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================
-- 7. COUPONS
-- ========================================
CREATE TABLE IF NOT EXISTS coupons (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    description VARCHAR(255),
    discount_type ENUM('percentage', 'fixed') DEFAULT 'percentage',
    discount_value DECIMAL(10, 2) NOT NULL,
    min_purchase DECIMAL(10, 2) DEFAULT 0,
    max_discount DECIMAL(10, 2),
    usage_limit INT,
    used_count INT DEFAULT 0,
    valid_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valid_until TIMESTAMP NULL,
    active BOOLEAN DEFAULT TRUE,
    INDEX idx_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================
-- 8. PROMOTIONS
-- ========================================
CREATE TABLE IF NOT EXISTS promotions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    promo_type ENUM('flash_sale', 'bundle', 'buy_x_get_y', 'seasonal') DEFAULT 'flash_sale',
    discount_percentage DECIMAL(5, 2),
    start_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_date TIMESTAMP NULL,
    active BOOLEAN DEFAULT TRUE,
    INDEX idx_dates (start_date, end_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================
-- 9. PRODUITS_PROMOTIONS (Many-to-Many)
-- ========================================
CREATE TABLE IF NOT EXISTS produits_promotions (
    produit_id INT,
    promotion_id INT,
    PRIMARY KEY (produit_id, promotion_id),
    FOREIGN KEY (produit_id) REFERENCES produits(id) ON DELETE CASCADE,
    FOREIGN KEY (promotion_id) REFERENCES promotions(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================
-- 10. COMMANDES (Orders)
-- ========================================
CREATE TABLE IF NOT EXISTS commandes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT NOT NULL,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    status ENUM('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded') DEFAULT 'pending',
    total_ht DECIMAL(10, 2),
    total_tva DECIMAL(10, 2),
    total_ttc DECIMAL(10, 2) NOT NULL,
    shipping_cost DECIMAL(10, 2) DEFAULT 0,
    coupon_id INT NULL,
    discount_amount DECIMAL(10, 2) DEFAULT 0,
    shipping_address TEXT,
    billing_address TEXT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE,
    FOREIGN KEY (coupon_id) REFERENCES coupons(id) ON DELETE SET NULL,
    INDEX idx_client (client_id),
    INDEX idx_status (status),
    INDEX idx_date (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================
-- 11. COMMANDE_ITEMS (Order Line Items)
-- ========================================
CREATE TABLE IF NOT EXISTS commande_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    commande_id INT NOT NULL,
    produit_id INT NOT NULL,
    quantity INT NOT NULL,
    prix_unitaire DECIMAL(10, 2) NOT NULL,
    discount_percentage DECIMAL(5, 2) DEFAULT 0,
    total DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (commande_id) REFERENCES commandes(id) ON DELETE CASCADE,
    FOREIGN KEY (produit_id) REFERENCES produits(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================
-- 12. FACTURES (Invoices)
-- ========================================
CREATE TABLE IF NOT EXISTS factures (
    id INT AUTO_INCREMENT PRIMARY KEY,
    commande_id INT NOT NULL,
    facture_number VARCHAR(50) UNIQUE NOT NULL,
    date_emission TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_echeance TIMESTAMP,
    status ENUM('unpaid', 'partial', 'paid', 'overdue', 'cancelled') DEFAULT 'unpaid',
    total_ht DECIMAL(10, 2),
    total_tva DECIMAL(10, 2),
    total_ttc DECIMAL(10, 2) NOT NULL,
    pdf_url VARCHAR(255),
    FOREIGN KEY (commande_id) REFERENCES commandes(id) ON DELETE CASCADE,
    INDEX idx_status (status),
    INDEX idx_date (date_emission)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================
-- 13. MODES_PAIEMENT (Payment Methods)
-- ========================================
CREATE TABLE IF NOT EXISTS modes_paiement (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type ENUM('card', 'transfer', 'direct_debit', 'paypal', 'cash', 'check') NOT NULL,
    active BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================
-- 14. PAIEMENTS (Payments)
-- ========================================
CREATE TABLE IF NOT EXISTS paiements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    facture_id INT NOT NULL,
    mode_paiement_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    transaction_id VARCHAR(100),
    status ENUM('pending', 'success', 'failed', 'refunded') DEFAULT 'pending',
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    FOREIGN KEY (facture_id) REFERENCES factures(id) ON DELETE CASCADE,
    FOREIGN KEY (mode_paiement_id) REFERENCES modes_paiement(id),
    INDEX idx_status (status),
    INDEX idx_date (payment_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================
-- 15. PRELEVEMENTS (Direct Debits)
-- ========================================
CREATE TABLE IF NOT EXISTS prelevements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT NOT NULL,
    iban VARCHAR(34) NOT NULL,
    bic VARCHAR(11),
    mandate_reference VARCHAR(50) UNIQUE NOT NULL,
    mandate_date DATE,
    status ENUM('active', 'suspended', 'cancelled') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================
-- 16. GARANTIES (Warranties)
-- ========================================
CREATE TABLE IF NOT EXISTS garanties (
    id INT AUTO_INCREMENT PRIMARY KEY,
    commande_item_id INT NOT NULL,
    type ENUM('constructeur', 'etendue', 'casse', 'vol') DEFAULT 'constructeur',
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    coverage_details TEXT,
    status ENUM('active', 'expired', 'used', 'cancelled') DEFAULT 'active',
    FOREIGN KEY (commande_item_id) REFERENCES commande_items(id) ON DELETE CASCADE,
    INDEX idx_status (status),
    INDEX idx_dates (start_date, end_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================
-- 17. ASSURANCES (Insurance)
-- ========================================
CREATE TABLE IF NOT EXISTS assurances (
    id INT AUTO_INCREMENT PRIMARY KEY,
    commande_item_id INT NOT NULL,
    policy_number VARCHAR(50) UNIQUE NOT NULL,
    insurance_company VARCHAR(200),
    coverage_type ENUM('vol', 'casse', 'liquide', 'complete') DEFAULT 'complete',
    monthly_premium DECIMAL(10, 2),
    coverage_amount DECIMAL(10, 2),
    start_date DATE NOT NULL,
    end_date DATE,
    status ENUM('active', 'suspended', 'cancelled', 'expired') DEFAULT 'active',
    FOREIGN KEY (commande_item_id) REFERENCES commande_items(id) ON DELETE CASCADE,
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================
-- 18. LIVRAISONS (Deliveries)
-- ========================================
CREATE TABLE IF NOT EXISTS livraisons (
    id INT AUTO_INCREMENT PRIMARY KEY,
    commande_id INT NOT NULL,
    tracking_number VARCHAR(100) UNIQUE,
    carrier VARCHAR(100),
    status ENUM('preparing', 'shipped', 'in_transit', 'out_for_delivery', 'delivered', 'failed') DEFAULT 'preparing',
    shipped_date TIMESTAMP NULL,
    delivery_date TIMESTAMP NULL,
    delivery_address TEXT,
    recipient_name VARCHAR(200),
    signature_required BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (commande_id) REFERENCES commandes(id) ON DELETE CASCADE,
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================
-- 19. RETOURS (Returns)
-- ========================================
CREATE TABLE IF NOT EXISTS retours (
    id INT AUTO_INCREMENT PRIMARY KEY,
    commande_item_id INT NOT NULL,
    reason ENUM('defective', 'wrong_item', 'not_satisfied', 'damaged', 'other') NOT NULL,
    description TEXT,
    status ENUM('requested', 'approved', 'rejected', 'received', 'refunded') DEFAULT 'requested',
    request_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolution_date TIMESTAMP NULL,
    refund_amount DECIMAL(10, 2),
    FOREIGN KEY (commande_item_id) REFERENCES commande_items(id) ON DELETE CASCADE,
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================
-- 20. AVIS (Reviews)
-- ========================================
CREATE TABLE IF NOT EXISTS avis (
    id INT AUTO_INCREMENT PRIMARY KEY,
    produit_id INT NOT NULL,
    client_id INT NOT NULL,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    title VARCHAR(200),
    comment TEXT,
    verified_purchase BOOLEAN DEFAULT FALSE,
    helpful_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (produit_id) REFERENCES produits(id) ON DELETE CASCADE,
    FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE,
    INDEX idx_rating (rating),
    INDEX idx_produit (produit_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================
-- 21. BEST_PRODUCTS (Analytics - Top Products)
-- ========================================
CREATE TABLE IF NOT EXISTS best_products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    produit_id INT NOT NULL,
    total_sold INT DEFAULT 0,
    revenue DECIMAL(12, 2) DEFAULT 0,
    avg_rating DECIMAL(3, 2),
    review_count INT DEFAULT 0,
    month DATE NOT NULL,
    FOREIGN KEY (produit_id) REFERENCES produits(id) ON DELETE CASCADE,
    UNIQUE KEY unique_product_month (produit_id, month),
    INDEX idx_revenue (revenue DESC),
    INDEX idx_sold (total_sold DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;

-- ========================================
-- SEED DATA
-- ========================================

-- Users (Employees)
INSERT INTO users (username, email, password_hash, role) VALUES
('admin', 'admin@electrostore.fr', 'hash_admin_123', 'admin'),
('marie_manager', 'marie@electrostore.fr', 'hash_marie_456', 'manager'),
('jean_sales', 'jean@electrostore.fr', 'hash_jean_789', 'sales'),
('sophie_support', 'sophie@electrostore.fr', 'hash_sophie_012', 'support');

-- Clients
INSERT INTO clients (username, email, password_hash, first_name, last_name, phone, address, city, postal_code, country, date_naissance, client_type, points_fidelite) VALUES
('alice_martin', 'alice.martin@gmail.com', 'hash_alice', 'Alice', 'Martin', '+33612345678', '12 Rue de la Paix', 'Paris', '75001', 'France', '1990-05-15', 'premium', 1250),
('bob_dupont', 'bob.dupont@yahoo.fr', 'hash_bob', 'Robert', 'Dupont', '+33623456789', '45 Avenue des Champs', 'Lyon', '69001', 'France', '1985-08-22', 'particulier', 340),
('claire_bernard', 'claire@entreprise.com', 'hash_claire', 'Claire', 'Bernard', '+33634567890', '78 Boulevard Haussmann', 'Marseille', '13001', 'France', '1992-12-03', 'professionnel', 850),
('david_roux', 'david.roux@hotmail.com', 'hash_david', 'David', 'Roux', '+33645678901', '23 Rue Victor Hugo', 'Toulouse', '31000', 'France', '1988-03-17', 'particulier', 120),
('emma_petit', 'emma.petit@gmail.com', 'hash_emma', 'Emma', 'Petit', '+33656789012', '56 Rue de Rivoli', 'Nice', '06000', 'France', '1995-07-29', 'premium', 2100),
('francois_girard', 'francois@email.fr', 'hash_francois', 'François', 'Girard', '+33667890123', '89 Avenue Foch', 'Nantes', '44000', 'France', '1982-11-08', 'particulier', 450);

-- Categories
INSERT INTO categories (name, description, parent_id) VALUES
('Smartphones', 'Téléphones mobiles et accessoires', NULL),
('Ordinateurs', 'PC portables et de bureau', NULL),
('Audio', 'Casques, enceintes et audio', NULL),
('Photo & Vidéo', 'Appareils photo et caméras', NULL),
('Gaming', 'Consoles et accessoires gaming', NULL),
('Wearables', 'Montres connectées et trackers', NULL),
('Smart Home', 'Maison connectée', NULL),
('Accessoires', 'Accessoires électroniques', NULL);

-- Sub-categories
INSERT INTO categories (name, description, parent_id) VALUES
('iPhone', 'Smartphones Apple', 1),
('Android', 'Smartphones Android', 1),
('PC Portable', 'Ordinateurs portables', 2),
('PC Bureau', 'Ordinateurs de bureau', 2),
('Casques', 'Casques audio', 3),
('Enceintes', 'Enceintes Bluetooth', 3);

-- Fournisseurs
INSERT INTO fournisseurs (name, contact_name, email, phone, address, city, country) VALUES
('Apple France', 'Jean Dupuis', 'contact@apple.fr', '+33140400000', '9 Rue Porte de Bagneux', 'Paris', 'France'),
('Samsung Europe', 'Marie Schmidt', 'info@samsung.eu', '+33155550000', 'Tour Samsung', 'Lyon', 'France'),
('Sony Distribution', 'Pierre Leclerc', 'sales@sony.fr', '+33144440000', '25 Rue de la Gare', 'Marseille', 'France'),
('Dell Technologies', 'Laura Rossi', 'orders@dell.fr', '+33133330000', '34 Avenue Tech', 'Nantes', 'France'),
('Bose SARL', 'Michel Bernard', 'contact@bose.fr', '+33122220000', '12 Rue Audio', 'Nice', 'France');

-- Produits (40+ products)
INSERT INTO produits (name, description, category_id, fournisseur_id, prix_achat, prix_vente, sku, brand, model, warranty_months, specifications) VALUES
-- Smartphones
('iPhone 15 Pro Max 256GB', 'Dernier iPhone avec puce A17 Pro', 1, 1, 950.00, 1299.99, 'APL-IP15PM-256', 'Apple', 'iPhone 15 Pro Max', 24, '{"screen": "6.7 inch", "storage": "256GB", "camera": "48MP"}'),
('iPhone 15 128GB', 'iPhone 15 version standard', 1, 1, 700.00, 969.99, 'APL-IP15-128', 'Apple', 'iPhone 15', 24, '{"screen": "6.1 inch", "storage": "128GB", "camera": "48MP"}'),
('Samsung Galaxy S24 Ultra', 'Flagship Samsung avec S Pen', 1, 2, 850.00, 1199.99, 'SAM-S24U-512', 'Samsung', 'Galaxy S24 Ultra', 24, '{"screen": "6.8 inch", "storage": "512GB", "camera": "200MP"}'),
('Samsung Galaxy S24', 'Samsung Galaxy dernière génération', 1, 2, 600.00, 859.99, 'SAM-S24-256', 'Samsung', 'Galaxy S24', 24, '{"screen": "6.2 inch", "storage": "256GB"}'),
('Google Pixel 8 Pro', 'Smartphone Google IA avancée', 1, 2, 650.00, 899.99, 'GOO-PIX8P-256', 'Google', 'Pixel 8 Pro', 24, '{"screen": "6.7 inch", "AI": "Google Tensor G3"}'),
('OnePlus 12', 'Flagship OnePlus performance', 1, 2, 550.00, 799.99, 'ONP-OP12-256', 'OnePlus', 'OnePlus 12', 24, '{"screen": "6.82 inch", "charging": "100W"}'),

-- Laptops
('MacBook Pro M3 14"', 'MacBook Pro puce M3', 2, 1, 1600.00, 2199.99, 'APL-MBP14-M3', 'Apple', 'MacBook Pro 14"', 24, '{"processor": "M3", "ram": "16GB", "storage": "512GB"}'),
('MacBook Air M2', 'MacBook Air léger et puissant', 2, 1, 1000.00, 1399.99, 'APL-MBA-M2', 'Apple', 'MacBook Air', 24, '{"processor": "M2", "ram": "8GB", "storage": "256GB"}'),
('Dell XPS 15', 'PC portable haute performance', 2, 4, 1200.00, 1699.99, 'DEL-XPS15-I9', 'Dell', 'XPS 15', 36, '{"processor": "Intel i9", "ram": "32GB", "gpu": "RTX 4060"}'),
('Dell XPS 13', 'Ultrabook compact et puissant', 2, 4, 900.00, 1299.99, 'DEL-XPS13-I7', 'Dell', 'XPS 13', 36, '{"processor": "Intel i7", "ram": "16GB"}'),
('ASUS ROG Zephyrus', 'PC portable gaming premium', 2, 4, 1400.00, 1999.99, 'ASU-ROGZ-RTX', 'ASUS', 'ROG Zephyrus', 24, '{"processor": "AMD Ryzen 9", "gpu": "RTX 4080"}'),

-- Audio
('Sony WH-1000XM5', 'Casque à réduction de bruit', 3, 3, 280.00, 399.99, 'SON-WH1000XM5', 'Sony', 'WH-1000XM5', 24, '{"noise_cancelling": "yes", "battery": "30h"}'),
('Bose QuietComfort Ultra', 'Casque premium Bose', 3, 5, 320.00, 449.99, 'BOS-QCULT', 'Bose', 'QuietComfort Ultra', 24, '{"noise_cancelling": "yes", "spatial_audio": "yes"}'),
('AirPods Pro 2', 'Écouteurs sans fil Apple', 3, 1, 180.00, 279.99, 'APL-AIRP2', 'Apple', 'AirPods Pro 2', 12, '{"noise_cancelling": "yes", "transparency": "yes"}'),
('Bose SoundLink Revolve+', 'Enceinte portable 360°', 3, 5, 180.00, 269.99, 'BOS-SLRP', 'Bose', 'SoundLink Revolve+', 12, '{"battery": "16h", "waterproof": "yes"}'),
('JBL Charge 5', 'Enceinte Bluetooth puissante', 3, 5, 100.00, 179.99, 'JBL-CHG5', 'JBL', 'Charge 5', 12, '{"battery": "20h", "powerbank": "yes"}'),

-- Photo & Video
('Sony Alpha 7 IV', 'Appareil photo hybride professionnel', 4, 3, 1800.00, 2599.99, 'SON-A7IV', 'Sony', 'Alpha 7 IV', 24, '{"sensor": "33MP", "video": "4K 60fps"}'),
('Canon EOS R6 Mark II', 'Hybride Canon haute performance', 4, 3, 1900.00, 2699.99, 'CAN-R6M2', 'Canon', 'EOS R6 II', 24, '{"sensor": "24MP", "fps": "40fps"}'),
('GoPro Hero 12', 'Caméra action 5.3K', 4, 3, 300.00, 449.99, 'GOP-H12', 'GoPro', 'Hero 12', 12, '{"video": "5.3K", "waterproof": "10m"}'),
('DJI Mini 4 Pro', 'Drone compact 4K', 4, 3, 600.00, 859.99, 'DJI-MIN4P', 'DJI', 'Mini 4 Pro', 12, '{"video": "4K 60fps", "range": "25km"}'),

-- Gaming
('PlayStation 5', 'Console Sony nouvelle génération', 5, 3, 400.00, 549.99, 'SON-PS5', 'Sony', 'PlayStation 5', 24, '{"storage": "825GB SSD", "ray_tracing": "yes"}'),
('Xbox Series X', 'Console Microsoft 4K', 5, 3, 400.00, 549.99, 'MSF-XBSX', 'Microsoft', 'Xbox Series X', 24, '{"storage": "1TB SSD", "fps": "120fps"}'),
('Nintendo Switch OLED', 'Console portable Nintendo', 5, 3, 280.00, 349.99, 'NIN-SWOLED', 'Nintendo', 'Switch OLED', 12, '{"screen": "7 inch OLED", "battery": "9h"}'),
('Steam Deck', 'Console portable PC gaming', 5, 3, 350.00, 469.99, 'VAL-STDK-512', 'Valve', 'Steam Deck', 12, '{"storage": "512GB", "screen": "7 inch"}'),

-- Wearables
('Apple Watch Series 9', 'Montre connectée Apple', 6, 1, 320.00, 449.99, 'APL-AWS9-45', 'Apple', 'Watch Series 9', 12, '{"size": "45mm", "gps": "yes", "cellular": "yes"}'),
('Samsung Galaxy Watch 6', 'Montre Samsung Wear OS', 6, 2, 250.00, 359.99, 'SAM-GW6-44', 'Samsung', 'Galaxy Watch 6', 12, '{"size": "44mm", "battery": "40h"}'),
('Garmin Fenix 7', 'Montre sport GPS', 6, 2, 500.00, 699.99, 'GAR-FEN7', 'Garmin', 'Fenix 7', 24, '{"gps": "multi-band", "battery": "18 days"}'),
('Fitbit Charge 6', 'Bracelet fitness tracker', 6, 2, 100.00, 159.99, 'FIT-CHG6', 'Fitbit', 'Charge 6', 12, '{"heart_rate": "yes", "gps": "yes"}'),

-- Smart Home
('Google Nest Hub Max', 'Écran connecté Google', 7, 2, 150.00, 229.99, 'GOO-NHMAX', 'Google', 'Nest Hub Max', 12, '{"screen": "10 inch", "camera": "yes"}'),
('Amazon Echo Show 10', 'Écran Alexa rotatif', 7, 2, 180.00, 249.99, 'AMZ-ES10', 'Amazon', 'Echo Show 10', 12, '{"screen": "10.1 inch", "rotation": "yes"}'),
('Philips Hue Starter Kit', 'Kit éclairage connecté', 7, 2, 120.00, 179.99, 'PHI-HUEKIT', 'Philips', 'Hue White & Color', 24, '{"bulbs": "3", "bridge": "yes"}'),
('Ring Video Doorbell Pro', 'Sonnette vidéo connectée', 7, 2, 150.00, 229.99, 'RNG-VDBP', 'Ring', 'Doorbell Pro 2', 12, '{"video": "1536p", "poe": "yes"}'),

-- Accessories
('Anker PowerBank 20000mAh', 'Batterie externe rapide', 8, 2, 35.00, 59.99, 'ANK-PB20K', 'Anker', 'PowerCore 20K', 18, '{"capacity": "20000mAh", "ports": "2 USB-C"}'),
('SanDisk microSD 512GB', 'Carte mémoire haute vitesse', 8, 2, 45.00, 79.99, 'SAN-SD512', 'SanDisk', 'Extreme Pro', 24, '{"capacity": "512GB", "speed": "170MB/s"}'),
('Logitech MX Master 3S', 'Souris ergonomique pro', 8, 2, 70.00, 109.99, 'LOG-MXM3S', 'Logitech', 'MX Master 3S', 12, '{"dpi": "8000", "buttons": "7"}'),
('Samsung T7 SSD 2TB', 'SSD externe portable', 8, 2, 140.00, 219.99, 'SAM-T7-2TB', 'Samsung', 'T7', 36, '{"capacity": "2TB", "speed": "1050MB/s"}'),
('Apple Magic Keyboard', 'Clavier sans fil Apple', 8, 1, 80.00, 119.99, 'APL-MGKB', 'Apple', 'Magic Keyboard', 12, '{"bluetooth": "yes", "battery": "1 month"}'),
('Belkin 3-in-1 Charger', 'Chargeur sans fil multi-appareils', 8, 1, 90.00, 149.99, 'BEL-3N1CHG', 'Belkin', '3-in-1 Stand', 12, '{"wireless": "yes", "devices": "3"}');

-- Stock (all products)
INSERT INTO stock (produit_id, quantity, reserved, location, min_stock, max_stock) VALUES
(1, 25, 3, 'A-12', 5, 50), (2, 40, 5, 'A-13', 10, 80),
(3, 18, 2, 'A-14', 5, 40), (4, 35, 4, 'A-15', 10, 60),
(5, 22, 1, 'A-16', 5, 40), (6, 30, 3, 'A-17', 8, 50),
(7, 15, 2, 'B-01', 3, 30), (8, 28, 4, 'B-02', 5, 50),
(9, 12, 1, 'B-03', 3, 25), (10, 20, 2, 'B-04', 5, 40),
(11, 8, 1, 'B-05', 2, 20), (12, 45, 6, 'C-01', 10, 80),
(13, 38, 4, 'C-02', 8, 70), (14, 60, 8, 'C-03', 15, 100),
(15, 25, 3, 'C-04', 5, 50), (16, 35, 4, 'C-05', 8, 60),
(17, 12, 1, 'D-01', 3, 25), (18, 10, 1, 'D-02', 2, 20),
(19, 18, 2, 'D-03', 4, 35), (20, 14, 1, 'D-04', 3, 30),
(21, 22, 3, 'E-01', 5, 40), (22, 20, 2, 'E-02', 5, 35),
(23, 30, 4, 'E-03', 8, 50), (24, 15, 2, 'E-04', 3, 30),
(25, 28, 3, 'F-01', 6, 50), (26, 32, 4, 'F-02', 8, 60),
(27, 18, 2, 'F-03', 4, 35), (28, 40, 5, 'F-04', 10, 70),
(29, 35, 4, 'G-01', 8, 60), (30, 28, 3, 'G-02', 6, 50),
(31, 50, 6, 'G-03', 12, 80), (32, 42, 5, 'G-04', 10, 70),
(33, 80, 10, 'H-01', 20, 150), (34, 65, 8, 'H-02', 15, 120),
(35, 55, 6, 'H-03', 12, 100), (36, 48, 5, 'H-04', 10, 90),
(37, 70, 8, 'H-05', 15, 120), (38, 45, 5, 'H-06', 10, 80);

-- Coupons
INSERT INTO coupons (code, description, discount_type, discount_value, min_purchase, max_discount, usage_limit, used_count, valid_until) VALUES
('WELCOME10', 'Bienvenue - 10% de réduction', 'percentage', 10.00, 50.00, 50.00, 100, 23, '2026-12-31 23:59:59'),
('TECH20', '20% sur high-tech', 'percentage', 20.00, 200.00, 100.00, 50, 12, '2026-06-30 23:59:59'),
('SUMMER50', '50€ de réduction été', 'fixed', 50.00, 300.00, 50.00, 200, 45, '2026-08-31 23:59:59'),
('PREMIUM15', 'Premium clients - 15%', 'percentage', 15.00, 100.00, 150.00, NULL, 67, NULL),
('FLASH30', 'Flash sale 30%', 'percentage', 30.00, 500.00, 200.00, 30, 8, '2026-02-15 23:59:59'),
('STUDENT20', 'Étudiants - 20€', 'fixed', 20.00, 100.00, 20.00, 500, 134, '2026-12-31 23:59:59');

-- Promotions
INSERT INTO promotions (name, description, promo_type, discount_percentage, start_date, end_date, active) VALUES
('Black Friday 2026', 'Méga promotions Black Friday', 'flash_sale', 40.00, '2026-11-27 00:00:00', '2026-11-30 23:59:59', TRUE),
('Soldes Hiver', 'Soldes d\'hiver électronique', 'seasonal', 25.00, '2026-01-15 00:00:00', '2026-02-15 23:59:59', TRUE),
('Pack Gaming', 'Console + 2 jeux', 'bundle', 15.00, '2026-01-01 00:00:00', '2026-03-31 23:59:59', TRUE),
('Offre Rentrée', 'Spécial rentrée scolaire', 'seasonal', 20.00, '2026-08-15 00:00:00', '2026-09-30 23:59:59', FALSE);

-- Link products to promotions
INSERT INTO produits_promotions (produit_id, promotion_id) VALUES
(1, 2), (2, 2), (3, 2), (4, 2),
(21, 3), (22, 3), (23, 3),
(7, 4), (8, 4), (9, 4), (10, 4);

-- Modes de paiement
INSERT INTO modes_paiement (name, type, active) VALUES
('Carte Bancaire', 'card', TRUE),
('Virement Bancaire', 'transfer', TRUE),
('Prélèvement SEPA', 'direct_debit', TRUE),
('PayPal', 'paypal', TRUE),
('Espèces', 'cash', TRUE),
('Chèque', 'check', TRUE);

-- Commandes (20+ orders)
INSERT INTO commandes (client_id, order_number, status, total_ht, total_tva, total_ttc, shipping_cost, coupon_id, discount_amount, shipping_address, billing_address) VALUES
(1, 'CMD-2026-0001', 'delivered', 2083.33, 416.67, 2500.00, 0.00, 1, 250.00, '12 Rue de la Paix, 75001 Paris', '12 Rue de la Paix, 75001 Paris'),
(2, 'CMD-2026-0002', 'shipped', 333.33, 66.67, 400.00, 5.90, NULL, 0.00, '45 Avenue des Champs, 69001 Lyon', '45 Avenue des Champs, 69001 Lyon'),
(3, 'CMD-2026-0003', 'processing', 1416.67, 283.33, 1700.00, 0.00, 2, 340.00, '78 Boulevard Haussmann, 13001 Marseille', '78 Boulevard Haussmann, 13001 Marseille'),
(1, 'CMD-2026-0004', 'delivered', 916.67, 183.33, 1100.00, 7.50, 4, 165.00, '12 Rue de la Paix, 75001 Paris', '12 Rue de la Paix, 75001 Paris'),
(4, 'CMD-2026-0005', 'confirmed', 625.00, 125.00, 750.00, 5.90, NULL, 0.00, '23 Rue Victor Hugo, 31000 Toulouse', '23 Rue Victor Hugo, 31000 Toulouse'),
(5, 'CMD-2026-0006', 'delivered', 1958.33, 391.67, 2350.00, 0.00, 4, 350.00, '56 Rue de Rivoli, 06000 Nice', '56 Rue de Rivoli, 06000 Nice'),
(2, 'CMD-2026-0007', 'cancelled', 166.67, 33.33, 200.00, 5.90, NULL, 0.00, '45 Avenue des Champs, 69001 Lyon', '45 Avenue des Champs, 69001 Lyon'),
(6, 'CMD-2026-0008', 'processing', 458.33, 91.67, 550.00, 5.90, 6, 20.00, '89 Avenue Foch, 44000 Nantes', '89 Avenue Foch, 44000 Nantes'),
(3, 'CMD-2026-0009', 'delivered', 708.33, 141.67, 850.00, 7.50, NULL, 0.00, '78 Boulevard Haussmann, 13001 Marseille', '78 Boulevard Haussmann, 13001 Marseille'),
(5, 'CMD-2026-0010', 'shipped', 2458.33, 491.67, 2950.00, 0.00, 5, 590.00, '56 Rue de Rivoli, 06000 Nice', '56 Rue de Rivoli, 06000 Nice'),
(1, 'CMD-2026-0011', 'delivered', 375.00, 75.00, 450.00, 5.90, NULL, 0.00, '12 Rue de la Paix, 75001 Paris', '12 Rue de la Paix, 75001 Paris'),
(4, 'CMD-2026-0012', 'processing', 1083.33, 216.67, 1300.00, 7.50, 1, 130.00, '23 Rue Victor Hugo, 31000 Toulouse', '23 Rue Victor Hugo, 31000 Toulouse'),
(2, 'CMD-2026-0013', 'confirmed', 291.67, 58.33, 350.00, 5.90, NULL, 0.00, '45 Avenue des Champs, 69001 Lyon', '45 Avenue des Champs, 69001 Lyon'),
(6, 'CMD-2026-0014', 'shipped', 833.33, 166.67, 1000.00, 5.90, 4, 150.00, '89 Avenue Foch, 44000 Nantes', '89 Avenue Foch, 44000 Nantes'),
(5, 'CMD-2026-0015', 'delivered', 1625.00, 325.00, 1950.00, 0.00, NULL, 0.00, '56 Rue de Rivoli, 06000 Nice', '56 Rue de Rivoli, 06000 Nice');

-- Commande Items
INSERT INTO commande_items (commande_id, produit_id, quantity, prix_unitaire, discount_percentage, total) VALUES
-- Order 1: Alice - iPhone + MacBook
(1, 1, 1, 1299.99, 0, 1299.99),
(1, 7, 1, 2199.99, 0, 2199.99),
-- Order 2: Bob - Headphones
(2, 12, 1, 399.99, 0, 399.99),
-- Order 3: Claire - Dell XPS + accessories
(3, 9, 1, 1699.99, 20, 1359.99),
(3, 35, 1, 109.99, 0, 109.99),
(3, 38, 1, 219.99, 0, 219.99),
-- Order 4: Alice - Apple Watch + AirPods
(4, 25, 1, 449.99, 15, 382.49),
(4, 14, 1, 279.99, 15, 237.99),
-- Order 5: David - PlayStation 5
(5, 21, 1, 549.99, 0, 549.99),
-- Order 6: Emma - Sony Camera + lens
(6, 17, 1, 2599.99, 0, 2599.99),
-- Order 7: Bob - cancelled
(7, 28, 1, 159.99, 0, 159.99),
-- Order 8: François - Echo Show + Hue
(8, 30, 1, 249.99, 0, 249.99),
(8, 31, 1, 179.99, 0, 179.99),
-- Order 9: Claire - GoPro + accessories
(9, 19, 1, 449.99, 0, 449.99),
(9, 33, 1, 59.99, 0, 59.99),
(9, 34, 2, 79.99, 0, 159.98),
-- Order 10: Emma - MacBook Pro + Magic Keyboard
(10, 7, 1, 2199.99, 0, 2199.99),
(10, 37, 1, 119.99, 0, 119.99),
-- Order 11: Alice - Bose speaker
(11, 15, 1, 269.99, 0, 269.99),
-- Order 12: David - Samsung S24 Ultra
(12, 3, 1, 1199.99, 10, 1079.99),
-- Order 13: Bob - Fitbit
(13, 28, 1, 159.99, 0, 159.99),
-- Order 14: François - Nintendo Switch + powerbank
(14, 23, 1, 349.99, 0, 349.99),
(14, 33, 2, 59.99, 0, 119.98),
-- Order 15: Emma - Dell XPS 15 + SSD
(15, 9, 1, 1699.99, 0, 1699.99),
(15, 36, 1, 219.99, 0, 219.99);

-- Factures
INSERT INTO factures (commande_id, facture_number, status, total_ht, total_tva, total_ttc, date_echeance) VALUES
(1, 'FACT-2026-0001', 'paid', 2083.33, 416.67, 2500.00, '2026-02-15 00:00:00'),
(2, 'FACT-2026-0002', 'paid', 333.33, 66.67, 400.00, '2026-02-16 00:00:00'),
(3, 'FACT-2026-0003', 'partial', 1416.67, 283.33, 1700.00, '2026-02-20 00:00:00'),
(4, 'FACT-2026-0004', 'paid', 916.67, 183.33, 1100.00, '2026-02-18 00:00:00'),
(5, 'FACT-2026-0005', 'unpaid', 625.00, 125.00, 750.00, '2026-03-01 00:00:00'),
(6, 'FACT-2026-0006', 'paid', 1958.33, 391.67, 2350.00, '2026-02-17 00:00:00'),
(8, 'FACT-2026-0008', 'unpaid', 458.33, 91.67, 550.00, '2026-02-25 00:00:00'),
(9, 'FACT-2026-0009', 'paid', 708.33, 141.67, 850.00, '2026-02-19 00:00:00'),
(10, 'FACT-2026-0010', 'paid', 2458.33, 491.67, 2950.00, '2026-02-21 00:00:00'),
(11, 'FACT-2026-0011', 'paid', 375.00, 75.00, 450.00, '2026-02-22 00:00:00'),
(12, 'FACT-2026-0012', 'unpaid', 1083.33, 216.67, 1300.00, '2026-03-05 00:00:00'),
(13, 'FACT-2026-0013', 'unpaid', 291.67, 58.33, 350.00, '2026-02-28 00:00:00'),
(14, 'FACT-2026-0014', 'paid', 833.33, 166.67, 1000.00, '2026-02-24 00:00:00'),
(15, 'FACT-2026-0015', 'paid', 1625.00, 325.00, 1950.00, '2026-02-23 00:00:00');

-- Paiements
INSERT INTO paiements (facture_id, mode_paiement_id, amount, transaction_id, status) VALUES
(1, 1, 2500.00, 'TXN-20260115-001', 'success'),
(2, 4, 400.00, 'PP-20260116-123', 'success'),
(3, 1, 1000.00, 'TXN-20260118-045', 'success'),
(4, 1, 1100.00, 'TXN-20260117-098', 'success'),
(6, 3, 2350.00, 'SEPA-20260117-234', 'success'),
(9, 1, 850.00, 'TXN-20260119-156', 'success'),
(10, 1, 2950.00, 'TXN-20260120-289', 'success'),
(11, 4, 450.00, 'PP-20260121-456', 'success'),
(14, 1, 1000.00, 'TXN-20260123-567', 'success'),
(15, 1, 1950.00, 'TXN-20260122-678', 'success');

-- Prélèvements
INSERT INTO prelevements (client_id, iban, bic, mandate_reference, mandate_date, status) VALUES
(1, 'FR7612345678901234567890123', 'BNPAFRPP', 'MAND-ALICE-001', '2025-12-01', 'active'),
(3, 'FR7698765432109876543210987', 'SOGEFRPP', 'MAND-CLAIRE-001', '2025-11-15', 'active'),
(5, 'FR7611112222333344445555666', 'CEPAFRPP', 'MAND-EMMA-001', '2025-10-20', 'active');

-- Garanties
INSERT INTO garanties (commande_item_id, type, start_date, end_date, coverage_details, status) VALUES
(1, 'constructeur', '2026-01-15', '2028-01-15', 'Garantie Apple 2 ans', 'active'),
(2, 'constructeur', '2026-01-15', '2028-01-15', 'Garantie Apple 2 ans', 'active'),
(3, 'constructeur', '2026-01-16', '2028-01-16', 'Garantie Sony 2 ans', 'active'),
(4, 'etendue', '2026-01-18', '2030-01-18', 'Garantie étendue 4 ans Dell', 'active'),
(10, 'constructeur', '2026-01-17', '2028-01-17', 'Garantie Sony 2 ans', 'active');

-- Assurances
INSERT INTO assurances (commande_item_id, policy_number, insurance_company, coverage_type, monthly_premium, coverage_amount, start_date, end_date, status) VALUES
(1, 'ASSU-IP15PM-001', 'AppleCare+ France', 'complete', 12.99, 1299.99, '2026-01-15', '2028-01-15', 'active'),
(2, 'ASSU-MBP-001', 'AppleCare+ France', 'complete', 19.99, 2199.99, '2026-01-15', '2028-01-15', 'active'),
(4, 'ASSU-XPS15-001', 'Dell Premium Support', 'casse', 14.99, 1699.99, '2026-01-18', '2029-01-18', 'active'),
(10, 'ASSU-A7IV-001', 'Sony Imaging Protect', 'vol', 15.99, 2599.99, '2026-01-17', '2028-01-17', 'active');

-- Livraisons
INSERT INTO livraisons (commande_id, tracking_number, carrier, status, shipped_date, delivery_date, delivery_address, recipient_name) VALUES
(1, 'TRACK-FR-001234567', 'Chronopost', 'delivered', '2026-01-16 09:00:00', '2026-01-17 14:30:00', '12 Rue de la Paix, 75001 Paris', 'Alice Martin'),
(2, 'TRACK-FR-002345678', 'Colissimo', 'delivered', '2026-01-17 10:00:00', '2026-01-19 11:15:00', '45 Avenue des Champs, 69001 Lyon', 'Robert Dupont'),
(3, 'TRACK-FR-003456789', 'UPS', 'in_transit', '2026-01-19 08:00:00', NULL, '78 Boulevard Haussmann, 13001 Marseille', 'Claire Bernard'),
(4, 'TRACK-FR-004567890', 'Chronopost', 'delivered', '2026-01-18 11:00:00', '2026-01-19 16:45:00', '12 Rue de la Paix, 75001 Paris', 'Alice Martin'),
(6, 'TRACK-FR-006789012', 'DHL', 'delivered', '2026-01-18 07:00:00', '2026-01-20 10:20:00', '56 Rue de Rivoli, 06000 Nice', 'Emma Petit'),
(9, 'TRACK-FR-009012345', 'Colissimo', 'delivered', '2026-01-20 09:30:00', '2026-01-22 15:00:00', '78 Boulevard Haussmann, 13001 Marseille', 'Claire Bernard'),
(10, 'TRACK-FR-010123456', 'Chronopost', 'shipped', '2026-01-21 08:00:00', NULL, '56 Rue de Rivoli, 06000 Nice', 'Emma Petit'),
(11, 'TRACK-FR-011234567', 'Colissimo', 'delivered', '2026-01-22 10:00:00', '2026-01-24 12:30:00', '12 Rue de la Paix, 75001 Paris', 'Alice Martin'),
(14, 'TRACK-FR-014567890', 'UPS', 'shipped', '2026-01-24 09:00:00', NULL, '89 Avenue Foch, 44000 Nantes', 'François Girard'),
(15, 'TRACK-FR-015678901', 'DHL', 'delivered', '2026-01-23 07:30:00', '2026-01-25 11:00:00', '56 Rue de Rivoli, 06000 Nice', 'Emma Petit');

-- Retours
INSERT INTO retours (commande_item_id, reason, description, status, resolution_date, refund_amount) VALUES
(3, 'not_satisfied', 'Qualité audio pas à la hauteur des attentes', 'refunded', '2026-01-25 00:00:00', 399.99),
(13, 'defective', 'Écran ne s\'allume plus après 2 jours', 'approved', NULL, NULL);

-- Avis (Reviews)
INSERT INTO avis (produit_id, client_id, rating, title, comment, verified_purchase, helpful_count) VALUES
(1, 1, 5, 'Excellent téléphone!', 'Le meilleur iPhone à ce jour. Performance incroyable et appareil photo exceptionnel.', TRUE, 24),
(7, 1, 5, 'MacBook parfait', 'Puissance de la puce M3 impressionnante. Idéal pour le développement.', TRUE, 18),
(12, 2, 4, 'Très bon casque', 'Réduction de bruit excellente, mais un peu cher.', TRUE, 12),
(9, 3, 5, 'Le meilleur laptop', 'Dell XPS 15 est parfait pour le travail pro. Écran magnifique.', TRUE, 31),
(21, 4, 5, 'PS5 géniale', 'Graphismes incroyables et chargements ultra rapides.', TRUE, 45),
(17, 5, 5, 'Caméra professionnelle', 'Sony Alpha 7 IV dépasse toutes mes attentes. Qualité vidéo 4K exceptionnelle.', TRUE, 38),
(25, 1, 4, 'Bonne montre', 'Apple Watch Series 9 très pratique mais batterie pourrait être meilleure.', TRUE, 15),
(3, 3, 5, 'Samsung au top', 'Galaxy S24 Ultra avec S Pen est parfait pour les notes et créativité.', TRUE, 28),
(14, 1, 5, 'AirPods excellents', 'Qualité audio Apple incomparable. Réduction de bruit top.', TRUE, 22),
(15, 6, 4, 'Bonne enceinte', 'Bose SoundLink son à 360° impressionnant. Batterie longue durée.', FALSE, 9);

-- Best Products (Analytics)
INSERT INTO best_products (produit_id, total_sold, revenue, avg_rating, review_count, month) VALUES
(1, 45, 58499.55, 5.00, 12, '2026-01-01'),
(3, 38, 45599.62, 5.00, 8, '2026-01-01'),
(7, 32, 70399.68, 5.00, 15, '2026-01-01'),
(9, 28, 47599.72, 5.00, 10, '2026-01-01'),
(12, 67, 26799.33, 4.50, 25, '2026-01-01'),
(14, 89, 24909.11, 5.00, 34, '2026-01-01'),
(21, 52, 28599.48, 5.00, 18, '2026-01-01'),
(17, 18, 46799.82, 5.00, 7, '2026-01-01'),
(25, 41, 18449.59, 4.00, 14, '2026-01-01'),
(33, 156, 9358.44, 4.80, 42, '2026-01-01');

-- ========================================
-- SUMMARY
-- ========================================
SELECT 'Database initialized successfully!' AS status;
SELECT COUNT(*) AS total_users FROM users;
SELECT COUNT(*) AS total_clients FROM clients;
SELECT COUNT(*) AS total_products FROM produits;
SELECT COUNT(*) AS total_orders FROM commandes;
SELECT COUNT(*) AS total_invoices FROM factures;
SELECT SUM(total_ttc) AS total_revenue FROM factures WHERE status = 'paid';
