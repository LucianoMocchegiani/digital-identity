import {
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Res,
} from "@nestjs/common";
import { ApiOkResponse, ApiOperation } from "@nestjs/swagger";
import { Response } from "express";
import { MetricsService } from "./metrics.service";

@Controller('metrics')
export class MetricsController {
  constructor(private readonly metricsService: MetricsService) {}

  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: "Obtener métricas en formato Prometheus" })
  @ApiOkResponse({ description: "Métricas exportadas correctamente." })
  async metrics(@Res() res: Response): Promise<void> {
    res.setHeader("Content-Type", this.metricsService.getContentType());
    res.send(await this.metricsService.getMetrics());
  }
}
