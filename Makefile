test:
	PYTHON=python2.4 ./test/test.bash
	PYTHON=python3.5 ./test/test.bash

.PHONY: test
