// Cross-platform notification plugin
// Supports macOS (osascript), Windows (PowerShell), and Linux (notify-send)
// Falls back to console output if native notifications are unavailable

export const NotificationPlugin = async ({ $ }) => {
  const platform = process.platform

  return {
    event: async ({ event }) => {
      if (event.type === "session.idle") {
        try {
          if (platform === "darwin") {
            await $`osascript -e 'display notification "Session completed!" with title "OpenCode" subtitle "Task finished" sound name "default"'`
          } else if (platform === "win32") {
            // Windows: try PowerShell toast, fallback to beep + console
            await $`powershell -Command "
              try {
                $Notification = [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType=WindowsRuntime]::CreateToastNotifier()
                $Xml = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)
                $TextNodes = $Xml.GetElementsByTagName('text')
                $TextNodes.Item(0).AppendChild($Xml.CreateTextNode('OpenCode')) > $null
                $TextNodes.Item(1).AppendChild($Xml.CreateTextNode('Task finished!')) > $null
                $Notification.Show([Windows.UI.Notifications.ToastNotification]::new($Xml))
              } catch {
                Write-Host '[OpenCode] Session completed!' -ForegroundColor Green
                [Console]::Beep(440, 200)
              }
            "` 2>$null
          } else {
            // Linux
            await $`notify-send "OpenCode" "Task finished!" 2>/dev/null || echo "[OpenCode] Session completed!"`
          }
        } catch {
          // Silent fallback
        }
      }

      if (event.type === "session.error") {
        try {
          if (platform === "darwin") {
            await $`osascript -e 'display notification "Session encountered an error" with title "OpenCode" subtitle "Error" sound name "Basso"'`
          } else if (platform === "win32") {
            await $`powershell -Command "
              try {
                Write-Host '[OpenCode] Session encountered an error' -ForegroundColor Red
                [Console]::Beep(800, 200)
              } catch {}
            "`
          } else {
            await $`notify-send -u critical "OpenCode" "Error occurred!" 2>/dev/null || echo "[OpenCode] Session error!"`
          }
        } catch {
          // Silent fallback
        }
      }
    },
  }
}
