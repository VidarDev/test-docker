# Ex Gobal

## Getting Started

### Prerequisites

This project requires the installation of docker.

## Usage

Go to the traefik folder, and copy the [.env.dist](./.env.dist) file to [.env](./.env) and edit it to configure the traefik.

```bash
TRAEFIK_DOMAIN=
TRAEFIK_NETWORK=
TRAEFIK_HTPASSWD= # docker run --rm httpd:alpine htpasswd -nbs user 'password'
TRAEFIK_ACME_EMAIL=
```

Launch your container.

```bash
docker-compose up -d
```

Now, go to the traefik folder

## License

Distributed under the MIT License. See `LICENSE` for more information.
