.PHONY: test

lint:
	shellcheck scripts/*.sh
	shellcheck tests/*.bats