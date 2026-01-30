# Système Multi-Agents pour E-Commerce

Chatbot utilisant des agents spécialisés, dans un contexte d'un site e-commerce de vente d'appareils électroniques, avec intégration base de données temps réel.

JOUDI Haroun, FILALI Amine, OUAD Mouad

---

## Résumé du Système

Ce projet implémente un système multi-agents pour le service client e-commerce. Trois agents spécialisés collaborent pour traiter les requêtes utilisateur:

- **Agent Ventes** (5 outils DB): Recherche produits, stock, prix, promotions, avis
- **Agent Support** (7 outils DB): Gestion commandes, livraisons, factures, garanties, SAV
- **Orchestrateur**: Analyse l'intention et route vers l'agent approprié

Le système utilise **LangChain** avec le modèle **Llama 3.3 70B** (via Groq), une base **MariaDB**, et expose une API REST via **Flask**.

---

![Demo screenshot](screenshots/example1.png)

Pour plus d'exemples, regarder le dossier [screenshots/](screenshots) 

## Installation Rapide

### Méthode 1: Installation Standard

Requires make

```bash

# Installation complète
make install                # Installer dépendances Python
make setup                  # Démarrer base de données + vérifier schéma

# Configuration
echo "GROQ_API_KEY=votre_cle_ici" > .env

# Démarrage
make serve                  # Lancer le serveur

# Accès
# Interface: http://localhost:5000
# phpMyAdmin: http://localhost:3009
```

---

## Installation Manuelle

Si Make n'est pas disponible:

```bash
# 1. Installer dépendances Python
pip install -r requirements.txt

# 2. Démarrer conteneurs Docker
docker Scompose up -d

# 3. Attendre initialisation MySQL (10 secondes)

# 4. Initialiser base de données
docker exec -i chatbot_mariadb mariadb -uroot ecommerce < ecommerce.sql

# 5. Configurer clé API
echo "GROQ_API_KEY=votre_cle_ici" > .env

# 6. Démarrer serveur
python server.py
```

---

```bash
make fresh
```

**Attention:** Cette commande supprime TOUTES les données de la base existante. Utilisez-la uniquement pour:
- Premier démarrage du projet
- Réinitialisation complète après erreurs
- Nettoyage pour tests


---

## Architecture Système

### Vue d'Ensemble

Le système suit une architecture à couches avec séparation claire des responsabilités.

```mermaid
graph TB
    subgraph Interface["Couche Interface"]
        U[Utilisateur<br/>Requête texte]
        UI[Interface Web<br/>localhost:5000]
    end
    
    subgraph Serveur["Couche Serveur - server.py"]
        API[API REST<br/>/api/chat<br/>/api/health<br/>/api/clear]
        Hist[Gestionnaire Historique<br/>Contexte conversation<br/>10 derniers messages]
    end
    
    subgraph Orchestration["Couche Orchestration"]
        O[Orchestrateur<br/>orchestrator.py<br/>Analyse intention]
        LLM1[LLM Groq<br/>Llama 3.3 70B<br/>Temperature: 0.1]
    end
    
    subgraph Agents["Couche Agents Spécialisés"]
        direction LR
        SA[Agent Ventes<br/>sales.py<br/>5 outils]
        SU[Agent Support<br/>support.py<br/>7 outils]
    end
    
    subgraph Outils["Couche Accès Données - core/database_mysql.py"]
        direction TB
        subgraph V[Outils Ventes]
            T1[search_products]
            T2[get_product_details]
            T3[check_stock]
            T4[get_promotions]
            T5[get_reviews]
        end
        subgraph S[Outils Support]
            T6[find_client]
            T7[get_orders]
            T8[track_delivery]
            T9[get_invoice]
            T10[check_warranty]
            T11[get_deliveries]
            T12[find_by_email]
        end
    end
    
    subgraph DB_Layer["Couche Persistance"]
        DB[(MariaDB 10.11<br/>Port: 3308<br/>Base: ecommerce)]
        Tables[Tables:<br/>products, clients,<br/>orders, invoices,<br/>warranties, deliveries,<br/>promotions, reviews]
    end
    
    U --> UI
    UI --> API
    API --> Hist
    Hist --> O
    O --> LLM1
    
    LLM1 -->|Ventes| SA
    LLM1 -->|Support| SU
    
    SA --> V
    SU --> S
    
    V --> DB
    S --> DB
    DB --> Tables
    
    style O fill:#4A90E2,color:#fff,stroke:#333,stroke-width:3px
    style SA fill:#7ED321,color:#fff,stroke:#333,stroke-width:3px
    style SU fill:#F5A623,color:#fff,stroke:#333,stroke-width:3px
    style DB fill:#BD10E0,color:#fff,stroke:#333,stroke-width:3px
    style LLM1 fill:#FF6B6B,color:#fff,stroke:#333,stroke-width:2px
```

