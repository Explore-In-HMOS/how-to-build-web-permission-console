export interface ConsoleLogEntry {
  id: number;
  level: MessageLevel;
  levelLabel: string;
  message: string;
  sourceId: string;
  line: number;
}

@ObservedV2
export class WebConsoleStore {
  @Trace logs: ConsoleLogEntry[] = [];
  private seq: number = 0;

  addFromConsoleMessage(message: ConsoleMessage): void {
    const level: MessageLevel = message.getMessageLevel();
    const entry: ConsoleLogEntry = {
      id: this.seq++,
      level: level,
      levelLabel: WebConsoleStore.levelToLabel(level),
      message: message.getMessage(),
      sourceId: message.getSourceId(),
      line: message.getLineNumber()
    };
    this.logs = [entry, ...this.logs].slice(0, 100);
  }

  clear(): void {
    this.logs = [];
  }

  static levelToLabel(level: MessageLevel): string {
    switch (level) {
      case MessageLevel.Debug:
        return 'DEBUG';
      case MessageLevel.Info:
        return 'INFO';
      case MessageLevel.Log:
        return 'LOG';
      case MessageLevel.Warn:
        return 'WARN';
      case MessageLevel.Error:
        return 'ERROR';
      default:
        return 'LOG';
    }
  }

  static levelToColor(level: MessageLevel): Resource {
    switch (level) {
      case MessageLevel.Debug:
        return $r('app.color.level_debug');
      case MessageLevel.Info:
        return $r('app.color.level_info');
      case MessageLevel.Log:
        return $r('app.color.level_log');
      case MessageLevel.Warn:
        return $r('app.color.level_warn');
      case MessageLevel.Error:
        return $r('app.color.level_error');
      default:
        return $r('app.color.level_log');
    }
  }
}
