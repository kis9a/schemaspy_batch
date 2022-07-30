SERVICE := schemaspy
SCHEMASPY_VERSION := 6.1.0
IMAGE_NAME := $(SERVICE)-$(SCHEMASPY_VERSION)
CONTAINER_NAME := $(SERVICE)-$(SCHEMASPY_VERSION)
IMAGE := $(shell docker images $(IMAGE_NAME) -q)
CONTAINER = $(shell docker ps --filter "ancestor=$(IMAGE)" -q)
DRIVERS_DIR = "drivers"
PWD = $(shell realpath $(dir $(lastword $(MAKEFILE_LIST))))

.DEFAULT_GOAL := help

help: ## help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: ## build terraform image
	@docker build -t $(IMAGE_NAME) . --file Dockerfile

build-no-cache: ## build terraform image --no-cache
	@docker build -t $(IMAGE_NAME) --no-cache . --file Dockerfile

run_app:
	@docker run -w / -v $(PWD):/app/ -v ~/.aws:/root/.aws -e "APP_ENV=$(env)" $(option) --entrypoint "/app/run" $(IMAGE) $(p)

run_test_app:
	@docker run -w / -v $(PWD):/app/ -v ~/.aws:/root/.aws -e "APP_ENV=$(env)" $(option) --entrypoint "/app/run" $(IMAGE) --test

schemaspy: ## schemaspy command
	@docker run -w / -v $(PWD):/app/ --entrypoint "/usr/local/bin/schemaspy" $(IMAGE) $(p)

schemaspy-version: ## schemaspy version
	@docker run -w /app -v $(PWD):/app/ --entrypoint "/usr/local/bin/schemaspy" $(IMAGE) --version

uname: ## print os names
	@docker run -w /app -v $(PWD):/app/ --entrypoint "/bin/uname" $(IMAGE) -a

tail: ## tail /dev/null and keep run container
	@docker run -w /app -v $(PWD):/app/ -v ~/.aws:/root/.aws --entrypoint "tail" $(IMAGE) -f /dev/null

stop: ## stop runing container
	@docker stop $(CONTAINER)

kill: ## kill runing container
	@docker kill $(CONTAINER)

exec: ## exec into container /bin/sh
	@docker exec -it $(CONTAINER) /bin/sh
