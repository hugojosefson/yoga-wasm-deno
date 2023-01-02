/// <reference path="./dist/yoga.d.ts" />
import loadYoga from "./dist/yoga.js";
import type { Yoga } from "./dist/yoga.d.ts";
export * from "./dist/yoga.d.ts";

const Yoga: Yoga = await loadYoga();
export { Yoga };
