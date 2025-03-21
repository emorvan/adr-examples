workspace {

    model {

        group "Toto"{

            customerPerson = person "Customer"
            warehousePerson = person "Warehouse Staff"

            ecommerceSystem = softwareSystem "E-Commerce" {
                storeContainer = container "Store SPA" "E-Commerce Store" "React" "Browser,Microsoft Azure - Static Apps,Azure"
                stockContainer = container "Stock Management SPA" "Order fufillment, stock management, order dispatch" "React" "Browser,Microsoft Azure - Static Apps,Azure"
                dbContainer = container "Database" "Customers, Orders, Payments" "SQL Server" "Database,Microsoft Azure - Azure SQL,Azure"
                apiContainer = container "API" "Backend" "ASP.NET Core" "Microsoft Azure - App Services,Azure" {
                    group "Web Layer" {
                        policyComp = component "Authorization Policy" "Authentication and authorization" "ASP.NET Core"
                        controllerComp = component "API Controller" "Requests, responses, routing and serialisation" "ASP.NET Core"
                        mediatrComp = component "MediatR" "Provides decoupling of requests and handlers" "MediatR"
                    }
                    group "Application Layer" {
                        commandHandlerComp = component "Command Handler" "Business logic for changing state and triggering events" "MediatR request handler"
                        queryHandlerComp = component "Query Handler" "Business logic for retrieving data" "MediatR request handler"
                        commandValidatorComp = component "Command Validator" "Business validation prior to changing state" "Fluent Validation"
                    }
                    group "Infrastructure Layer" {
                        dbContextComp = component "DB Context" "ORM - Maps linq queries to the data store" "Entity Framework Core"
                    }
                    group "Domain Layer" {
                        domainModelComp = component "Model" "Domain models" "poco classes"
                    }
                }
            }
        }

        emailSystem = softwareSystem "Email System" "Sendgrid" "External"

        # relationships between people and software systems 
        customerPerson -> storeContainer "Placers Orders" "https"
        warehousePerson -> stockContainer "Dispatches Orders" "https"
        apiContainer -> emailSystem "Trigger emails" "https"
        emailSystem -> customerPerson "Delivers emails" "https"
        
        # relationships to/from containers
        stockContainer -> apiContainer "uses" "https"
        storeContainer -> apiContainer "uses" "https"
        apiContainer -> dbContainer "persists data" "https"

        # relationships to/from components
        dbContextComp -> dbContainer "stores and retrieves data"
        storeContainer -> controllerComp "calls"
        stockContainer -> controllerComp "calls"
        controllerComp -> policyComp "authenticated and authorized by"
        controllerComp -> mediatrComp "sends queries & commands to"
        mediatrComp -> queryHandlerComp "sends query to"
        mediatrComp -> commandValidatorComp "sends command to"
        commandValidatorComp -> commandHandlerComp "passes command to"
        queryHandlerComp -> dbContextComp "Gets data from"
        commandHandlerComp -> dbContextComp "Update data in"
        dbContextComp -> domainModelComp "contains collections of"
    }

    deployment {

        node "Azure Web App" {
            description "Host for API backend"
            container apiContainer
        }

        node "Azure Static Web App" {
            description "Host for E-Commerce Store and Stock Management SPA"
            container storeContainer
            container stockContainer
        }

        node "Azure SQL Database" {
            description "Host for Database (Customers, Orders, Payments)"
            container dbContainer
        }

        node "Azure Service Bus" {
            description "Service bus for communication with external systems"
        }

    }

    views {

        systemContext ecommerceSystem "Context" {
            include * emailSystem
            autoLayout
        }

        container ecommerceSystem "Container" {
            include *
            autoLayout
        }

        component apiContainer "Component" {
            include * customerPerson warehousePerson
            autoLayout
        }

        deployment "Deployment" {
            include * Azure Web App Azure Static Web App Azure SQL Database Azure Service Bus
            autoLayout
        }

        themes default "https://static.structurizr.com/themes/microsoft-azure-2021.01.26/theme.json"

        styles {
            # default overrides
            element "Azure" {
                color #ffffff
                #stroke #438dd5
            }
            element "External" {
                background #999999
                color #ffffff
            }
            element "Database" {
                shape Cylinder
            }
            element "Browser" {
                shape WebBrowser
            }
            element "Web App" {
                shape RoundedBox
                background #f0f0f0
            }
            element "Static Web App" {
                shape WebBrowser
            }
            element "Service Bus" {
                shape Cloud
                background #00A9C2
            }
        }
    }
}