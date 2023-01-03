.PHONY: default clean all help build/flex/.git

## Build the Flex library
default: all

## Build all the generated files, and run tests
all: dist/LICENSE dist/flex.js dist/flex.d.ts dist/wrapAsm.d.ts dist/generated/YGEnums.d.ts test

## Delete all generated files
clean:
	rm -rf build
	rm -rf dist

build/:
	mkdir -p build

dist/:
	mkdir -p dist

dist/generated/:
	mkdir -p dist/generated

## Run tests
test: $(wildcard test/*) mod.ts dist/flex.js dist/flex.d.ts dist/wrapAsm.d.ts dist/generated/YGEnums.d.ts
	deno test

# declare the version of flex to checkout:
FLEX_GIT_URL = "https://github.com/jordwalke/flex.git"
FLEX_GIT_VERSION = "6ff12fe"

## Check out the Flex library source code
build/flex/.git: build/ Makefile
	( cd build/flex && [ "$$(git config --get remote.origin.url)" = $(FLEX_GIT_URL) ] && git checkout --force $(FLEX_GIT_VERSION) ) || ( cd build && rm -rf flex && git clone $(FLEX_GIT_URL) flex && cd flex && git checkout --force $(FLEX_GIT_VERSION) )

## List all the targets with descriptions
help:
	@awk '/^#/{c=substr($$0,3);next}c&&/^[[:alpha:]][[:alnum:]_-]+:/{print substr($$1,1,index($$1,":")),c}1{c=0}' $(MAKEFILE_LIST) | column -s: -t

dist/LICENSE: dist/ build/flex/.git build/flex/LICENSE
	cp build/flex/LICENSE dist/LICENSE

build/flex.js: build/ build/flex/.git
	cd build/flex && esy install
	cd build/flex && esy build

dist/flex.js: dist/ build/flex.js
	cp build/flex.js dist/flex.js
	deno fmt dist/flex.js

dist/flex.d.ts: dist/ build/flex/javascript/src_js/index.d.ts
	cp build/flex/javascript/src_js/index.d.ts dist/flex.d.ts
	deno fmt dist/flex.d.ts
	sed -r 's/from ["'"'"'](.*)["'"'"']/from "\1.d.ts"/g' -i dist/flex.d.ts
	sed -r 's/export function loadFlex/export default function loadFlex/g' -i dist/flex.d.ts
	echo "export type { Flex };" >> dist/flex.d.ts
	deno fmt dist/flex.d.ts

dist/wrapAsm.d.ts: dist/ build/flex/javascript/src_js/wrapAsm.d.ts
	cp build/flex/javascript/src_js/wrapAsm.d.ts dist/
	deno fmt dist/wrapAsm.d.ts
	sed -r 's/from ["'"'"'](.*)["'"'"']/from "\1.d.ts"/g' -i dist/wrapAsm.d.ts
	deno fmt dist/wrapAsm.d.ts

dist/generated/YGEnums.d.ts: dist/generated/ build/flex/javascript/src_js/generated/YGEnums.d.ts
	cp build/flex/javascript/src_js/generated/YGEnums.d.ts dist/generated/
	deno fmt dist/generated/YGEnums.d.ts
	sed -r 's/from ["'"'"'](.*)["'"'"']/from "\1.d.ts"/g' -i dist/generated/YGEnums.d.ts
	deno fmt dist/generated/YGEnums.d.ts
