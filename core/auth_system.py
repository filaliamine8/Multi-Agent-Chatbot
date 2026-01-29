"""
SYSTÈME D'AUTHENTIFICATION - Multi-Agent Chatbot
================================================

Gestion de l'authentification par:
- Nom + Prénom
- Mot de passe (hashé en production)
- Email (alternative)
"""

import re
from database_mysql import execute_query, execute_update
import hashlib

def hash_password(password):
    """Hash un mot de passe (simple pour demo, utiliser bcrypt en prod)"""
    return hashlib.sha256(password.encode()).hexdigest()

def verify_password(input_password, stored_hash):
    """Vérifie un mot de passe"""
    return hash_password(input_password) == stored_hash

def find_client_by_name(first_name, last_name):
    """Trouve un client par nom et prénom"""
    query = """
        SELECT * FROM clients 
        WHERE LOWER(first_name) = LOWER(%s) 
        AND LOWER(last_name) = LOWER(%s)
    """
    results = execute_query(query, (first_name, last_name))
    return results[0] if results else None

def find_client_by_email(email):
    """Trouve un client par email"""
    query = "SELECT * FROM clients WHERE LOWER(email) = LOWER(%s)"
    results = execute_query(query, (email,))
    return results[0] if results else None

def authenticate_client(identifier, password):
    """
    Authentifie un client avec:
    - identifier: nom complet, email, ou référence
    - password: mot de passe
    
    Returns: client dict si succès, None sinon
    """
    client = None
    
    # Essayer par email
    if '@' in identifier:
        client = find_client_by_email(identifier)
    # Essayer par référence (13 chiffres)
    elif identifier.isdigit() and len(identifier) == 13:
        query = "SELECT * FROM clients WHERE client_reference = %s"
        results = execute_query(query, (identifier,))
        client = results[0] if results else None
    # Essayer par nom complet "Prénom Nom"
    else:
        parts = identifier.strip().split()
        if len(parts) >= 2:
            first_name = ' '.join(parts[:-1])
            last_name = parts[-1]
            client = find_client_by_name(first_name, last_name)
    
    if not client:
        return None
    
    # Vérifier mot de passe
    # En demo, on accepte un mot de passe simple = username
    # En prod, utiliser verify_password avec hash stocké en DB
    if password == client.get('username') or password == 'demo123':
        return client
    
    return None

def extract_name_from_text(text):
    """
    Extrait nom et prénom d'un texte libre
    
    Examples:
    - "haroun joudi" -> ("haroun", "joudi")
    - "Alice Martin" -> ("alice", "martin")
    - "je m'appelle bob dupont" -> ("bob", "dupont")
    """
    text_lower = text.lower()
    
    # Patterns communs
    patterns = [
        r"(?:je m'appelle|je suis|mon nom est|nom:?)\s+([a-zàâäéèêëïîôùûü]+)\s+([a-zàâäéèêëïîôùûü]+)",
        r"^([a-zàâäéèêëïîôùûü]+)\s+([a-zàâäéèêëïîôùûü]+)$",
    ]
    
    for pattern in patterns:
        match = re.search(pattern, text_lower)
        if match:
            return (match.group(1), match.group(2))
    
    # Fallback: deux mots consécutifs (lettres uniquement)
    words = re.findall(r'[a-zàâäéèêëïîôùûü]+', text_lower)
    if len(words) >= 2:
        return (words[0], words[1])
    
    return None

def create_temp_password_session(client_id):
    """Crée une session temporaire pour authentification mot de passe"""
    # En production, utiliser Redis ou session DB
    # Pour demo, retourner juste un token
    import uuid
    return str(uuid.uuid4())
