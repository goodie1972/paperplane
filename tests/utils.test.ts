import { describe, expect, it } from "vitest";
import { greet, add } from "../src/utils.js";

describe("utils", () => {
  it("greet returns greeting message", () => {
    expect(greet("World")).toBe("Hello, World!");
  });

  it("add returns sum of two numbers", () => {
    expect(add(2, 3)).toBe(5);
  });
});
