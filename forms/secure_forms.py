# FORMS SÉCURISÉS SUPPLÉMENTAIRES

SECURE_FORMS = {
    # Authentification par mot de passe
    'password_auth': {
        'name': 'password_auth',
        'description': 'Demande de mot de passe pour authentification sécurisée',
        'fields': [{
            'name': 'password',
            'label': "Mot de passe",
            'type': 'password',
            'required': True,
            'prompt': "🔐 Super ! Maintenant, tapez votre mot de passe dans ce champ sécurisé :",
            'validation': {
                'type': 'length',
                'min': 4,
                'error': "Mot de passe incorrect. Réessayez :"
            }
        }]
    },
    
    # Authentification par nom
    'name_auth': {
        'name': 'name_auth',
        'description': 'Demande de nom et prénom pour identification',
        'fields': [{
            'name': 'full_name',
            'label': "Nom complet",
            'type': 'text',
            'required': True,
            'prompt': "📝 Pas grave ! C'est quoi votre nom et prénom ?",
            'validation': {
                'type': 'regex',
                'pattern': r'^[a-zA-ZÀ-ÿ\s]{3,50}$',
                'error': "Veuill ez entrer votre nom et prénom (lettres uniquement)."
            }
        }]
    },
    
    # Paiement par carte
    'card_payment': {
        'name': 'card_payment',
        'description': 'Formulaire de paiement par carte bancaire',
        'fields': [
            {
                'name': 'card_number',
                'label': "Numéro de carte",
                'type': 'card',
                'required': True,
                'prompt': "💳 Tapez vos coordonnées de carte (16 chiffres) :",
                'validation': {
                    'type': 'regex',
                    'pattern': r'^\d{16}$',
                    'error': "Le numéro de carte doit contenir exactement 16 chiffres."
                }
            },
            {
                'name': 'expiry',
                'label': "Date d'expiration",
                'type': 'text',
                'required': True,
                'prompt': "📅 Date d'expiration (MM/AA) :",
                'validation': {
                    'type': 'regex',
                    'pattern': r'^(0[1-9]|1[0-2])/\d{2}$',
                    'error': "Format invalide. Utilisez MM/AA (ex: 12/25)."
                }
            },
            {
                'name': 'cvv',
                'label': "Code CVV",
                'type': 'password',
                'required': True,
                'prompt': "🔒 Code CVV (3 chiffres au dos) :",
                'validation': {
                    'type': 'regex',
                    'pattern': r'^\d{3}$',
                    'error': "Le CVV doit contenir exactement 3 chiffres."
                }
            }
        ]
    }
}
