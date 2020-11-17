#!/usr/bin/env sh

pandoc \
    --metadata-file config.yml \
    --template=styles/template.tex \
    -F pandoc-crossref --citeproc --bibliography=references.bib \
    -s \
        sections/01-introduction.md \
        sections/09-conclusion.md \
    -o report.pdf

