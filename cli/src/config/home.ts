import os from "node:os";
import path from "node:path";

const DEFAULT_INSTANCE_ID = "default";
const INSTANCE_ID_RE = /^[a-zA-Z0-9_-]+$/;

export function resolvePaperplaneHomeDir(): string {
  const envHome = process.env.PAPERPLANE_HOME?.trim();
  if (envHome) return path.resolve(expandHomePrefix(envHome));
  return path.resolve(os.homedir(), ".paperplane");
}

export function resolvePaperplaneInstanceId(override?: string): string {
  const raw = override?.trim() || process.env.PAPERPLANE_INSTANCE_ID?.trim() || DEFAULT_INSTANCE_ID;
  if (!INSTANCE_ID_RE.test(raw)) {
    throw new Error(
      `Invalid instance id '${raw}'. Allowed characters: letters, numbers, '_' and '-'.`,
    );
  }
  return raw;
}

export function resolvePaperplaneInstanceRoot(instanceId?: string): string {
  const id = resolvePaperplaneInstanceId(instanceId);
  return path.resolve(resolvePaperplaneHomeDir(), "instances", id);
}

export function resolveDefaultConfigPath(instanceId?: string): string {
  return path.resolve(resolvePaperplaneInstanceRoot(instanceId), "config.json");
}

export function resolveDefaultContextPath(): string {
  return path.resolve(resolvePaperplaneHomeDir(), "context.json");
}

export function resolveDefaultEmbeddedPostgresDir(instanceId?: string): string {
  return path.resolve(resolvePaperplaneInstanceRoot(instanceId), "db");
}

export function resolveDefaultLogsDir(instanceId?: string): string {
  return path.resolve(resolvePaperplaneInstanceRoot(instanceId), "logs");
}

export function resolveDefaultSecretsKeyFilePath(instanceId?: string): string {
  return path.resolve(resolvePaperplaneInstanceRoot(instanceId), "secrets", "master.key");
}

export function resolveDefaultStorageDir(instanceId?: string): string {
  return path.resolve(resolvePaperplaneInstanceRoot(instanceId), "data", "storage");
}

export function resolveDefaultBackupDir(instanceId?: string): string {
  return path.resolve(resolvePaperplaneInstanceRoot(instanceId), "data", "backups");
}

export function expandHomePrefix(value: string): string {
  if (value === "~") return os.homedir();
  if (value.startsWith("~/")) return path.resolve(os.homedir(), value.slice(2));
  return value;
}

export function describeLocalInstancePaths(instanceId?: string) {
  const resolvedInstanceId = resolvePaperplaneInstanceId(instanceId);
  const instanceRoot = resolvePaperplaneInstanceRoot(resolvedInstanceId);
  return {
    homeDir: resolvePaperplaneHomeDir(),
    instanceId: resolvedInstanceId,
    instanceRoot,
    configPath: resolveDefaultConfigPath(resolvedInstanceId),
    embeddedPostgresDataDir: resolveDefaultEmbeddedPostgresDir(resolvedInstanceId),
    backupDir: resolveDefaultBackupDir(resolvedInstanceId),
    logDir: resolveDefaultLogsDir(resolvedInstanceId),
    secretsKeyFilePath: resolveDefaultSecretsKeyFilePath(resolvedInstanceId),
    storageDir: resolveDefaultStorageDir(resolvedInstanceId),
  };
}
