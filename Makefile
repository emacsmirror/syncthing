EMACS := emacs
EMACSCLIENT := emacsclient
DEMO_HOST := 127.0.0.1
DEMO_PORT := 5000
DEMO_PROTO := http
DEMO_ADDR := $(DEMO_PROTO)://$(DEMO_HOST):$(DEMO_PORT)
DEMO_TOKEN := dummy

.PHONY: all
all: tests

.PHONY: tests
clean:
	@-rm syncthing*.elc 2>/dev/null

%.elc: %.el
	@$(EMACS) --batch --quick \
		--directory . \
		--eval \
		'(byte-compile-file (replace-regexp-in-string ".elc" ".el" "$@"))'

byte-compile: \
	syncthing-common.elc \
	syncthing-common-tests.elc \
	syncthing-constants.elc \
	syncthing-custom.elc \
	syncthing-draw.elc \
	syncthing.elc \
	syncthing-errors.elc \
	syncthing-faces.elc \
	syncthing-groups.elc \
	syncthing-keyboard.elc \
	syncthing-keyboard-tests.elc \
	syncthing-network.elc \
	syncthing-network-tests.elc \
	syncthing-state.elc \
	syncthing-tests.elc \
	syncthing-update.elc \
	syncthing-watcher.elc

.PHONY: tests
tests: clean byte-compile main-tests keyboard-tests common-tests network-tests

.PHONY: network-tests
network-tests:
	@$(EMACS) --batch --quick \
		--directory . \
		--load syncthing-network-tests.el \
		--funcall ert-run-tests-batch

.PHONY: common-tests
common-tests:
	@$(EMACS) --batch --quick \
		--directory . \
		--load syncthing-common-tests.el \
		--funcall ert-run-tests-batch

.PHONY: keyboard-tests
keyboard-tests:
	@$(EMACS) --batch --quick \
		--directory . \
		--load syncthing-keyboard-tests.el \
		--funcall ert-run-tests-batch

.PHONY: main-tests
main-tests:
	@$(EMACS) --batch --quick \
		--directory . \
		--load syncthing-tests.el \
		--funcall ert-run-tests-batch

.PHONY: demo-server
demo-server:
	FLASK_APP=demo/demo.py flask run \
		--host $(DEMO_HOST) --port $(DEMO_PORT) \
		--reload

.PHONY: demo
demo:
	$(EMACSCLIENT) --eval \
		'(load "$(PWD)/demo/demo.el")' \
		'(syncthing-demo "Demo" "$(DEMO_ADDR)")' &
	$(MAKE) demo-server

.PHONY: tag
tag:
	$(MAKE) all
	git add -f . && git stash
	@grep ";; Version:" syncthing.el | tee /dev/stderr | grep "$(TAG)"
	@git tag "$(TAG)" --sign
