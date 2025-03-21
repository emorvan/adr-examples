workspace {

    model {
        user = person "Utilisateur B2B" {
            description "Client B2B utilisant l'application de gestion de commandes."
        }

        b2bSystem = softwareSystem "Système de gestion de commandes B2B" {
            description "Back-end microservices pour la gestion des commandes."

            webApp = container "Application Web (Frontend)" {
                technology "Angular/React"
                description "Interface utilisateur utilisée par les clients B2B."
            }

            apiGateway = container "API Gateway / Ingress Controller" {
                technology "NGINX / Traefik / Istio Gateway"
                description "Point d'entrée HTTP vers les microservices REST."
            }

            kafka = container "Kafka Event Bus" {
                technology "Apache Kafka"
                description "Bus d'événements pour la communication asynchrone entre services."
            }

            prometheus = container "Prometheus / Grafana" {
                technology "Monitoring & Observabilité"
                description "Surveillance des métriques et alertes."
            }

            user -> webApp "Utilise via le navigateur"
            webApp -> apiGateway "Fait des appels REST"

            // === Microservices ===
            catalogueService = container "CatalogueService" {
                technology "Spring Boot"
                description "Gère les produits du catalogue."
            }

            panierService = container "PanierService" {
                technology "Spring Boot"
                description "Gère le panier client."
            }

            commandeService = container "CommandeService" {
                technology "Spring Boot"
                description "Prise et suivi des commandes."
            }

            facturationService = container "FacturationService" {
                technology "Spring Boot"
                description "Génère les factures."
            }

            notificationService = container "NotificationService" {
                technology "Node.js"
                description "Envoie des notifications clients."
            }

            userService = container "UserService" {
                technology "Spring Boot"
                description "Gestion des utilisateurs et authentification."
            }

            // === Bases de données (containers séparés) ===
            catalogueDb = container "Catalogue DB" {
                technology "PostgreSQL"
                description "Base de données du catalogue"
            }

            panierDb = container "Panier DB" {
                technology "Redis"
                description "Base de données du panier"
            }

            commandeDb = container "Commande DB" {
                technology "PostgreSQL"
                description "Base de données des commandes"
            }

            factureDb = container "Facturation DB" {
                technology "PostgreSQL"
                description "Base de données de facturation"
            }

            userDb = container "User DB" {
                technology "PostgreSQL"
                description "Base de données des utilisateurs"
            }

            // Relations REST/API
            apiGateway -> catalogueService "Appels REST (produits)"
            apiGateway -> panierService "Appels REST (panier)"
            apiGateway -> commandeService "Appels REST (commandes)"
            apiGateway -> userService "Appels REST (utilisateurs)"

            // Accès bases
            catalogueService -> catalogueDb "Lecture/Écriture"
            panierService -> panierDb "Lecture/Écriture"
            commandeService -> commandeDb "Lecture/Écriture"
            facturationService -> factureDb "Lecture/Écriture"
            userService -> userDb "Lecture/Écriture"

            // Kafka
            commandeService -> kafka "Publie CommandeValidée"
            facturationService -> kafka "Consomme CommandeValidée"
            notificationService -> kafka "Consomme CommandeValidée"
        }

        // === DEPLOYMENT MODEL ===

        deploymentEnvironment "Kubernetes Cluster - Production" {
            deploymentNode "Kubernetes Cluster" {
                deploymentNode "Namespace: b2b" {
                    deploymentNode "Pod: catalogue-service" {
                        containerInstance catalogueService {
                            description "Déployé avec Rolling Update"
                            tags "rolling-update"
                        }
                    }

                    deploymentNode "Pod: panier-service" {
                        containerInstance panierService {
                            description "Déployé avec Rolling Update"
                            tags "rolling-update"
                        }
                    }

                    deploymentNode "Pod: commande-service" {
                        containerInstance commandeService {
                            description "Déployé avec Canary Release via Istio"
                            tags "canary-release"
                        }
                    }

                    deploymentNode "Pod: facturation-service" {
                        containerInstance facturationService {
                            description "Déployé avec Rolling Update"
                            tags "rolling-update"
                        }
                    }

                    deploymentNode "Pod: notification-service" {
                        containerInstance notificationService {
                            description "Déployé avec Rolling Update"
                            tags "rolling-update"
                        }
                    }

                    deploymentNode "Pod: user-service" {
                        containerInstance userService {
                            description "Déployé avec Rolling Update"
                            tags "rolling-update"
                        }
                    }

                    deploymentNode "Pod: api-gateway" {
                        containerInstance apiGateway {
                            description "Déployé avec Rolling Update"
                        }
                    }

                    deploymentNode "Pod: kafka" {
                        containerInstance kafka
                    }

                    deploymentNode "Pod: prometheus/grafana" {
                        containerInstance prometheus
                    }
                }
            }
        }

    }

    views {
        systemContext b2bSystem {
            include *
            autolayout lr
            title "C4 - Niveau 1 : Contexte Système B2B"
        }

        container b2bSystem {
            include *
            autolayout lr
            title "C4 - Niveau 2 : Conteneurs du Système B2B"
        }

        deployment b2bSystem "Kubernetes Cluster - Production" {
            include *
            autolayout lr
            title "C4 - Niveau 4 : Déploiement Kubernetes - Production"
        }

        theme default
    }

}
