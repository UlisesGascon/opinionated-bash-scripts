.PHONY: test

test:
	docker build -t bats-tests -f Dockerfile.test .
	docker run -it --rm bats-tests tests
test-ci:
	docker build -t bats-tests -f Dockerfile.test .
	docker run --rm bats-tests tests
lint:
	shellcheck scripts/*.sh
	shellcheck tests/*.bats