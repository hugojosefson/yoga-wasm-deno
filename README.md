# yoga-wasm-deno

Building [Yoga](https://github.com/facebook/yoga) Flexbox layout engine for
WebAssembly and running it in [Deno](https://deno.land/).

## Usage

```typescript
import { Yoga } from "https://deno.land/x/yoga_wasm/mod.ts";
```

### Example

See [./src/example.ts](./src/example.ts).

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
