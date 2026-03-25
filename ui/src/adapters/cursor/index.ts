import type { UIAdapterModule } from "../types";
import { parseCursorStdoutLine } from "@paperplaneai/adapter-cursor-local/ui";
import { CursorLocalConfigFields } from "./config-fields";
import { buildCursorLocalConfig } from "@paperplaneai/adapter-cursor-local/ui";

export const cursorLocalUIAdapter: UIAdapterModule = {
  type: "cursor",
  label: "Cursor CLI (local)",
  parseStdoutLine: parseCursorStdoutLine,
  ConfigFields: CursorLocalConfigFields,
  buildAdapterConfig: buildCursorLocalConfig,
};
