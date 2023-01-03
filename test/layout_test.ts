import { Container, Node } from "npm:@welefen/grid-layout";
import {
  BoundingRect,
  ContainerBoundingRect,
} from "npm:@welefen/grid-layout/lib/util/config.d.ts";
import { assertEquals } from "https://deno.land/std@0.170.0/testing/asserts.ts";
import { drawBorder, moveCursorTo, placeAt } from "../src/primitives.ts";

function drawLayout(layout: BoundingRect, text: string, yOffset = 0): string {
  return drawBorder(
    {
      width: layout.width! * 2,
      height: layout.height!,
      x: layout.left! * 2,
      y: layout.top! + 1 + yOffset,
    },
    text,
  );
}

Deno.test("layout", () => {
  const marginTop = 2;

  const root = new Container({
    width: 50,
    height: 30,
    justifyItems: "center",
    gridTemplateColumns: "1fr 1fr",
  });

  const children: Record<string, Node> = {
    nav: new Node({
      width: 10,
      height: 10,
      marginTop,
      marginLeft: "auto",
    }),
    article: new Node({
      width: 10,
      height: 10,
      marginTop,
      marginRight: "auto",
    }),
  };

  const childNames = Object.keys(children);
  Object.values(children).forEach((child) => root.appendChild(child));

  root.calculateLayout();
  const actualLayouts: ContainerBoundingRect = root.getAllComputedLayout()!;
  const actualChildren: BoundingRect[] = actualLayouts.children!;

  const expectedChildren: BoundingRect[] = [
    {
      left: 15,
      top: marginTop,
      width: 10,
      height: 10,
    },
    {
      left: 25,
      top: marginTop,
      width: 10,
      height: 10,
    },
  ];
  const expectedLayouts: ContainerBoundingRect = {
    left: 0,
    top: 0,
    width: 50,
    height: 30,
    children: expectedChildren,
  };

  const CLEAR_SCREEN = "\x1b[2J\x1b[3J\x1b[H";
  const output = [
    CLEAR_SCREEN,
    placeAt(["Actual:"], { x: 0, y: 0 }),
    drawLayout(actualLayouts, "root", 1),
    ...actualChildren.map((layout, i) => drawLayout(layout, childNames[i], 1)),
    placeAt(["Expected:"], { x: 0, y: actualLayouts.height! + 3 }),
    drawLayout(expectedLayouts, "root", actualLayouts.height! + 3),
    ...expectedChildren.map((layout, i) =>
      drawLayout(layout, childNames[i], actualLayouts.height! + 3)
    ),
    moveCursorTo({
      x: 0,
      y: actualLayouts.height! + 1 + expectedLayouts.height! + 2,
    }),
  ].join("");
  console.log(output);

  assertEquals(actualLayouts, expectedLayouts);
});
