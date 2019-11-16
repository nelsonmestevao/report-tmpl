#==============================================================================
SHELL   = zsh
#------------------------------------------------------------------------------
FILTERS = -F pandoc-crossref -F pandoc-include-code
OPTIONS = --template=styles/template.tex $(FILTERS)
CONFIG  = --metadata-file config.yml
BIB     = --filter pandoc-citeproc --bibliography=references.bib
#------------------------------------------------------------------------------
SRC     = $(shell ls $(SRC_DIR)/**/*.md)
SRC_DIR = sections
REPORT  = report
#==============================================================================

pdf:
	pandoc $(CONFIG) $(OPTIONS) $(BIB) -s $(SRC) -o $(REPORT).pdf

clean:
	@echo "Cleaning..."
	@-cat .art/maid.ascii
	@rm $(REPORT).pdf
	@echo "...✓ done!"
