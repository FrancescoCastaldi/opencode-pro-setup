export const ContextPruning = async () => {
  return {
    "experimental.session.compacting": async (input, output) => {
      output.context.push(`Remove any tool outputs that are no longer relevant to the current task. Keep only:
- The most recent file reads and searches
- Results of commands that produced errors or important data
- References to files currently being modified`)
    },
  }
}
