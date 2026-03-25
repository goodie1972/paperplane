import type { UIAdapterModule } from "../types";
import { parsePiStdoutLine } from "@paperplaneai/adapter-pi-local/ui";
import { PiLocalConfigFields } from "./config-fields";
import { buildPiLocalConfig } from "@paperplaneai/adapter-pi-local/ui";

export const piLocalUIAdapter: UIAdapterModule = {
  type: "pi_local",
  label: "Pi (local)",
  parseStdoutLine: parsePiStdoutLine,
  ConfigFields: PiLocalConfigFields,
  buildAdapterConfig: buildPiLocalConfig,
};
