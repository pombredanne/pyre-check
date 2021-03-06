# Copyright (c) 2016-present, Facebook, Inc.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

export OCAMLFIND_IGNORE_DUPS_IN=$(dir $(OCAML_TOPLEVEL_PATH))ocaml/compiler-libs
export MACOSX_DEPLOYMENT_TARGET=10.11

.PHONY: all
all: configure dev

.PHONY: dev
dev:
	@./scripts/generate-version-number.sh development
	dune build @install -j auto --profile dev

.PHONY: test
test:
	@OUNIT_SHARDS="1" dune runtest -j auto --profile dev

.PHONY: python_tests
python_tests:
	./scripts/run-python-tests.sh

.PHONY: server_integration_test
server_integration_test: all
	PYRE_BINARY="$(shell pwd)/_build/default/main.exe" ./scripts/run_integration_test.py command/test/integration/fake_repository/

.PHONY: fbtest
fbtest: all
	if [ -d "$(shell pwd)/facebook" ]; then make -C facebook; fi

.PHONY: release
release:
	@./scripts/generate-version-number.sh
	dune build @install -j auto --profile release

.PHONY: clean
clean:
	dune clean
	@if [ -f dune ]; then rm dune; fi

.PHONY: configure
configure: dune;

dune: dune.in
	./scripts/setup.sh --configure

.PHONY: lint
lint:
	find -name "*.ml" | grep -v build | grep -v hack | xargs ocp-indent -i
