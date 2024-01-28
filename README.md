# Vegan Paradise API

This is a simple API built with [Express](https://expressjs.com/).

## Getting Started

1. Run docker with output to terminal: `docker-compose up`
2. Take down server: `docker-compose down -v`
3. Run with more then one server `docker-compose up -d --scale api=3`

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
