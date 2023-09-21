env "poc" {
    src = "file://poc.hcl"
    url = "postgres://user:pass@localhost:5455?sslmode=disable"
    dev = "docker://postgres/13"

    migration {
        dir = "file://poc-migrations"
    }
}