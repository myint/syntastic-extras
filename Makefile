default: test

test:
	PYTHON=python2.4 ./test/test.bash
	PYTHON=python3.6 ./test/test.bash

.PHONY: test
