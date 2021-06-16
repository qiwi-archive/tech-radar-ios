SHELL := $(shell which bash)
.DEFAULT_GOAL := help
.PHONY: build

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

## App setting
export PATHPREFIX?=/pages/common/tech-radar/

## General setting
export DOCKER_REGISTRY?=dcr.qiwi.com
export DOCKER_OPTIONS?=-e PATHPREFIX=$(PATHPREFIX)

DOCKER_EXEC=$(shell which docker)
GIT_EXEC=$(shell which git)

DOCKERFILE_NODE_BUILD_TOOL_NAME?=debian-buster-node-build
DOCKERFILE_NODE_BUILD_TOOL_VERSION?=$$($(GIT_EXEC) archive --remote="ssh://gerrit.osmp.ru:29418/devops/docker-images" HEAD base-images/$(DOCKERFILE_NODE_BUILD_TOOL_NAME)/VERSION | tar -x --to-stdout)
DOCKERFILE_NODE_BUILD_TOOL_IMAGE?=$(DOCKER_REGISTRY)/$(DOCKERFILE_NODE_BUILD_TOOL_NAME):$(DOCKERFILE_NODE_BUILD_TOOL_VERSION)
NODE_BUILD_TOOL?=sudo $(DOCKER_EXEC) run --rm -i -u $(shell id -u):$(shell id -g) -v $(HOME):/home -v $(PWD):/app -e NPM_INTERNAL_REGISTRY $(DOCKER_OPTIONS) $(DOCKERFILE_NODE_BUILD_TOOL_IMAGE)

build: ## build application
	$(NODE_BUILD_TOOL) --install build

deploy: ## deploy application
	rm -rf src
	mv -f dist/* .
	$(GIT_EXEC) add --all
	$(GIT_EXEC) commit --message "deploy"
	$(GIT_EXEC) push -f origin HEAD:gh-pages
