ADR 001 - Choix de l’architecture : Microservices

Statut : Accepté

Date : 2025-03-21

Contexte du projet : Application de gestion de commandes B2B avec des fonctionnalités de catalogue, panier, commande, facturation et notifications.

Présents :
 - Thomas
 - Paul
 - Robert

## 1. Contexte ## 
Nous devons choisir une architecture pour la nouvelle application back-end de gestion de commandes B2B. Le système devra être capable de :

Gérer un grand nombre d'utilisateurs et de commandes simultanément.
Être évolutif pour intégrer de nouvelles fonctionnalités indépendamment.
Faciliter la maintenance, la résilience et la rapidité des déploiements.
Être compatible avec une culture DevOps et CI/CD.
Les alternatives considérées sont :

    - Monolithique modulaire
    - Microservices
    - Architecture hexagonale (dans un monolithe)
    - Serverless / FaaS (non retenue pour des raisons de complexité métier)

##  2. Décision ## 
Nous adoptons une architecture microservices, avec une séparation claire des domaines fonctionnels :

    - CatalogueService : gestion des produits
    - PanierService : gestion du panier client
    - CommandeService : prise de commande et suivi
    - FacturationService : génération de factures
    - NotificationService : envoi d’e-mails et SMS
    - UserService : gestion des comptes utilisateurs

## Chaque microservice sera :  ##

    - Déployé indépendamment (containerisé via Docker & orchestré via Kubernetes)
    - Communiquant via HTTP REST (à court terme) et des événements asynchrones (Kafka) pour les interactions critiques (ex. : Commande → Notification)
    - Stockant ses propres données (Database per Service - PostgreSQL ou MongoDB selon le besoin)
    - Versionné indépendamment et testé de manière autonome

##  3. Conséquences ## 
Avantages :

    -Scalabilité horizontale par service
    -Déploiements indépendants (DevOps friendly)
    -Isolation des pannes et meilleure résilience
    -Facilite le découplage des équipes (team par domaine fonctionnel)
    -Évolution technologique indépendante par service (choix Go, Node.js, Java...)

## Inconvénients :

    - Complexité accrue en termes de gestion d’infrastructure, observabilité, traçabilité
    - Nécessité de gestion des contrats d’API (breaking changes)
    - Complexité des transactions distribuées (compensations, sagas)
    - Montée en charge de la supervision (logs, métriques, tracing)

##  4. Alternatives rejetées ## 

    - Architecture monolithique modulaire : plus simple à court terme, mais moins adaptée à l’évolutivité du projet à moyen/long terme.
    - Architecture hexagonale (monolithe) : trop couplée au déploiement global, pas suffisamment agile pour notre roadmap.
    - Serverless (FaaS) : bien adaptée aux traitements unitaires mais trop complexe pour le besoin transactionnel et les dépendances métier fortes.

##  5. Actions à suivre ## 
    - Définir les premières API contracts (OpenAPI specs) pour chaque service
    - Mettre en place une base CI/CD par microservice
    - Implémenter l’observabilité dès le début (Prometheus, Grafana, OpenTelemetry)
    - Choisir un service mesh léger si besoin de cross-cutting (Istio/Linkerd)
    - Documenter les règles de communication et de versionning inter-services
