.PHONY: default clean all help build/yoga/javascript/.babelrc.js

## Build the Yoga library
default: all
 
## Build all the generated files
all: dist/yoga.js dist/yoga.d.ts dist/wrapAsm.d.ts dist/generated/YGEnums.d.ts

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
test: $(wildcard test/*) mod.ts dist/yoga.js dist/yoga.d.ts dist/wrapAsm.d.ts dist/generated/YGEnums.d.ts
	deno test

## Check out the Yoga library source code
build/yoga/: build/
	cd build/yoga && git checkout --force c3291912b34568d671526cc0c21185023d3df2c5 || ( cd build && rm -rf yoga && git clone https://github.com/facebook/yoga.git )

## List all the targets with descriptions
help:
	@awk '/^#/{c=substr($$0,3);next}c&&/^[[:alpha:]][[:alnum:]_-]+:/{print substr($$1,1,index($$1,":")),c}1{c=0}' $(MAKEFILE_LIST) | column -s: -t

build/yoga.js: build/ build/yoga/
	cd build/yoga && emcc yoga/*.cpp javascript/src_native/*.cc \
		--bind -O0 --memory-init-file 0 --llvm-lto 1 \
		-I. \
		-s "DEFAULT_LIBRARY_FUNCS_TO_INCLUDE=['memcpy','memset','malloc','free','strlen']" \
		-s AGGRESSIVE_VARIABLE_ELIMINATION=1 \
		-s ALLOW_MEMORY_GROWTH=1 \
		-s ASSERTIONS=0 \
		-s DISABLE_EXCEPTION_CATCHING=1 \
		-s ERROR_ON_UNDEFINED_SYMBOLS=0 \
		-s EXPORT_ES6=1 \
		-s NO_EXIT_RUNTIME=1 \
		-s WASM_ASYNC_COMPILATION=1 \
		-s EXPORT_NAME=Yoga \
		-s MODULARIZE=1 \
		-s SINGLE_FILE=1 \
		-o ../yoga.js

dist/yoga.js: dist/ build/yoga.js
	cp build/yoga.js dist/yoga.js
	deno fmt dist/yoga.js

build/yoga/javascript/dist/index.d.ts: build/yoga/javascript/.babelrc.js
	cd build/yoga/javascript && node --version && yarn && yarn build

dist/yoga.d.ts: dist/ build/yoga/javascript/src_js/index.d.ts
	cp build/yoga/javascript/src_js/index.d.ts dist/yoga.d.ts
	deno fmt dist/yoga.d.ts
	sed -r 's/from ["'"'"'](.*)["'"'"']/from "\1.d.ts"/g' -i dist/yoga.d.ts
	sed -r 's/export function loadYoga/export default function loadYoga/g' -i dist/yoga.d.ts
	echo "export type { Yoga };" >> dist/yoga.d.ts
	deno fmt dist/yoga.d.ts

dist/wrapAsm.d.ts: dist/ build/yoga/javascript/src_js/wrapAsm.d.ts
	cp build/yoga/javascript/src_js/wrapAsm.d.ts dist/
	deno fmt dist/wrapAsm.d.ts
	sed -r 's/from ["'"'"'](.*)["'"'"']/from "\1.d.ts"/g' -i dist/wrapAsm.d.ts
	deno fmt dist/wrapAsm.d.ts

dist/generated/YGEnums.d.ts: dist/generated/ build/yoga/javascript/src_js/generated/YGEnums.d.ts
	cp build/yoga/javascript/src_js/generated/YGEnums.d.ts dist/generated/
	deno fmt dist/generated/YGEnums.d.ts
	sed -r 's/from ["'"'"'](.*)["'"'"']/from "\1.d.ts"/g' -i dist/generated/YGEnums.d.ts
	deno fmt dist/generated/YGEnums.d.ts

build/yoga/javascript/.babelrc.js: build/yoga/ src/babelrc.js
	cp src/babelrc.js build/yoga/javascript/.babelrc.js