.PHONY: help list build wrapper-get wrapper-update wrapper-install

REPO    := beincontrol/docker-compose
VERSION := 1.22.0-stretch-slim-pip
DOCKER  := sudo docker

TAG := $(REPO):$(VERSION)
ME  := $(realpath $(firstword $(MAKEFILE_LIST)))
PWD := $(dir $(ME))

WRAPPER_BIN := /usr/local/bin/docker-compose
WRAPPER_URL := https://raw.githubusercontent.com/docker/compose/master/script/run/run.sh

##
# help
# Displays list of targets, using target '##' comments as descriptions
# NOTE: Keep 'help' as first target in case .DEFAULT_GOAL is not honored
#
help: ## This help screen
	@echo
	@echo "Make targets:"
	@echo
	@cat $(ME) | \
	sed -n -r 's/^([^.][^: ]+)\s*:(([^=#]*##\s*(.*[^[:space:]])\s*)|[^=].*)$$/    \1\t\4/p' | \
	sort -u | \
	expand -t20
	@echo

##
# list
# We place 'list' after 'help' to keep 'help' as first target
#
list: help ## List targets (currently an alais for 'help')

##
# build
#
build: ## Build the image
	$(DOCKER) build -t "$(TAG)" "$(PWD)"

##
# wrapper-get
#
wrapper-get: ## Fetch latest wrapper script from docker. usage: f=<file>
	@if [ -z "$(f)" ]; then \
		echo; \
		echo "Usage: wrapper-get f=<file>"; \
		echo; \
	elif [ -f "$(f)" ]; then \
		echo; \
		echo "File '$(f)' already exists.  Please rename it or choose a different file name"; \
		echo; \
	else \
		echo; \
		echo -n "Downloading latest wrapper script into '$(f)' ... "; \
		wget -q -O "$(f)" "$(WRAPPER_URL)" && \
		echo "Done"; \
		echo; \
	fi

##
# wrapper-update
#
wrapper-update: ## Updates wrapper script with custom image. usage: f=<file>
	@if [ -z "$(f)" ]; then \
		echo; \
		echo "Usage: wrapper-update f=<file>"; \
		echo; \
	elif [ ! -f "$(f)" ]; then \
		echo; \
		echo "File '$(f)' not found, did you use wrapper-get?"; \
		echo; \
	else \
		echo; \
		echo -n "Updating wrapper script '$(f)' ... "; \
		sed -i -r \
		    -e '/^REPO\s*=.*$$/d'    \
		    -e '/^VERSION\s*=.*$$/d' \
		    -e 's|^IMAGE\s*=.*$$|REPO="${REPO}"\nVERSION="${VERSION}"\nIMAGE="$$REPO:$$VERSION"|g' \
		     "$(f)" && \
		echo "Done";   \
		echo; \
	fi

##
# wrapper-install
#
wrapper-install: ## Install wrapper script (requires sudo). usage: f=<file>
	@if [ -z "$(f)" ]; then \
		echo; \
		echo "Usage: wrapper-install f=<file>"; \
		echo "       see wrapper-get for fetching the file from docker"; \
		echo; \
	elif [ ! -f "$(f)" ]; then \
		echo; \
		echo "File '$(f)' not found, did you use wrapper-get?"; \
		echo; \
	else \
		echo; \
		echo -n "Installing wrapper script into '$(WRAPPER_BIN)' ... "; \
		cat "$(f)" | \
		sed -r \
		    -e '/^REPO\s*=.*$$/d'    \
		    -e '/^VERSION\s*=.*$$/d' \
		    -e 's|^IMAGE\s*=.*$$|REPO="${REPO}"\nVERSION="${VERSION}"\nIMAGE="$$REPO:$$VERSION"|g' | \
		sudo tee "$(WRAPPER_BIN)" >/dev/null && \
		sudo chmod ugo+rx "$(WRAPPER_BIN)"   && \
		echo "Done"; \
		echo; \
	fi
