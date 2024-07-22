import regex

schema App:
    """The application model."""
    name: str
    version: str
    environment: "dev" | "stg" | "prd"
    team: str
    min_replicas: int = 1
    max_replicas: int = 2
    labels?: {str:str} = {name = name, version = version, environment = environment, team = team}
    service?: Service
    containers?: {str:Container}

    check:
        min_replicas < max_replicas <= 20, "max_replicas must be between min_replicas and 20, inclusive"


schema Service:
    """The service model."""
    $type?: str
    ports: [Port]

schema Port:
    """The port model."""
    port: int
    protocol: "TCP" | "UDP" | "SCTP" = "TCP"
    targetPort?: int | str

schema Container:
    """The container model."""
    image: str
    command?: [str]
    args?: [str]
    env?: [Env]
    volumes?: [Volume]
    resources?: Resource
    health?: Health
    ports: [ContainerPort]

schema ContainerPort:
    """The container port model."""
    name?: str
    protocol: "TCP" | "UDP" | "SCTP" = "TCP"
    containerPort: int

    check:
        1 <= containerPort <= 65535, "containerPort must be between 1 and 65535, inclusive"

schema Env:
    name: str
    value: str

schema Volume:
    source: str
    path: str
    target: str
    readOnly?: bool = False

schema Health:
    readinessProbe?: {str:}
    livenessProbe?: {str:}

schema Resource:
    limits?: {str:}
    requests?: {str:}