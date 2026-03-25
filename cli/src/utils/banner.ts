import pc from "picocolors";

const PAPERPLANE_ART = [
  "██████╗  █████╗ ██████╗ ███████╗██████╗ ██╗      █████╗ ███╗   ██╗███████╗",
  "██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗██║     ██╔══██╗████╗  ██║██╔════╝",
  "██████╔╝███████║██████╔╝█████╗  ██████╔╝██║     ███████║██╔██╗ ██║█████╗  ",
  "██╔═══╝ ██╔══██║██╔═══╝ ██╔══╝  ██╔══██╗██║     ██╔══██║██║╚██╗██║██╔══╝  ",
  "██║     ██║  ██║██║     ███████╗██║  ██║███████╗██║  ██║██║ ╚████║███████╗",
  "╚═╝     ╚═╝  ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝",
] as const;

const TAGLINE = "Open-source orchestration for AI agent teams";

export function printPaperplaneCliBanner(): void {
  const lines = [
    "",
    ...PAPERPLANE_ART.map((line) => pc.cyan(line)),
    pc.blue("  ───────────────────────────────────────────────────────"),
    pc.bold(pc.white(`  ${TAGLINE}`)),
    "",
  ];

  console.log(lines.join("\n"));
}
