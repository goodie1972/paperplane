import type { UIAdapterModule } from "../types";
import { parseGeminiStdoutLine } from "@paperplaneai/adapter-gemini-local/ui";
import { GeminiLocalConfigFields } from "./config-fields";
import { buildGeminiLocalConfig } from "@paperplaneai/adapter-gemini-local/ui";

export const geminiLocalUIAdapter: UIAdapterModule = {
  type: "gemini_local",
  label: "Gemini CLI (local)",
  parseStdoutLine: parseGeminiStdoutLine,
  ConfigFields: GeminiLocalConfigFields,
  buildAdapterConfig: buildGeminiLocalConfig,
};
