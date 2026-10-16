NAME = inception

COMPOSE = docker-compose -f srcs/docker-compose.yml --env-file srcs/.env

.DEFAULT_GOAL := all

all:
	@printf "Starting $(NAME)...\n"
	@set -a; . ./srcs/.env; set +a; \
		bash srcs/requirements/tools/make_dir.sh
	@$(COMPOSE) up -d --build

up: all

down:
	@printf "Stopping $(NAME)...\n"
	@$(COMPOSE) down

stop:
	@$(COMPOSE) stop

start:
	@$(COMPOSE) start

restart:
	@$(COMPOSE) restart

re: down all

logs:
	@$(COMPOSE) logs --tail=100

ps:
	@$(COMPOSE) ps

clean: down
	@printf "Removing project containers and images...\n"
	@$(COMPOSE) down --rmi local --remove-orphans

fclean:
	@printf "WARNING: Removing $(NAME) containers and Docker volumes.\n"
	@printf "Host bind-mounted data directories are not deleted.\n"
	@$(COMPOSE) down --rmi local --volumes --remove-orphans

.PHONY: all up down stop start restart re logs ps clean fclean
