export const EnvProtection = async () => {
  return {
    "tool.execute.before": async (input) => {
      if (input.tool === "read" && input.args.filePath && input.args.filePath.includes(".env")) {
        throw new Error("Access denied: reading .env files is not allowed")
      }
    },
  }
}