### Flux de Traitement Complet

Séquence détaillée du traitement d'une requête utilisateur depuis la réception jusqu'à la réponse.

```mermaid
sequenceDiagram
    participant U as Utilisateur
    participant API as API Flask<br/>server.py
    participant Ctx as Context Manager<br/>context_manager.py
    participant O as Orchestrateur<br/>orchestrator.py
    participant LLM as LLM Groq<br/>Llama 3.3 70B
    participant SA as Agent Ventes<br/>sales.py
    participant DB as Base MariaDB<br/>ecommerce
    
    Note over U,DB: Exemple: Recherche produit
    
    U->>API: POST /api/chat<br/>{"message": "smartphones gaming",<br/>"conversation_id": "user123"}
    
    API->>Ctx: get_or_create_context("user123")
    Ctx-->>API: Contexte avec 10 derniers messages
    
    API->>O: process(message, context_id)
    
    O->>LLM: Prompt: Analyse intention<br/>Message: "smartphones gaming"<br/>Contexte: [...]
    LLM-->>O: Intention détectée: VENTES<br/>Domaine: Produits
    
    O->>SA: Transférer à Agent Ventes<br/>Message + Contexte
    
    Note over SA: Sélection outil approprié<br/>search_products
    
    SA->>LLM: Générer paramètres requête<br/>Message: "smartphones gaming"
    LLM-->>SA: Paramètres extraits:<br/>category='Smartphones'<br/>keyword='gaming'<br/>sort_by='performance'
    
    SA->>DB: CALL search_products(<br/>  category='Smartphones',<br/>  keyword='gaming',<br/>  sort='performance'<br/>)
    
    DB-->>SA: Résultats SQL:<br/>[<br/>  {id:1, name:"Samsung S24 Ultra",<br/>   price:1299, stock:15},<br/>  {id:2, name:"iPhone 15 Pro Max",<br/>   price:1399, stock:8}<br/>]
    
    SA->>LLM: Formater réponse française<br/>Données: [produits]<br/>Style: Concis, professionnel
    LLM-->>SA: "Pour gaming: Samsung S24 Ultra<br/>(1299€, 15 en stock) ou<br/>iPhone 15 Pro Max<br/>(1399€, 8 en stock)"
    
    SA-->>O: Retour réponse formatée<br/>+ métadonnées
    O-->>API: {<br/>  response: "...",<br/>  agent: "VENTES",<br/>  trace: [steps]<br/>}
    
    API->>Ctx: Sauvegarder échange<br/>user + assistant messages
    Ctx-->>API: Contexte mis à jour
    
    API-->>U: HTTP 200<br/>{<br/>  "response": "Pour gaming...",<br/>  "agent": "VENTES",<br/>  "conversation_id": "user123"<br/>}
```

### Agents et Outils

| Composant | Agent Ventes | Agent Support |
|-----------|--------------|---------------|
| **Fichier source** | `agents/sales.py` | `agents/support.py` |
| **Modèle LLM** | Llama 3.3 70B (temp: 0.3) | Llama 3.3 70B (temp: 0.2) |
| **Nombre outils** | 5 fonctions database | 7 fonctions database |
| **Domaine métier** | Catalogue, stock, prix, promotions | Commandes, SAV, livraisons, factures |
| **Cas d'usage** | "cherche laptop", "en stock?", "promos" | "commande CMD-123", "où est colis?", "facture" |

---

## Structure du Projet

