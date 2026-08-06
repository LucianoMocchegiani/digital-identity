import { Injectable, Logger, OnModuleDestroy, OnModuleInit } from '@nestjs/common'
import { ConfigService } from '@nestjs/config'
import * as os from 'os'
import { collectDefaultMetrics, Gauge, register } from 'prom-client'

/** API interna de Node.js para introspección de handles activos (no forma parte de los tipados públicos). */
interface ProcessWithHandles extends NodeJS.Process {
  _getActiveHandles?: () => unknown[]
}

/**
 * Recopila métricas de Prometheus y opcionalmente registra estadísticas del runtime (memoria, CPU, estado de BD).
 *
 * El monitoreo del runtime se habilita cuando la variable de entorno `METRICS_MONITOR_INTERVAL_MS`
 * se establece con un número positivo. Todas las estadísticas se emiten a nivel DEBUG
 * mediante el logger JSON estructurado.
 */
@Injectable()
export class MetricsService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(MetricsService.name)
  private monitorInterval: NodeJS.Timeout | null = null

  private readonly activeHandlesGauge = new Gauge({
    name: 'node_active_handles_total',
    help: 'Number of active libuv handles in the Node process',
  })

  constructor(
    private readonly configService: ConfigService,
  ) {}

  onModuleInit(): void {
    register.clear()
    collectDefaultMetrics({ register })

    setInterval(() => {
      try {
        const proc = process as ProcessWithHandles
        const handles = typeof proc._getActiveHandles === 'function'
          ? proc._getActiveHandles().length
          : 0
        this.activeHandlesGauge.set(handles)
      } catch {
        // La API interna de Node puede no estar disponible en todos los runtimes
      }
    }, 5000)

    const intervalMs = this.configService.get<number>('config.METRICS_MONITOR_INTERVAL_MS')
    if (intervalMs && intervalMs > 0) {
      this.startRuntimeMonitor(intervalMs)
    } else {
      this.logger.log('Runtime monitor disabled (METRICS_MONITOR_INTERVAL_MS not set or 0)', MetricsService.name)
    }
  }

  onModuleDestroy(): void {
    if (this.monitorInterval !== null) {
      clearInterval(this.monitorInterval)
      this.monitorInterval = null
      this.logger.log('Runtime monitor stopped', MetricsService.name)
    }
  }

  private startRuntimeMonitor(intervalMs: number): void {
    this.monitorInterval = setInterval(() => this.logRuntimeStats(), intervalMs)
    this.logger.log(`Runtime monitor started (interval: ${intervalMs}ms)`, MetricsService.name)
  }

  /** Captura el uso de memoria y promedio de carga de CPU. */
  private logRuntimeStats(): void {
    const mem = process.memoryUsage()
    const toMB = (b: number) => (b / 1024 / 1024).toFixed(2)
    const loadAvg = os.loadavg()

    const stats = {
      timestamp: new Date().toISOString(),
      memory: {
        rss: `${toMB(mem.rss)} MB`,
        heapTotal: `${toMB(mem.heapTotal)} MB`,
        heapUsed: `${toMB(mem.heapUsed)} MB`,
      },
      cpu: {
        loadAvg1m: loadAvg[0].toFixed(2),
      },
    }

    this.logger.debug(stats, MetricsService.name)
  }

  async getMetrics(): Promise<string> {
    return register.metrics()
  }

  getContentType(): string {
    return register.contentType
  }
}