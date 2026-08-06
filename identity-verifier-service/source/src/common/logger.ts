import { Injectable, LoggerService } from '@nestjs/common'

import { LogLevel } from '../config/environment.config'

/** Mapa de prioridades utilizado para filtrar la salida de logs según el nivel mínimo configurado. */
const LOG_LEVEL_PRIORITY: Record<LogLevel, number> = {
  DEBUG: 0,
  INFO: 1,
  WARN: 2,
  ERROR: 3,
}

/**
 * Produce logs JSON estructurados compatibles con Elasticsearch.
 *
 * Reemplaza el logger predeterminado de NestJS para que cada línea de log
 * (incluidos los internos del framework) se emita como un objeto JSON de
 * una sola línea a stdout/stderr.
 * El nivel de log es configurable mediante la variable de entorno `LOG_LEVEL`.
 */
@Injectable()
export class JsonLoggerService implements LoggerService {
  private readonly service = 'identity-verifier'
  private readonly minLevel: number

  constructor() {
    const logLevel = (process.env.LOG_LEVEL ?? 'INFO').toUpperCase() as LogLevel
    this.minLevel = LOG_LEVEL_PRIORITY[logLevel] ?? LOG_LEVEL_PRIORITY.INFO
  }

  log(message: unknown, ...optionalParams: unknown[]): void {
    this.printLog('INFO', message, ...optionalParams)
  }

  error(message: unknown, ...optionalParams: unknown[]): void {
    this.printLog('ERROR', message, ...optionalParams)
  }

  warn(message: unknown, ...optionalParams: unknown[]): void {
    this.printLog('WARN', message, ...optionalParams)
  }

  debug(message: unknown, ...optionalParams: unknown[]): void {
    this.printLog('DEBUG', message, ...optionalParams)
  }

  verbose(message: unknown, ...optionalParams: unknown[]): void {
    this.printLog('DEBUG', message, ...optionalParams)
  }

  /**
   * Construye un objeto JSON estructurado y lo escribe en el flujo correspondiente.
   *
   * Sigue la convención de NestJS donde el último parámetro de tipo string se
   * trata como el contexto de logging (nombre de clase/módulo) y todo lo
   * intermedio se recopila en un array `details`.
   *
   * Los logs de nivel ERROR van a stderr; todos los demás niveles van a stdout
   * para que los entornos de contenedores (Docker, K8s) y los recolectores de
   * logs puedan clasificarlos automáticamente.
   */
  private printLog(level: string, message: unknown, ...optionalParams: unknown[]): void {
    if ((LOG_LEVEL_PRIORITY[level as LogLevel] ?? 0) < this.minLevel) return

    try {
      const timestamp = new Date().toISOString()

      let context = 'System'
      let details = optionalParams

      if (optionalParams.length > 0) {
        const lastParam = optionalParams[optionalParams.length - 1]
        if (typeof lastParam === 'string') {
          context = lastParam
          details = optionalParams.slice(0, -1)
        }
      }

      const logObject: Record<string, unknown> = {
        timestamp,
        level,
        service: this.service,
        context,
        message: this.formatMessage(message),
      }

      if (details.length > 0) {
        logObject.details = details.map((d) => this.formatMessage(d))
      }

      const output = JSON.stringify(logObject, this.getCircularReplacer())

      if (level === 'ERROR') {
        process.stderr.write(output + '\n')
      } else {
        process.stdout.write(output + '\n')
      }
    } catch (err) {
      process.stderr.write(`[LOGGER_ERROR] ${level} ${message} ${err}\n`)
    }
  }

  /** Extrae nombre, mensaje y stack trace de instancias de Error; deja pasar otros valores sin modificar. */
  private formatMessage(message: unknown): unknown {
    if (message instanceof Error) {
      return {
        error: message.name,
        message: message.message,
        stack: message.stack,
      }
    }
    return message
  }

  /**
   * Crea un replacer de JSON que detecta referencias circulares mediante un WeakSet
   * y las sustituye con la cadena `[Circular]`.
   */
  private getCircularReplacer(): (key: string, value: unknown) => unknown {
    const seen = new WeakSet()
    return (_key: string, value: unknown) => {
      if (typeof value === 'object' && value !== null) {
        if (seen.has(value)) return '[Circular]'
        seen.add(value)
      }
      return value
    }
  }
}
