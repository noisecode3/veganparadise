# Vegan Paradise API

This is joke docker website that will not be hosted, but roasted.

## Getting Started

1. Run docker with output to terminal: `docker-compose up`
2. Take down server: `docker-compose down -v` on another terminal or use ctrl+C
3. Run with more then one server `docker-compose up -d --scale api=3`
4. If you get failed to bind port 127.0.0.1:7306/tcp: Error starting userland proxy:
    you can add `DOCKER_OPTS="--userland-proxy=false"` to `/etc/default/docker`

## Entering mysql server

- docker-compose exec db mysql -u root -p #test password is root
- USE broccoli;
- SHOW TABLES;
- DESCRIBE sometablename;

## Docker Containers

- web-nginx-N
- web-api-N
- web-db-N

## API Endpoints

- `/hello`: Returns a greeting message.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
