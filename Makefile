#==============================================================================
SHELL   = sh
#------------------------------------------------------------------------------
FILTERS = -F pandoc-crossref # -F pandoc-include-code -F pandoc-xnos
OPTIONS = --template=styles/default.tex $(FILTERS)
CONFIG  = --metadata-file config.yml
BIB     = --citeproc --bibliography=references.bib --csl styles/ieee.csl
#------------------------------------------------------------------------------
NO_COLOR=\x1b[0m
OK_COLOR=\x1b[32m
ERROR_COLOR=\x1b[31m
WARN_COLOR=\x1b[33m
OK_STRING=$(OK_COLOR)done$(NO_COLOR)
ERROR_STRING=$(ERROR_COLOR)fail$(NO_COLOR)
WARN_STRING=$(WARN_COLOR)problem$(NO_COLOR)
#------------------------------------------------------------------------------
SRC     = $(shell ls $(SRC_DIR)/*.md)
SRC_DIR = sections
UTI_DIR = scripts
REPORT  = report
#==============================================================================

.DEFAULT_GOAL = pdf

define compile
	@echo -ne "Compiling $(REPORT).$1 ... ";
	@pandoc $(CONFIG) \
		$(OPTIONS) \
		$(BIB) \
		-s $(SRC) \
		-o "$(REPORT).$1";
	@echo -e "$(OK_STRING)";
endef

pdf:
	@$(call compile,$@)

tex:
	@$(call compile,$@)

clean:
	@echo "Cleaning..."
	@-cat .art/maid.ascii
	@rm $(REPORT).pdf
	@echo "...✓ done!"
