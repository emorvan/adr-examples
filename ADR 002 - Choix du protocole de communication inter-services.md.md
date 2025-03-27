ADR 002 - Choix du protocole de communication inter-services

Statut : Accepté

Date : 2025-03-21

Contexte du projet : Application de gestion de commandes B2B (architecture microservices déjà validée - cf ADR 001)

Présents :
 - Thomas
 - Paul
 - Robert

## 1. Contexte ## 
Dans notre architecture microservices, les services doivent échanger des informations entre eux pour fonctionner de manière cohérente. Par exemple :

 - Le PanierService doit interagir avec le CatalogueService pour enrichir les produits.
 - Le CommandeService notifie le NotificationService lors de la validation.
 - Le FacturationService attend des événements du CommandeService pour générer une facture.

Nous devons donc définir les protocoles de communication inter-services, en distinguant :

 - Les appels synchrones (requêtes directes, besoin immédiat de réponse)
 - Les communications asynchrones (notifications, événements métier)
 - Les options considérées :

    - HTTP REST
    - gRPC
    - Messaging (Kafka, RabbitMQ, etc.)

##  2. Décision ## 
Nous adoptons une approche hybride, en combinant HTTP REST pour les appels synchrones et Kafka pour les communications asynchrones (event-driven).

## Détail des choix : ##

- HTTP REST (JSON) : utilisé pour les appels simples entre services (lecture de ressources, validation de données, service discovery initial)
- Kafka (event streaming) : utilisé pour propager les événements métiers (ex. : CommandeValidée, FactureGénérée, UtilisateurCréé, etc.)

## Exemples : ##

- POST /commande déclenche un enregistrement via REST, puis publie un événement CommandeValidée dans Kafka.
- Le NotificationService est abonné à cet événement pour réagir sans être couplé au CommandeService.


##  3. Conséquences ## 

## Avantages : ##

    - REST : simple, lisible, facile à tester et documenter (OpenAPI).
    - Kafka : découplage fort, résilience accrue, meilleure scalabilité.
    - Permet de commencer simple avec REST et ajouter Kafka progressivement.
    - Facilite les architectures réactives et la traçabilité des événements.

## Inconvénients : ##

    - REST a des limitations en termes de performance et typage strict.
    - Kafka ajoute de la complexité technique (infrastructure, gestion des topics, monitoring).
    - Double mécanisme à maintenir (REST + Kafka), nécessite une gouvernance claire.


##  4. Alternatives rejetées ## 

## 100% REST : ##

    - Risque de couplage fort entre services
    - Difficulté à gérer les workflows distribués
    - Moins résilient en cas de panne d’un service

## gRPC only : ##

    - Plus performant, mais moins lisible et plus complexe à intégrer à l’écosystème actuel (outillage, debug, documentation)
    - Moins adapté aux communications événementielles
    - Moins accessible pour certaines équipes internes

## 100% messaging (Kafka/RabbitMQ) : ##

    - Très résilient mais moins adapté aux requêtes directes (lecture, validation synchrone)
    - Plus difficile à tester/déboguer au début du projet

##  5. Actions à suivre ## 

    - Normaliser les endpoints REST (OpenAPI + versionnement d’API)
    - Définir une convention de nommage des événements Kafka (<Domaine>.<Action>, ex : Commande.Validée)
    - Intégrer Kafka dans l’observabilité (monitoring, tracing)
    - Implémenter un contrat d’événement clair (JSON Schema ou Avro)
    - Ajouter une stratégie de retry & DLQ (Dead Letter Queue) pour Kafka
