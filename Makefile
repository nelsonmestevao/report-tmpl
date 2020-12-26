#==============================================================================
SHELL   = sh
#------------------------------------------------------------------------------
FILTERS = -F pandoc-crossref # -F pandoc-include-code -F pandoc-xnos
OPTIONS = --template=styles/default.tex $(FILTERS)
CONFIG  = --metadata-file config.yml
BIB     = --citeproc --bibliography=references.bib --csl styles/ieee.csl
#------------------------------------------------------------------------------
SRC     = $(shell ls $(SRC_DIR)/*.md)
SRC_DIR = sections
REPORT  = report
#==============================================================================

pdf:
	pandoc $(CONFIG) $(OPTIONS) $(BIB) -s $(SRC) -o $(REPORT).pdf

tex:
	pandoc $(CONFIG) $(OPTIONS) $(BIB) -s $(SRC) -o $(REPORT).tex

clean:
	@echo "Cleaning..."
	@-cat .art/maid.ascii
	@rm $(REPORT).pdf
	@echo "...✓ done!"
