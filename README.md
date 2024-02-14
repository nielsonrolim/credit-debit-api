# Credit-Debit API

This application was created to participate of the "Rinha de Backend - 2024/Q1" code challenge.

More info about the challenge here: https://github.com/zanfranceschi/rinha-de-backend-2024-q1

#### Tech Stack
- Ruby 3.3.0
- Ruby on Rails 7.1.3
- PostgreSQL 16.2
- Blueprinter 1.0.2 as serializer
- Oj 3.16.3 as JSON parsers

## Running the application

### Requirements

- Docker
- Docker Compose
- Open `docker-compose.yml` file and add `SECRET_BASE_KEY` enviroment var to the `api` service:

```
services:
  api:
    environment:
      - SECRET_KEY_BASE=<128-BYTES-STRING>
```

Note: you can generate the secret key base by running in IRB:
```
require 'securerandom'; SecureRandom.alphanumeric(128)
```

### In Development

Build the application:
```
docker compose build
```

Run the application:
```
docker compose up -d
```
The application run in `http://localhost:3000`


### In "Production"

Go to the Rinha directory:
```
cd rinha/
```
Run the application:
```
docker compose up -d
```
The application run in `http://localhost:9999`

## Endpoints

### GET /clientes/:id/extrato
List accounts (clients) with balance, credit limit and last 10 transactions.

Sample response:
```
{
    "saldo": {
        "total": 40,
        "data_extrato": "2024-02-13T15:55:48-03:00",
        "limite": 100000
    },
    "ultimas_transacoes": [
        {
            "valor": 20,
            "tipo": "c",
            "descricao": "toma mais 20",
            "realizada_em": "2024-02-13 14:48:44 -0300"
        },
        {
            "valor": 20,
            "tipo": "c",
            "descricao": "toma 20",
            "realizada_em": "2024-02-13 14:48:28 -0300"
        }
    ]
}
```

### POST /clientes/1/transacoes
Add a transaction for credit ('c') or debit ('d')

Sample payload:
```
{
    "valor": 20,
    "tipo": "c",
    "descricao": "toma mais 20"
}
```

Sample response:
```
{
    "limite": 100000,
    "saldo": 40
}
```

## Running the tests
1. Make sure you have the application running in development
2. Run `RSpec`:
```
bundle exec rspec
```

## Author
Nielson Rolim ([nielsonrolim @ linkedin](https://www.linkedin.com/in/nielsonrolim/))
