CD=cd
FIND=find
DEL=rm
TAR=tar
PYTHON=python
PIP=pip
COVERAGE=coverage
COVERALLS=coveralls
PYLINT=pylint
SPHINX=sphinx-build

MODULE_DIR=reputation
DOC_DIR=doc/build
OUT_DIR=ip-reputation-monitoring
DIST_NAME=$(OUT_DIR).tgz

clean: clean-doc
	if [[ `$(FIND) . -name *.pyc` ]] ; \
	then \
		$(FIND) . -name *.pyc | xargs $(DEL) ; \
	fi;
	$(DEL) -f $(DIST_NAME)

clean-doc:
	$(DEL) -rf $(DOC_DIR)

install-deps:
	$(PIP) install -r requirements.txt

install-dev-deps:
	$(PIP) install -r requirements/dev.txt

test: 
	cd $(MODULE_DIR) && \
	$(COVERAGE) > /dev/null 2>&1 && \
	$(COVERAGE) run --source='.' -m unittest discover && \
	$(COVERAGE) report \
		|| \
	$(PYTHON) -m unittest discover

coveralls:
	$(COVERAGE) erase && \
	cd $(MODULE_DIR) && \
	$(COVERAGE) > /dev/null 2>&1 && \
	$(COVERAGE) run --source='.' -m unittest discover && \
	$(COVERALLS)

lint:
	cd $(MODULE_DIR) && \
	$(PYLINT) --disable=W0141 --max-line-length=150 adapters/ api/ archive/ config/ default/ factory/ main.py mongo/ parsing/ reporting/ run_api.py tests/ spamhaus_monitor.py  tools/ utils/

doc: clean-doc
	$(SPHINX) -b html doc/source doc/build

dist: clean doc
	$(DEL) -f reputation/.coverage $(DIST_NAME)
	$(TAR) --transform 's/^\./$(OUT_DIR)/' -cvzf $(DIST_NAME) \
							  ./reputation/ \
							  ./doc/build/ \
							  ./requirements/ \
							  ./Makefile \
							  ./README.md \
							  ./LICENSE \
							  ./CONTRIBUTING.md \
							  ./CHANGELOG.md \
							  ./requirements.txt \
							  ./setup.py \
							  ./*.sh
