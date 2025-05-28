NAME = inception

all: $(NAME)

$(NAME): prepare up

prepare:
	@printf "🚀 Preparing environment...\n"
	@if [ ! -d "/home/$(USER)/data" ]; then \
		mkdir -p /home/$(USER)/data/wordpress && \
		mkdir -p /home/$(USER)/data/mariadb && \
		printf "✅ Data directories created\n"; \
	else \
		printf "📁 Data directories already exist\n"; \
	fi
	@sudo chown -R $(USER):$(USER) /home/$(USER)/data/wordpress
	@sudo chown -R $(USER):$(USER) /home/$(USER)/data/mariadb
	@sudo chmod 755 /home/$(USER)/data/wordpress
	@sudo chmod 755 /home/$(USER)/data/mariadb
	@printf "🔒 Permissions set\n"

up:
	@printf "🐳 Building and starting containers...\n"
	@docker-compose -f srcs/docker-compose.yml up --build -d
	@printf "✅ Containers are running\n"

down:
	@printf "🛑 Stopping containers...\n"
	@docker-compose -f srcs/docker-compose.yml down
	@printf "✅ Containers stopped\n"

clean: down
	@printf "🧹 Cleaning volumes...\n"
	@sudo rm -rf /home/$(USER)/data/wordpress/*
	@sudo rm -rf /home/$(USER)/data/mariadb/*
	@printf "✅ Volumes cleaned\n"

fclean: clean
	@printf "🗑️  Full cleanup...\n"
	@sudo rm -rf /home/$(USER)/data
	@docker system prune -af
	@printf "✅ Everything cleaned\n"

re: fclean all

ps:
	@docker-compose -f srcs/docker-compose.yml ps

logs:
	@docker-compose -f srcs/docker-compose.yml logs

.PHONY: all prepare up down clean fclean re ps logs $(NAME)
