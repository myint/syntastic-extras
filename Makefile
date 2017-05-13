default: .git/hooks/pre-push test

.git/hooks/pre-push: hooks/pre-push
	cd .git/hooks && ln -fs ../../hooks/pre-push .

test:
	PYTHON=python2.4 ./test/test.bash
	PYTHON=python3.6 ./test/test.bash

.PHONY: test
