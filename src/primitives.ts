import { Point, Size } from "./components.ts";

const encoder = new TextEncoder();
export const encode = encoder.encode.bind(encoder);

export interface SavedTerminalState {
  isRaw: boolean;
}

export function storeTerminal(): SavedTerminalState {
  return {
    isRaw: Deno.isatty(Deno.stdout.rid) && Deno.isatty(Deno.stdin.rid),
  };
}

export function restoreTerminal(state: SavedTerminalState): void {
  Deno.stdin.setRaw(state.isRaw);
}

export function getTerminalSize(): Size {
  const size = Deno.consoleSize();
  return {
    width: size.columns,
    height: size.rows,
  };
}

export function writeBytes(bytes: Uint8Array) {
  Deno.stdout.writeSync(bytes);
}

export function writeString(s: string) {
  writeBytes(encode(s));
}

export function moveCursorTo(coordinates: Point): string {
  return `\x1b[${coordinates.y};${coordinates.x}H`;
}

/**
 * Draws a box with optional border and padding, and text inside.
 * @param text
 * @param box
 */
export function textInRectangle(
  lines: string[],
  box: Size & Point,
  border = true,
): string {
  const { x, y, width, height } = box;
  const borderWidth = border ? 2 : 0;

  const clippedAndPadded = clipAndPadLinesToSize(lines, {
    width: width - borderWidth,
    height: height - borderWidth,
  });
  const linesToPlace = border
    ? wrapInBorder(clippedAndPadded)
    : clippedAndPadded;
  return placeAt(linesToPlace, { x, y });
}

/**
 * Clips lines to the size of the box. Adds empty lines if needed. Adds empty space to the end of lines if needed.
 * @param lines
 * @param size
 */
export function clipAndPadLinesToSize(lines: string[], size: Size): string[] {
  const isNotTallEnough = lines.length < size.height;
  const correctAmountOfLines = isNotTallEnough
    ? lines.concat(Array(size.height - lines.length).fill(""))
    : lines.slice(0, size.height);

  const correctLengthOfLines = correctAmountOfLines.map((line) => {
    const isNotWideEnough = line.length < size.width;
    return isNotWideEnough
      ? line.padEnd(size.width)
      : line.slice(0, size.width);
  });

  return correctLengthOfLines;
}

const TOP_LEFT = ("┌");
const TOP_RIGHT = ("┐");
const BOTTOM_LEFT = ("└");
const BOTTOM_RIGHT = ("┘");
const HORIZONTAL = ("─");
const VERTICAL = ("│");

export const CLEAR_SCREEN = encode("\x1b[2J\x1b[3J\x1b[H");

export function wrapInBorder(lines: string[]): string[] {
  const width = lines[0]?.length ?? 0;

  const top = TOP_LEFT + HORIZONTAL.repeat(width) + TOP_RIGHT;
  const bottom = BOTTOM_LEFT + HORIZONTAL.repeat(width) + BOTTOM_RIGHT;

  const wrappedLines = lines.map((line) => VERTICAL + line + VERTICAL);

  return [top, ...wrappedLines, bottom];
}

export function placeAt(lines: string[], coordinates: Point): string {
  return lines
    .map((line, i) =>
      moveCursorTo({ x: coordinates.x, y: coordinates.y + i }) + line
    )
    .join("");
}

export function drawBorder(box: Size & Point, text: string): string {
  return textInRectangle([text], box);
}
