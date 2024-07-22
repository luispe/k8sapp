import manifests
import .app

# Convert the `App` model into Kubernetes Manifests
kubernetesRender = lambda a: app.App {
    # Construct the deployment manifest.
    deployment = {
        apiVersion = "apps/v1"
        kind = "Deployment"
        metadata.name = a.name
        metadata.labels = a.labels
        spec = {
            replicas = a.min_replicas
            selector.matchLabels = a.labels
            template.metadata.labels = a.labels
            template.spec.containers = [{
                name = n
                image = c.image
                command = c.command
                args = c.args
                env = c.env
                volumeMounts = c.volumes
                resources: c.resources
                readinessProbe: c.health?.readinessProbe
                livenessProbe: c.health?.livenessProbe
                ports = c.ports
            } for n, c in a.containers]
        }
    }
    # Construct the hpa manifest
    hpa = {
        apiVersion = "autoscaling/v2"
        kind = "HorizontalPodAutoscaler"
        metadata.name = a.name + "-hpa"
        # TODO add metadata.name = a.name + hpa
        spec = {
            scaleTargetRef = {
                apiVersion = "apps/v1"
                kind = "Deployment"
                name = a.name
            }
            minReplicas = a.min_replicas
            maxReplicas = a.max_replicas
            metrics = [
                {
                    type = "Resource"
                    resource = {
                        name = "cpu"
                        target = {
                            type = "Utilization"
                            averageUtilization = 50
                        }
                    }
                }
                {
                    type = "Resource"
                    resource = {
                        name = "memory"
                        target = {
                            type = "Utilization"
                            averageUtilization = 70
                        }
                    }
                }
            ]
            behavior = {
                scaleDown = {
                    stabilizationWindowSeconds = 300
                    policies = [{
                        type = "Percent"
                        value = 100
                        periodSeconds = 15
                    }]
                }
                scaleUp = {
                    stabilizationWindowSeconds = 0
                    policies = [
                        {
                            type = "Percent"
                            value = 100
                            periodSeconds = 15
                        }
                        {
                            type = "Pods"
                            value = 4
                            periodSeconds = 15
                        }
                    ]
                    selectPolicy = "Max"
                }
            }
        }
    }
    # Construct the service manifest.
    service = {
        apiVersion = "v1"
        kind = "Service"
        metadata.name = a.name
        metadata.labels = a.labels
        spec = {
            type = a.service?.$type
            selector = a.labels
            ports = a.service?.ports
        }
    }
    # Returns Kubernetes manifests
    [deployment, hpa, if a.service:
        service
    ]
}
manifests.yaml_stream(sum([kubernetesRender(a) for a in app.App.instances()], []))
