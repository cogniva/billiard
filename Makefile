PYTHON=python
SPHINX_DIR="docs/"
SPHINX_BUILDDIR="${SPHINX_DIR}/.build"
README="README.rst"
README_SRC="docs/templates/readme.txt"
CONTRIBUTING_SRC="docs/contributing.rst"
SPHINX2RST="extra/release/sphinx-to-rst.py"

SPHINX_HTMLDIR = "${SPHINX_BUILDDIR}/html"

html:
	(cd "$(SPHINX_DIR)"; make html)
	mv "$(SPHINX_HTMLDIR)" Documentation

docsclean:
	-rm -rf "$(SPHINX_BUILDDIR)"

htmlclean:
	-rm -rf "$(SPHINX)"

apicheck:
	extra/release/doc4allmods billiard

indexcheck:
	extra/release/verify-reference-index.sh

configcheck:
	PYTHONPATH=. $(PYTHON) extra/release/verify_config_reference.py $(CONFIGREF_SRC)

flakecheck:
	flake8 billiard

flakediag:
	-$(MAKE) flakecheck

flakepluscheck:
	flakeplus billiard --2.6

flakeplusdiag:
	-$(MAKE) flakepluscheck

flakes: flakediag flakeplusdiag

readmeclean:
	-rm -f $(README)

readmecheck:
	iconv -f ascii -t ascii $(README) >/dev/null

$(README):
	$(PYTHON) $(SPHINX2RST) $(README_SRC) --ascii > $@

readme: readmeclean $(README) readmecheck

test:
	nosetests -xv billiard.tests

cov:
	nosetests -xv billiard.tests --with-coverage --cover-html --cover-branch

removepyc:
	-find . -type f -a \( -name "*.pyc" -o -name "*$$py.class" \) | xargs rm
	-find . -type d -name "__pycache__" | xargs rm -r

gitclean:
	git clean -xdn

gitcleanforce:
	git clean -xdf

bump_version:
	$(PYTHON) extra/release/bump_version.py billiard/__init__.py

distcheck: flakecheck apicheck indexcheck configcheck readmecheck test gitclean

dist: readme docsclean gitcleanforce removepyc
