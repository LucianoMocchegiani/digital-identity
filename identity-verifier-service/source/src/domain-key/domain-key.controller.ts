import { Body, Controller, Post } from '@nestjs/common'
import { DomainKeyService } from './domain-key.service'
import { ImportDomainKeyDto } from './dto/import-domain-key.dto'

@Controller('domain-key')
export class DomainKeyController {
  constructor(private readonly domainKeyService: DomainKeyService) {}

  @Post()
  importDomainKey(@Body() body: ImportDomainKeyDto) {
    return this.domainKeyService.importDomainKey(body.keyId, body.privateJwk)
  }
}
