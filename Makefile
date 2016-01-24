COVERAGE=coverage
PYTHON=python

ifdef PREFIX
PREFIX_ARG=--prefix=$(PREFIX)
endif

all: build

build:
	$(PYTHON) setup.py build

check: test

checkdist:
	check-manifest

clean:
	-$(PYTHON) setup.py clean --all
	find . -not -path '*/.hg/*' \( -name '*.py[cdo]' -o -name '*.err' -o \
		-name '*,cover' -o -name __pycache__ \) -prune \
		-exec rm -rf '{}' ';'
	rm -rf dist build htmlcov
	rm -f README.md MANIFEST .coverage cram.xml

install: build
	$(PYTHON) setup.py install $(PREFIX_ARG)

dist:
	TAR_OPTIONS="--owner=root --group=root --mode=u+w,go-w,a+rX-s" \
	$(PYTHON) setup.py -q sdist

test: pep8 pyflakes checkdist
	PYTHON=$(PYTHON) PYTHONPATH=`pwd` scripts/cram $(TEST_ARGS) tests

tests: test

coverage: pep8 pyflakes checkdist
	$(COVERAGE) erase
	COVERAGE=$(COVERAGE) PYTHON=$(PYTHON) PYTHONPATH=`pwd` scripts/cram \
	$(TEST_ARGS) tests
	$(COVERAGE) report --fail-under=100

# E129: indentation between lines in conditions
# E261: two spaces before inline comment
# E301: expected blank line
# E302: two new lines between functions/etc.
pep8:
	pep8 --ignore=E129,E261,E301,E302 --repeat cram scripts/cram setup.py

pyflakes:
	pyflakes cram scripts/cram setup.py

markdown:
	pandoc -f rst -t markdown README.rst > README.md

.PHONY: all build checkdist clean install dist test tests coverage pep8 \
	pyflakes markdown
