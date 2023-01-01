// import { Yoga } from "https://deno.land/x/yoga_wasm/mod.ts";
import { Yoga } from "../mod.ts";

const root = Yoga.Node.createDefault();
root.setWidth(100);
root.setHeight(100);

const child0 = Yoga.Node.createDefault();
child0.setWidth(10);
child0.setHeight(10);
root.insertChild(child0, 0);

const child1 = Yoga.Node.createDefault();
child1.setWidth(10);
child1.setHeight(10);
root.insertChild(child1, 1);

root.calculateLayout(100, 100, Yoga.DIRECTION_LTR);

const child0Left = child0.getComputedLeft();
const child0Top = child0.getComputedTop();
const child1Left = child1.getComputedLeft();
const child1Top = child1.getComputedTop();

const actual = { child0Left, child0Top, child1Left, child1Top };
console.log(actual);

// Output:
// { child0Left: 0, child0Top: 0, child1Left: 0, child1Top: 10 }
