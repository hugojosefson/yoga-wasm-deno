export const ROOT = "root" as const;

export interface Component extends Drawable {
  parent: Component | typeof ROOT;
  size: Size;
  position: Point;
}

export class BaseComponent implements Component {
  constructor(
    public parent: Component,
    public size: Size,
    public position: Point,
    public children: Component[] = [],
  ) {}

  draw(): DrawOutput {
    return this.children.flatMap((child) => child.draw());
  }
}

/**
 * A component that splits its area into equal sized children, vertically.
 * When drawing, it will first divide the area into equal sized children, and update their relative positions always counting from {x: 0, y: 0}, and sizes based on the area.
 * It will then draw its children in order, from top to bottom.
 * The lines drawn by the first child, comes first. Then the lines drawn by the second child, and so on.
 */
export class VerticalLayout extends BaseComponent {
  constructor(
    parent: Component,
    size: Size,
    position: Point,
    children: Component[] = [],
  ) {
    super(parent, size, position, children);
  }

  draw(): DrawOutput {
    const { size, children } = this;
    const childSize = {
      width: size.width,
      height: size.height / children.length,
    };
    const childPosition = { x: 0, y: 0 };
    const childDraws = children.flatMap((child, index) => {
      child.size = { ...childSize };
      child.position = { ...childPosition };
      const draw = child.draw();
      childPosition.y += childSize.height;
      return draw;
    });
    return childDraws;
  }
}

/**
 * A component that splits its area into equal sized children, horizontally.
 * When drawing, it will first divide the area into equal sized children, and update their relative positions always counting from {x: 0, y: 0}, and sizes based on the area.
 * It will then draw its children in order, from left to right.
 * The output is a combination of the lines drawn from each child.
 * The first line of the output is a concatenation of the first line of each child, without any line-breaks.
 * The second line of the output is a concatenation of the second line of each child, without any line-breaks.
 * And so on.
 */
export class HorizontalLayout extends BaseComponent {
  constructor(
    parent: Component,
    size: Size,
    position: Point,
    children: Component[] = [],
  ) {
    super(parent, size, position, children);
  }

  draw(): DrawOutput {
    const { size, children } = this;
    const childSize = {
      width: size.width / children.length,
      height: size.height,
    };
    const childPosition = { x: 0, y: 0 };
    const childDraws = children.map((child) => {
      child.size = { ...childSize };
      child.position = { ...childPosition };
      const draw = child.draw();
      childPosition.x += childSize.width;
      return draw;
    });
    const output: DrawOutput = [];
    for (let i = 0; i < childDraws[0].length; i++) {
      output.push(childDraws.map((draw) => draw[i]).join(""));
    }
    return output;
  }
}

export class Screen implements Component {
  public parent = ROOT;
  public position = { x: 0, y: 0 };

  constructor(public size: Size, public children: Component[] = []) {
  }

  draw(): DrawOutput {
    return this.children.flatMap((child) => child.draw());
  }
}

export class Text implements Component {
  constructor(
    public parent: Component,
    public size: Size,
    public position: Point,
    public text: string,
  ) {}

  draw(): DrawOutput {
    // TODO: should calculate the size based on its parent, or possibly get the size as an argument to draw().
    const { size, text } = this;
    const lines = text.split("\n");
    const output: DrawOutput = [];
    for (let i = 0; i < size.height; i++) {
      const line = lines[i] ?? "";
      output.push(line.padEnd(size.width, " ").slice(0, size.width));
    }
    return output;
  }
}

export interface Size {
  width: number;
  height: number;
}

export interface Point {
  x: number;
  y: number;
}

export type DrawOutput = string[];

export interface Drawable {
  draw(): DrawOutput;
}

export class Box extends BaseComponent {
  constructor(
    size: Size,
    parent: Component,
    position: Point,
    children: Component[] = [],
    public border: Border = BORDER_SIMPLE,
    public padding: Padding = PADDING_0,
    public title?: string,
  ) {
    super(parent, size, position, children);
  }

