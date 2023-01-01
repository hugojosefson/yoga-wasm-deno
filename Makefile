.PHONY: default clean all help

## Build the Yoga library
default: build/yoga

## Build all the generated files
all: dist/yoga.d.ts dist/yoga.mjs dist/yoga.wasm

## Delete all generated files
clean:
	rm -rf build
	rm -rf dist

build:
	mkdir -p build

dist:
	mkdir -p dist

## Run tests
test: $(wildcard test/*) dist/yoga.d.ts dist/yoga.mjs dist/yoga.wasm
	deno test

## Check out the Yoga library source code
build/yoga: build
	cd build && git clone https://github.com/facebook/yoga.git
	cd build/yoga && git checkout -f c3291912b34568d671526cc0c21185023d3df2c5

## List all the targets with descriptions
help:
	@awk '/^#/{c=substr($$0,3);next}c&&/^[[:alpha:]][[:alnum:]_-]+:/{print substr($$1,1,index($$1,":")),c}1{c=0}' $(MAKEFILE_LIST) | column -s: -t