```
Multi-Agent-Chatbot/
│
├── agents/                         # Agents IA
│   ├── orchestrator.py             #   Routage intelligent basé intention
│   ├── sales.py                    #   Agent ventes (5 outils DB)
│   └── support.py                  #   Agent support (7 outils DB)
│
├── core/                           # Logique métier
│   ├── database_mysql.py           #   17 fonctions accès base données
│   ├── smart_extractor.py          #   Extraction entités (dates, IDs, emails)
│   ├── auth_system.py              #   Authentification clients
│   └── context_manager.py          #   Gestion mémoire conversationnelle
│
├── forms/                          # Gestion formulaires
│   ├── form_manager.py             #   Templates et validation
│   └── secure_forms.py             #   Sécurisation inputs sensibles
│
├── config/                         # Configuration et documentation
│   ├── database_functions.md       #   Catalogue 17 fonctions DB
│   ├── forms_catalog.md            #   Templates formulaires disponibles
│   ├── fallback_strategies.md      #   Stratégies gestion erreurs
│   └── agent_scenarios.md          #   Scénarios test agents
│
├── tests/                          # Tests automatisés
│   ├── test_all_scenarios.py       #   Suite tests (15 scénarios)
│   └── scenarios.json              #   Définitions cas de test
│
│
├── static/                         # Assets frontend
│   ├── css/                        #   Feuilles style
│   └── js/
│       └── script.js               #   Logique interface chat
│
├── templates/                      # Templates HTML
│   └── index.html                  #   Interface principale
│
├── server.py                       # Serveur Flask principal
├── docker-compose.yml              # Configuration Docker services
├── requirements.txt                # Dépendances Python
├── Makefile                        # Commandes automatisation
├── .env                            # Variables environnement (API keys)
└── README.md                       # Cette documentation
```

### Fonctions Base de Données

Le fichier `core/database_mysql.py` contient 17 fonctions organisées par domaine:

**Outils Agent Ventes (5):**

| Fonction | Paramètres | Retour | Description |
|----------|------------|--------|-------------|
| `search_products` | category, keyword, min_price, max_price, sort | liste dicts | Recherche multi-critères avec filtres et tri |
| `get_product_details` | product_id | dict | Informations complètes produit |
| `check_stock` | product_id | dict | Quantité disponible temps réel |
| `get_active_promotions` | - | liste dicts | Promotions en cours avec réductions |
| `get_product_reviews` | product_id | liste dicts | Avis clients et notes moyennes |

**Outils Agent Support (7):**

| Fonction | Paramètres | Retour | Description |
|----------|------------|--------|-------------|
| `find_client_by_reference` | client_ref | dict | Recherche client par référence unique |
| `find_client_by_email` | email | dict | Recherche client par adresse email |
| `get_client_orders` | client_id, limit | liste dicts | Historique commandes client |
| `get_order_details` | order_id | dict | Détails complets commande spécifique |
| `track_delivery` | tracking_number | dict | Statut livraison temps réel |
| `get_invoice` | invoice_id | dict | Détails facture (montants, statut paiement) |
| `check_warranty` | product_id, client_id | dict | Vérification garantie produit |

**Fonctions Générales (5):**

| Fonction | Paramètres | Retour | Description |
|----------|------------|--------|-------------|
| `get_db_connection` | - | Connection | Connexion MySQL/MariaDB |
| `test_connection` | - | bool | Test santé connexion base |
| `get_best_sellers` | limit | liste dicts | Produits plus vendus |
| `get_products_on_promotion` | - | liste dicts | Produits actuellement en promotion |
| `get_client_deliveries` | client_id, limit | liste dicts | Livraisons client |

---

## Tests

### Exécution Tests

```bash
# Via Make
make test

# Manuel
python tests/test_all_scenarios.py
```

### Résultats Actuels

**Statut:** 15 tests sur 15 réussis (100%)

| Catégorie | Nombre Tests | Statut |
|-----------|--------------|--------|
| Requêtes produits (ventes) | 6 | Réussi |
| Requêtes support client | 7 | Réussi |
| Messages généraux/conversation | 2 | Réussi |

### Scénarios Testés

**Tests Ventes:**
- Recherche générique ("smartphones")
- Recherche avec filtres ("laptops gaming moins 1500€")
- Vérification stock produit
- Requête promotions actives
- Recherche multi-critères

**Tests Support:**
- Suivi commande par numéro
- Identification client par référence
- Recherche client par email
- Suivi livraison
- Demande facture
- Vérification garantie

**Tests Généraux:**
- Messages de salutation
- Questions ambiguës
- Gestion erreurs

---

### Métriques Système

| Métrique | Valeur Mesurée | Notes |
|----------|----------------|-------|
| Temps réponse moyen | ~4 secondes | Incluant appel LLM + DB query |
| Taux réussite tests | 100% (15/15) | Tests automatisés |
| Nombre fonctions DB | 17 | 5 ventes + 7 support + 5 générales |
| Précision routage | 100% | Agent correct pour chaque intention |
| Contexte conversation | 10 messages | Mémoire par conversation_id |

### Clés API

- **Groq API Key** (gratuite): https://console.groq.com
  - Créer compte
  - Générer clé API
  - Copier dans `.env`


