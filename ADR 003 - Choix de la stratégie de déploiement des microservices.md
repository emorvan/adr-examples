ADR 003 - Choix de la stratégie de déploiement des microservices 

**Statut:** Accepté

**Date:**  2025-03-21

**Contexte du projet:** Application back-end B2B en microservices conteneurisés, orchestrés via Kubernetes, avec CI/CD GitLab.


Présents :
 - Thomas
 - Paul
 - Robert

## 1. Contexte ## 
Dans le cadre de notre architecture microservices, chaque service est déployé indépendamment via un pipeline CI/CD automatisé.
Nous devons choisir une stratégie de déploiement pour permettre :

Des mises à jour continues sans interruption de service
Un retour arrière rapide en cas de régression
Une visibilité claire sur la version en production
Un déploiement sécurisé et progressif
Les options considérées :

Rolling Update
Blue/Green Deployment
Canary Deployment


##  2. Décision ## 
Nous adoptons une stratégie de déploiement progressive de type Canary Deployment, combinée à des Rolling Updates sur certains services secondaires moins critiques.

### Détail : ###

- Canary Deployment pour les services critiques : déploiement progressif d’une nouvelle version sur un petit pourcentage de pods (5%, 20%, 50%, 100%) avec monitoring étroit (logs, métriques, erreurs).
- Rolling Update sur les services internes ou non-sensibles (ex : NotificationService), car plus simple à maintenir.
- Possibilité d’évoluer vers Blue/Green Deployment pour certains cas de migration disruptive (changement majeur d’API ou de schéma DB).

##  3. Conséquences ## 

### Avantages : ###

- Canary : Limite les risques, permet d'observer les effets réels de la nouvelle version sur un petit trafic.
- Retour arrière rapide si anomalies détectées.
Compatible avec des outils de progressive delivery (Argo Rollouts, Flagger).
- Meilleur contrôle qualité en production sans arrêt de service.

### Inconvénients : ###

-Mise en œuvre plus complexe qu’un simple rolling update (gestion du routage, métriques, seuils de rollback).
- Nécessite une bonne observabilité (SLO/SLI, alertes en temps réel).
- Nécessite coordination avec les équipes QA/ops pour valider les seuils d’alerte.


##  4. Alternatives rejetées ## 

### Rolling Update Only : ###

- Simple, mais tout le trafic passe immédiatement sur la nouvelle version.
- Risque de propager rapidement un bug en production.
- Pas de visibilité intermédiaire sur l’impact de la release.

### Blue/Green Deployment : ###

- Intéressant pour rollback instantané, mais nécessite le doublement temporaire de l’infrastructure.
- Surcoût en ressources (2 environnements complets) → pas justifié à chaque déploiement.
- Meilleur pour les cas de migration ou refonte, à garder en option ponctuelle.

##  5. Actions à suivre ## 

- Intégrer Canary Deployment dans notre pipeline CI/CD GitLab (via Argo Rollouts ou Flagger)
- Définir des SLIs/SLAs critiques (latence, taux d'erreurs, timeout, CPU/mem)
- Mettre en place un monitoring de canary pods + alertes
- Définir des seuils de rollback automatique
- Documenter la stratégie de déploiement par service (qui est Canary, qui reste Rolling)
