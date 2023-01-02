# yoga_wasm for Deno

A WebAssembly build of [Yoga](https://github.com/facebook/yoga) Flexbox layout
engine, for [Deno](https://deno.land/).

## Usage

```typescript
import { Yoga } from "https://deno.land/x/yoga_wasm/mod.ts";
```

### Example

See [./src/example.ts](https://deno.land/x/yoga_wasm/src/example.ts?source).

```bash
deno run https://deno.land/x/yoga_wasm/src/example.ts
```

Outputs:

```js
{ child0Left: 0, child0Top: 0, child1Left: 80, child1Top: 0 }
```

## Build

### Pre-requisites

- `bash`
- `podman` or `docker` command-line tool
  - Install for example via https://podman-desktop.io/

### Build Yoga for WebAssembly

```bash
./make-in-container
```

### Run tests

```bash
./make-in-container test
```

## License

Yoga files in the `./dist` directory are licensed under the MIT license, see
[./dist/LICENSE](https://deno.land/x/yoga_wasm/dist/LICENSE?source).

Files in other directories, such as build scripts etc, are MIT licensed, see
[./LICENSE](https://deno.land/x/yoga_wasm/LICENSE?source).
