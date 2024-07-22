import .app

config = app.App {
    name = "akua-using-kcl"
    version = "0.2"
    environment = "prd"
    team = "payment"
    # min_replicas = 2
    # max_replicas = 3
    containers.guestbook = {
        image = "gcr.io/akua/ks-guestbook-demo:0.2"
        ports = [{containerPort = 80}]
        resources = {
            requests = {memory = "64Mi", cpu = "250m"}
            limits = {memory = "200Mi", cpu = "3000m"}
        }
        health = {
            livenessProbe = {
                httpGet = {
                    path: "/health"
                    port: 80
                }
                initialDelaySeconds = 30
                periodSeconds = 10
            }
        }
    }
    service.ports = [{port = 80}]
    service.type = "LoadBalancer"
}

