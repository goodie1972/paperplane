import os from "node:os";
import path from "node:path";
import { afterEach, describe, expect, it } from "vitest";
import {
  describeLocalInstancePaths,
  expandHomePrefix,
  resolvePaperplaneHomeDir,
  resolvePaperplaneInstanceId,
} from "../config/home.js";

const ORIGINAL_ENV = { ...process.env };

describe("home path resolution", () => {
  afterEach(() => {
    process.env = { ...ORIGINAL_ENV };
  });

  it("defaults to ~/.paperplane and default instance", () => {
    delete process.env.PAPERPLANE_HOME;
    delete process.env.PAPERPLANE_INSTANCE_ID;

    const paths = describeLocalInstancePaths();
    expect(paths.homeDir).toBe(path.resolve(os.homedir(), ".paperplane"));
    expect(paths.instanceId).toBe("default");
    expect(paths.configPath).toBe(path.resolve(os.homedir(), ".paperplane", "instances", "default", "config.json"));
  });

  it("supports PAPERPLANE_HOME and explicit instance ids", () => {
    process.env.PAPERPLANE_HOME = "~/paperplane-home";

    const home = resolvePaperplaneHomeDir();
    expect(home).toBe(path.resolve(os.homedir(), "paperplane-home"));
    expect(resolvePaperplaneInstanceId("dev_1")).toBe("dev_1");
  });

  it("rejects invalid instance ids", () => {
    expect(() => resolvePaperplaneInstanceId("bad/id")).toThrow(/Invalid instance id/);
  });

  it("expands ~ prefixes", () => {
    expect(expandHomePrefix("~")).toBe(os.homedir());
    expect(expandHomePrefix("~/x/y")).toBe(path.resolve(os.homedir(), "x/y"));
  });
});