  /**
   * If there is a border, the size of the drawable area is reduced by the size of the border.
   * If padding is set, the drawable area will be reduced by the padding.
   * Regarding the title, the box will always be drawn with the title centered.
   * If the title is too long, it will be truncated.
   * If the title is undefined, it will be ignored.
   * If the border is set, the title will be drawn over the border with one space on either side of the title.
   * If the border is not set, the title will be drawn on the first line, and the drawable area will be reduced by one line.
   */
  draw(): DrawOutput {
    const { size, border, padding } = this;
    const drawableSize = {
      width: size.width - border.vertical.length * 2 - padding.left -
        padding.right,
      height: size.height - (border.vertical.length ? 2 : 0) - padding.top -
        padding.bottom,
    };
    const drawablePosition = {
      x: padding.left + border.vertical.length,
      y: padding.top + (border.vertical.length ? 1 : 0),
    };
    const childrenOutput = new BaseComponent(
      this,
      drawableSize,
      drawablePosition,
      this.children,
    );
    const innerContent = childrenOutput.draw();
    const output: DrawOutput = [];
    const title = this.title ?? "";
    const paddingAroundTitle: number = title ? 2 : 0;
    const accountForBorderCornersOnTitleLine =
      `${border.cornerTopLeft}${border.cornerTopRight}`.length;
    const titleLength = Math.min(
      title.length,
      drawableSize.width - paddingAroundTitle -
        accountForBorderCornersOnTitleLine,
    );
    const horizontalBorderLengthEachSide = Math.floor(
      (drawableSize.width - titleLength) / 2,
    );
    const titleLine = title
      ? [
        border.cornerTopLeft,
        border.horizontal.repeat(horizontalBorderLengthEachSide),
        title.slice(0, titleLength - 2).padEnd(titleLength - 2, " "),
        border.horizontal.repeat(horizontalBorderLengthEachSide),
        border.cornerTopRight,
      ].join("")
      : [
        border.cornerTopLeft,
        border.horizontal.repeat(drawableSize.width),
        border.cornerTopRight,
      ].join("");
    output.push(titleLine);
    output.push(
      ...innerContent.map((line) =>
        `${border.vertical}${line}${border.vertical}`
      ),
    );
    output.push([
      border.cornerBottomLeft,
      border.horizontal.repeat(drawableSize.width),
      border.cornerBottomRight,
    ].join(""));
    return output;
  }
}

export interface Border {
  cornerTopLeft: string;
  cornerTopRight: string;
  cornerBottomLeft: string;
  cornerBottomRight: string;
  horizontal: string;
  vertical: string;
}

export const BORDER_SIMPLE: Border = {
  cornerTopLeft: "┌",
  cornerTopRight: "┐",
  cornerBottomLeft: "└",
  cornerBottomRight: "┘",
  horizontal: "─",
  vertical: "│",
};

export interface Padding {
  top: number;
  right: number;
  bottom: number;
  left: number;
}

export const PADDING_0: Padding = {
  top: 0,
  right: 0,
  bottom: 0,
  left: 0,
};

export const PADDING_1: Padding = {
  top: 1,
  right: 1,
  bottom: 1,
  left: 1,
};

export class Modal extends BaseComponent {}

/**
 * ##### TextBox
 *
 * - [x] Extends `Component`.
 * - [ ] Text box that receives its data (continuously) from a
 *       [ReadableStream](https://developer.mozilla.org/en-US/docs/Web/API/ReadableStream),
 *       such as
 *       [Process.stdout](https://deno.land/api@v1.29.1?s=Deno.Process#prop_stdout).
 * - [ ] Some
 *       [TransformStream](https://developer.mozilla.org/en-US/docs/Web/API/TransformStream)s
 *       transform the data as-is, and some transform the data into a TUI
 *       primitive.
 * - [ ] Text that is too large for the text box should be scrollable.
 *
 * ###### Transform data as-is
 *
 * - [ ] Use
 *       [TransformStream](https://developer.mozilla.org/en-US/docs/Web/API/TransformStream)
 *       to transform the data from the ReadableStream, such as to add colors.
 *
 * ###### Transform data into TUI primitives
 *
 * - [ ] Use
 *       [TransformStream](https://developer.mozilla.org/en-US/docs/Web/API/TransformStream)
 *       to wrap text lines.
 * - [ ] Use
 *       [TransformStream](https://developer.mozilla.org/en-US/docs/Web/API/TransformStream)
 *       to clip text to the size of the text box, taking into account any scroll
 *       position.
 * - [ ] Transform text into bytes to be sent to the terminal, including ANSI
 *       escape codes for positioning the cursor, colors, etc.
 *   - [ ] Use
 *         [TextEncoder](https://developer.mozilla.org/en-US/docs/Web/API/TextEncoder),
 *         or possibly
 *         [TextEncoderStream](https://developer.mozilla.org/en-US/docs/Web/API/TextEncoderStream)
 *         to convert to bytes.
 * - [ ] Use
 *       [WritableStream](https://developer.mozilla.org/en-US/docs/Web/API/WritableStream)
 *       to write to the
 *       [WritableStream](https://developer.mozilla.org/en-US/docs/Web/API/WritableStream)
 *       of the terminal.
 */
export class TextBox extends Box {
}
