FROM pandoc/latex

RUN apk add --update make

ENTRYPOINT []

CMD make
