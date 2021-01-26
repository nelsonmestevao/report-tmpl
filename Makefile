#==============================================================================
SHELL   = sh
#------------------------------------------------------------------------------
NO_COLOR=\x1b[0m
OK_COLOR=\x1b[32m
ERROR_COLOR=\x1b[31m
WARN_COLOR=\x1b[33m
OK_STRING=$(OK_COLOR)done$(NO_COLOR)
ERROR_STRING=$(ERROR_COLOR)fail$(NO_COLOR)
WARN_STRING=$(WARN_COLOR)problems$(NO_COLOR)
#------------------------------------------------------------------------------
FILTERS = -F pandoc-crossref # -F pandoc-include-code -F pandoc-xnos
OPTIONS = --template=styles/default.tex $(FILTERS)
CONFIG  = --metadata-file config.yml
BIB     = --citeproc --bibliography=references.bib --csl styles/ieee.csl
#------------------------------------------------------------------------------
SRC     = $(shell ls $(SRC_DIR)/*.md)
SRC_DIR = sections
#------------------------------------------------------------------------------
REPORT  = report
#==============================================================================

define show
	@./$(UTI_DIR)/fmt.sh --color $(1) --type $(2) $(3)
endef

define compile
	@echo -en "Compiling $(REPORT).$1 ... "
	@pandoc $(CONFIG) $(OPTIONS) $(BIB) -s $(SRC) -o $(REPORT).$1
	@echo -e "$(OK_STRING)"
endef

.PHONY: pdf # Compile the document to a PDF
pdf:
	$(call compile,$@)

.PHONY: tex # Generate the TeX file
tex:
	$(call compile,$@)

.PHONY: clean # Clean all generated artifacts
clean:
	@-cat .art/maid.ascii
	@echo -en "Cleaning ... "
	@rm $(REPORT).pdf
	@echo -e "$(OK_STRING)"

.PHONY: help # Generate list of targets with descriptions
help:
	@grep '^.PHONY: .* #' Makefile | sed 's/\.PHONY: \(.*\) # \(.*\)/    \1 \t \2/'

