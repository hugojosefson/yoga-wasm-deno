import { Node, Yoga } from "../mod.ts";
import { assertEquals } from "https://deno.land/std@0.170.0/testing/asserts.ts";
import {
  drawBorder,
  moveCursorTo,
  placeAt,
} from "../src/primitives.ts";

type Layout = {
  left: number;
  right: number;
  top: number;
  bottom: number;
  width: number;
  height: number;
};

interface Layouts {
  root: Layout;
  children: Layout[];
}

function drawLayout(layout: Layout, text: string, yOffset = 0): string {
  return drawBorder(
    {
      width: layout.width * 2,
      height: layout.height,
      x: layout.left * 2,
      y: layout.top + 1 + yOffset,
    },
    text,
  );
}

function appendChild(parent: Node, child: Node): void {
  parent.insertChild(child, parent.getChildCount());
}

Deno.test("layout", () => {
  const root = Yoga.Node.createDefault();
  root.setWidth(50);
  root.setHeight(30);
  root.setJustifyContent(Yoga.JUSTIFY_CENTER);
  root.setFlexDirection(Yoga.FLEX_DIRECTION_ROW);

  const nav = Yoga.Node.createDefault();
  nav.setWidth(10);
  nav.setHeight(10);


  const article = Yoga.Node.createDefault();
  article.setWidth(10);
  article.setHeight(10);

  const childNames = ["nav", "article"];
  appendChild(root, nav);
  appendChild(root, article);

  root.calculateLayout(50, 30, Yoga.DIRECTION_LTR);

  const actualLayouts: Layouts = {
    root: root.getComputedLayout(),
    children: [
      nav.getComputedLayout(),
      article.getComputedLayout(),
    ],
  };

  const expectedLayouts: Layouts = {
    root: {
      left: 0,
      top: 0,
      width: 50,
      height: 30,
      right: 0,
      bottom: 0,
    },
    children: [
      {
        left: 15,
        top: 0,
        width: 10,
        height: 10,
        right: 0,
        bottom: 0,
      },
      {
        left: 25,
        top: 0,
        width: 10,
        height: 10,
        right: 0,
        bottom: 0,
      },
    ],
  };

  const CLEAR_SCREEN = "\x1b[2J\x1b[3J\x1b[H";
  const output = [
    CLEAR_SCREEN,
    placeAt(["Actual:"], { x: 0, y: 0 }),
    drawLayout(actualLayouts.root, "root", 1),
    ...actualLayouts.children.map((layout, i) =>
      drawLayout(layout, childNames[i], 1)
    ),
    placeAt(["Expected:"], { x: 0, y: actualLayouts.root.height + 3 }),
    drawLayout(expectedLayouts.root, "root", actualLayouts.root.height + 3),
    ...expectedLayouts.children.map((layout, i) =>
      drawLayout(layout, childNames[i], actualLayouts.root.height + 3)
    ),
    moveCursorTo({
      x: 0,
      y: actualLayouts.root.height + 1 + expectedLayouts.root.height + 2,
    }),
  ].join("");
  console.log(output);

  assertEquals(actualLayouts, expectedLayouts);
});
