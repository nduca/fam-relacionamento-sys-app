# fam-relacionamento-sys-app

System API MuleSoft responsável por encapsular o acesso aos serviços de relacionamento e processo seletivo disponibilizados pelos backends da FAM.

A aplicação faz parte da arquitetura API-led Connectivity da FAM e representa a camada **System**, mantendo seus contratos e payloads proximos aos contratos dos sistemas de origem.

## Visao Geral

```text
Salesforce / Consumidores
          |
          v
Experience API
fam-salesforce-bot-exp-app
          |
          v
Process API
fam-candidato-prc-app
          |
          v
System API
fam-relacionamento-sys-app
          |
          v
Backends FAM
```

Responsabilidades desta aplicacao:

- expor o contrato da `fam-relacionamento-sys-api`;
- validar requisicoes por meio do APIKit;
- encapsular o acesso aos backends da FAM;
- preservar o modelo proximo ao contrato do backend;
- aplicar logging estruturado;
- garantir rastreabilidade por `correlationId`;
- padronizar respostas de erro;
- preparar a aplicacao para execucao no CloudHub 2.0.

Transformacoes para modelo canonico, composicao e orquestracao entre dominios pertencem a camada Process e nao devem ser adicionadas a esta System API.

---

## Estado Atual

A aplicacao encontra-se funcional para desenvolvimento e testes da arquitetura API-led.

Atualmente:

```text
HTTP Listener                REAL
APIKit                       REAL
Validacao de contrato        REAL
Logging                      REAL
Correlation ID               REAL
Error Handling               REAL
Duration                     REAL
Resource Flows               REAL
Integracao HTTP com FAM      DESABILITADA
Autenticacao FAM             DESABILITADA NO FLUXO
Resposta dos backends FAM    MOCK
```

As respostas FAM estao temporariamente simuladas por arquivos DataWeave externos.

Este estado permite desenvolver e testar:

```text
Process API
    |
    v
System API
    |
    v
Mock FAM
```

sem dependencia da conectividade com os backends da instituicao.

---

## API Specification

A aplicacao segue abordagem **contract-first**.

O contrato RAML e publicado separadamente no Exchange:

```text
fam-relacionamento-sys-api
```

A Mule Application:

```text
fam-relacionamento-sys-app
```

consome a API Specification como dependencia Maven.

Configuracao atual:

```text
API Specification : fam-relacionamento-sys-api
Version           : 1.0.0
Mule Application  : fam-relacionamento-sys-app
Version           : 1.0.0-SNAPSHOT
```

O contrato permanece como fonte de verdade da interface da API.

---

## Recursos Implementados

Atualmente estao implementadas as operacoes de processo seletivo:

```text
POST /candidatos/processos-seletivos/cursos

POST /candidatos/processos-seletivos/turnos

POST /candidatos/processos-seletivos/polos

POST /candidatos/processos-seletivos/formas-ingresso
```

Os flows sao gerenciados pelo APIKit e implementados em:

```text
src/main/mule/implementation/candidatos/flows/processo-seletivo-flow.xml
```

Enquanto a conectividade com a FAM nao estiver disponivel, cada operacao utiliza um DWL responsavel por preparar uma resposta equivalente ao backend.

```text
preparar-resposta-cursos.dwl

preparar-resposta-turnos.dwl

preparar-resposta-polos.dwl

preparar-resposta-formas-ingresso.dwl
```

Os nomes dos componentes nao identificam explicitamente o comportamento como mock para que permaneçam validos quando o conteudo passar a utilizar a resposta real da FAM.

---

## Fluxo Principal

O fluxo principal da aplicacao e:

```text
HTTP Listener
      |
      v
Definir Inicio da Requisicao
      |
      v
Registrar API_REQUEST
      |
      v
APIKit Router
      |
      v
Resource Flow
      |
      v
Registrar API_RESPONSE
```

Em caso de falha:

```text
HTTP Listener
      |
      v
APIKit / Resource Flow
      |
      X
      |
      v
Error Handler Global
      |
      v
Preparar Resposta de Erro
      |
      v
Registrar API_ERROR
```

Arquivo principal:

```text
src/main/mule/fam-relacionamento-sys-app-flow.xml
```

---

## Estrutura do Projeto

```text
fam-relacionamento-sys-app/
|
|-- pom.xml
|-- mule-artifact.json
|-- README.md
|
|-- build/
|   `-- parent/
|       `-- pom.xml
|
|-- src/
|   |
|   |-- main/
|   |   |
|   |   |-- mule/
|   |   |   |
|   |   |   |-- fam-relacionamento-sys-app-flow.xml
|   |   |   |
|   |   |   |-- common/
|   |   |   |   |-- global.xml
|   |   |   |   |-- error-handler.xml
|   |   |   |   |-- log-subflow.xml
|   |   |   |   |
|   |   |   |   `-- fam/
|   |   |   |       `-- autenticar-parceiro-fam-subflow.xml
|   |   |   |
|   |   |   `-- implementation/
|   |   |       `-- candidatos/
|   |   |           `-- flows/
|   |   |               `-- processo-seletivo-flow.xml
|   |   |
|   |   `-- resources/
|   |       |
|   |       |-- dwl/
|   |       |   |
|   |       |   |-- preparar-resposta-cursos.dwl
|   |       |   |-- preparar-resposta-turnos.dwl
|   |       |   |-- preparar-resposta-polos.dwl
|   |       |   |-- preparar-resposta-formas-ingresso.dwl
|   |       |   |
|   |       |   `-- common/
|   |       |       |-- preparar-mensagem-log-requisicao.dwl
|   |       |       |-- preparar-mensagem-log-resposta.dwl
|   |       |       |-- preparar-mensagem-log-erro.dwl
|   |       |       |-- preparar-requisicao-autenticar-parceiro-fam.dwl
|   |       |       `-- preparar-resposta-padrao-erro.dwl
|   |       |
|   |       |-- properties/
|   |       |   |-- config.yaml
|   |       |   |-- config-local.yaml
|   |       |   |-- config-dev.yaml
|   |       |   |-- config-hml.yaml
|   |       |   |-- config-prod.yaml
|   |       |   `-- config-secure-<ambiente>.yaml
|   |       |
|   |       `-- log4j2.xml
|   |
|   `-- test/
|       |-- munit/
|       `-- resources/
|
`-- exchange-docs/
    `-- home.md
```

---

## Organizacao dos Arquivos Mule

A aplicacao separa responsabilidades da seguinte forma:

### `fam-relacionamento-sys-app-flow.xml`

Contem:

- HTTP Listener principal;
- APIKit Router;
- medicao de tempo da requisicao;
- logging de entrada e saida;
- APIKit Console;
- referencia para o Error Handler global.

### `common/global.xml`

Contem configuracoes globais:

- APIKit;
- HTTP Listener;
- Configuration Properties;
- Secure Configuration Properties;
- Object Store;
- Caching Strategy;
- HTTP Request Configurations para FAM;
- configuracao preparada para API Autodiscovery.

### `common/error-handler.xml`

Centraliza o tratamento tecnico de erros da aplicacao.

### `common/log-subflow.xml`

Centraliza os eventos estruturados:

```text
API_REQUEST
API_RESPONSE
API_ERROR
```

### `common/fam/autenticar-parceiro-fam-subflow.xml`

Contem a estrutura preparada para autenticacao de parceiro junto a FAM, incluindo:

```text
Cache do Token FAM
        |
        v
Preparar Requisicao de Autenticacao FAM
        |
        v
Autenticar Parceiro FAM
        |
        v
Validar Retorno da Autenticacao
        |
        v
Extrair Token de Acesso FAM
```

A utilizacao desse subflow nos recursos permanece desabilitada enquanto a conectividade real com a FAM nao estiver disponivel.

---

## DataWeave

Transformacoes e construcao de payloads devem permanecer preferencialmente em arquivos `.dwl` externos.

Principio utilizado:

```text
XML
-> fluxo
-> orquestracao
-> configuracao

DWL
-> transformacao
-> mapeamento
-> construcao de payload
```

Exemplo:

```xml
<ee:set-payload resource="dwl/preparar-resposta-cursos.dwl" />
```

Essa separacao reduz a quantidade de DataWeave inline e melhora a leitura dos flows no Anypoint Studio.

---

## Logging

A aplicacao utiliza logging estruturado em JSON.

Categorias:

```text
br.com.fam.api.request
br.com.fam.api.response
br.com.fam.api.error
```

### API_REQUEST

Exemplo:

```json
{
  "event": "API_REQUEST",
  "correlationId": "5e9a8fc4-5a53-4c38-9a5d-dce9c014fb80",
  "application": "fam-relacionamento-sys-app",
  "version": "1.0.0-SNAPSHOT",
  "environment": "LOCAL",
  "method": "POST",
  "path": "/candidatos/processos-seletivos/cursos"
}
```

### API_RESPONSE

Exemplo:

```json
{
  "event": "API_RESPONSE",
  "correlationId": "5e9a8fc4-5a53-4c38-9a5d-dce9c014fb80",
  "application": "fam-relacionamento-sys-app",
  "version": "1.0.0-SNAPSHOT",
  "environment": "LOCAL",
  "statusCode": 200,
  "durationMs": 150
}
```

### API_ERROR

Exemplo:

```json
{
  "event": "API_ERROR",
  "correlationId": "5e9a8fc4-5a53-4c38-9a5d-dce9c014fb80",
  "application": "fam-relacionamento-sys-app",
  "version": "1.0.0-SNAPSHOT",
  "environment": "LOCAL",
  "errorType": "APIKIT:BAD_REQUEST",
  "statusCode": 400,
  "errorCode": "FAM-RELACIONAMENTO-SYS-APP-400",
  "durationMs": 125
}
```

Payloads completos de negocio nao fazem parte do logging operacional padrao.

---

## Correlation ID

O `correlationId` nativo do Mule e utilizado para rastreabilidade.

O mesmo identificador e utilizado:

```text
Request
   |
   v
API_REQUEST
   |
   v
Processamento
   |
   +--> API_RESPONSE
   |
   `--> API_ERROR
```

A aplicacao tambem devolve:

```http
x-correlation-id
```

no header das respostas HTTP, tanto em sucesso quanto em erro.

Nos HTTP Request Configurations preparados para comunicacao com a FAM esta configurado:

```text
sendCorrelationId="ALWAYS"
```

para propagacao do identificador quando a integracao real for ativada.

---

## Medicao de Duracao

O primeiro componente apos o HTTP Listener registra:

```text
inicioRequisicaoMs
```

O valor e utilizado nos logs de resposta e erro para calcular:

```text
durationMs
```

A medicao representa o tempo de processamento da requisicao dentro da aplicacao Mule a partir do primeiro ponto controlavel apos o Listener.

---

## Tratamento de Erros

O tratamento e centralizado em:

```text
fam-relacionamento-sys-app-error-handler
```

Os resource flows nao possuem Error Handler proprio enquanto nao existir necessidade de comportamento especifico por operacao.

Mapeamentos principais:

| Error Type | HTTP Status |
|---|---:|
| `APIKIT:BAD_REQUEST` | 400 |
| `APIKIT:NOT_FOUND` | 404 |
| `APIKIT:METHOD_NOT_ALLOWED` | 405 |
| `APIKIT:NOT_ACCEPTABLE` | 406 |
| `APIKIT:UNSUPPORTED_MEDIA_TYPE` | 415 |
| `APIKIT:NOT_IMPLEMENTED` | 501 |
| `HTTP:CONNECTIVITY` | 502 |
| `HTTP:TIMEOUT` | 504 |
| `ANY` | 500 |

O codigo de erro segue o padrao:

```text
{ERROR_CODE_PREFIX}-{HTTP_STATUS}
```

Nesta aplicacao:

```text
FAM-RELACIONAMENTO-SYS-APP-400
FAM-RELACIONAMENTO-SYS-APP-404
FAM-RELACIONAMENTO-SYS-APP-500
FAM-RELACIONAMENTO-SYS-APP-502
FAM-RELACIONAMENTO-SYS-APP-504
```

O prefixo e configurado em:

```yaml
error:
  codePrefix: "FAM-RELACIONAMENTO-SYS-APP"
```

---

## Resposta Padrao de Erro

Estrutura:

```json
{
  "codigo": "FAM-RELACIONAMENTO-SYS-APP-400",
  "mensagem": "Requisicao invalida.",
  "correlationId": "5e9a8fc4-5a53-4c38-9a5d-dce9c014fb80"
}
```

Quando existirem detalhes adicionais:

```json
{
  "codigo": "FAM-RELACIONAMENTO-SYS-APP-400",
  "mensagem": "Requisicao invalida.",
  "detalhes": [
    "Detalhe do erro"
  ],
  "correlationId": "5e9a8fc4-5a53-4c38-9a5d-dce9c014fb80"
}
```

---

## Properties

As propriedades comuns ficam em:

```text
src/main/resources/properties/config.yaml
```

Propriedades especificas por ambiente:

```text
config-local.yaml
config-dev.yaml
config-hml.yaml
config-prod.yaml
```

Propriedades seguras:

```text
config-secure-local.yaml
config-secure-dev.yaml
config-secure-hml.yaml
config-secure-prod.yaml
```

A aplicacao utiliza:

```text
mule.env
```

para selecionar o arquivo de ambiente.

Valor padrao local:

```text
mule.env=local
```

---

## Ambientes

Ambientes previstos:

| Profile | Ambiente |
|---|---|
| `local` | LOCAL |
| `dev` | DEV |
| `hml` | HML |
| `prod` | PROD |

Os profiles Maven `dev`, `hml` e `prod` possuem configuracao preparada para deployment no CloudHub 2.0.

Targets atuais:

```text
DEV  -> ps-fam-nonprod
HML  -> ps-fam-nonprod
PROD -> ps-fam-prod
```

System APIs permanecem configuradas por padrao sem geracao automatica de URL publica:

```text
generateDefaultPublicUrl=false
```

---

## Integracao com Backends FAM

A configuracao global ja possui HTTP Request Configurations para:

```text
Autenticacao FAM
Workflow FAM
```

Identificadores:

```text
autenticacao-fam_http-request
workflow-fam_http-request
```

Host e paths sao definidos pelos arquivos de properties de cada ambiente.

Exemplo conceitual:

```text
System API
    |
    v
Autenticar Parceiro FAM
    |
    v
Backend de Autenticacao
    |
    v
Token
    |
    v
Backend Workflow FAM
```

No estado atual, os componentes de autenticacao e HTTP Request dos resource flows permanecem desabilitados e as respostas sao fornecidas pelos DWLs locais.

Quando a conectividade estiver disponivel, os mocks poderao ser substituidos pela resposta real sem alterar a responsabilidade dos componentes de preparacao de resposta.

---

## APIKit Console

O projeto possui APIKit Console configurado em:

```text
/api/console/*
```

No ambiente local, utilizando a porta padrao:

```text
http://localhost:8081/api/console/
```

---

## Execucao Local

Profile Maven padrao:

```text
local
```

Configuracao:

```text
mule.env=local
```

Listener local:

```text
Host: 0.0.0.0
Port: 8081
Path: /*
```

Exemplo:

```text
http://localhost:8081/candidatos/processos-seletivos/cursos
```

Para testes manuais, pode ser utilizado Postman ou APIKit Console.

Recomenda-se informar um:

```http
x-correlation-id: 5e9a8fc4-5a53-4c38-9a5d-dce9c014fb80
```

para facilitar a rastreabilidade da chamada nos logs.

---

## Build Maven

Build local:

```bash
mvn clean package -Plocal
```

Profiles disponiveis:

```text
local
dev
hml
prod
```

---

## CloudHub 2.0

O Parent POM local possui configuracao preparada para deployment no CloudHub 2.0 utilizando Mule Maven Plugin.

Exemplo conceitual para DEV:

```bash
mvn clean deploy \
  -DmuleDeploy \
  -Pdev \
  -Dsecure.key=<CHAVE>
```

A autenticacao Maven/Anypoint utiliza Connected App por meio das variaveis de ambiente:

```text
ANYPOINT_CLIENT_ID
ANYPOINT_CLIENT_SECRET
```

O nome de runtime segue:

```text
${project.artifactId}-${app.suffix}
```

Exemplos:

```text
fam-relacionamento-sys-app-dev
fam-relacionamento-sys-app-hml
fam-relacionamento-sys-app-prod
```

---

## API Manager

O `global.xml` possui estrutura preparada para API Autodiscovery.

O Autodiscovery deve ser habilitado somente quando existir uma API Instance correspondente no API Manager e o respectivo `api.id` estiver configurado para o ambiente.

A configuracao permanece desabilitada no estado atual da aplicacao.

---

## MUnit

O projeto possui dependencias e plugin MUnit configurados no Maven.

Estrutura:

```text
src/test/munit/
```

Atualmente nao existem testes MUnit implementados.

Nao existe gate minimo de cobertura configurado nesta fase.

---

## Baseline Tecnologica

```text
Mule Runtime                 4.9.24 LTS
Java                         17
Mule Maven Plugin            4.10.4
HTTP Connector               1.12.2
APIKit                       1.13.4
Secure Configuration Props   1.3.2
MUnit                        3.7.6
Object Store Connector       1.3.4
```

As versoes comuns sao centralizadas no Parent POM local:

```text
build/parent/pom.xml
```

---

## Parent POM

O projeto utiliza:

```text
fam-mule-parent
```

distribuido localmente em:

```text
build/parent/pom.xml
```

O Parent centraliza:

- versoes da baseline;
- repositories Maven;
- Mule Maven Plugin;
- CloudHub 2.0 deployment;
- configuracao MUnit;
- resource filtering;
- configuracoes comuns de build.

No momento nao existe dependencia de um Parent POM externo no Exchange.

---

## Convencoes de Nomenclatura

A implementacao criada pela FAM utiliza nomenclaturas em **portugues do Brasil**, mantendo sem acentuacao os identificadores presentes no codigo-fonte.

### Flows, subflows e arquivos funcionais

Utilizar PT-BR e `kebab-case`.

Exemplos:

```text
processo-seletivo-flow.xml

autenticar-parceiro-fam-subflow
registrar-log-requisicao-subflow
registrar-log-resposta-subflow
registrar-log-erro-subflow
```

Flows gerados pelo APIKit devem manter a nomenclatura criada pelo framework.

### DataWeave

Arquivos `.dwl` utilizam PT-BR e `kebab-case`.

Exemplos:

```text
preparar-resposta-cursos.dwl
preparar-resposta-turnos.dwl
preparar-resposta-padrao-erro.dwl
```

### Variaveis internas

Variaveis criadas pela FAM utilizam PT-BR e `camelCase`.

Exemplos:

```text
inicioRequisicaoMs
codigoErro
mensagemErro
detalhesErro
mensagemLogRequisicao
mensagemLogResposta
mensagemLogErro
```

Nomes convencionados pelo APIKit permanecem conforme o framework:

```text
httpStatus
outboundHeaders
```

### Configuracoes globais

Para objetos tecnicos globais pode ser utilizado:

```text
<nome-funcional>_<tipo-do-componente>
```

O hifen separa palavras dentro da identidade funcional e `_` diferencia visualmente o tipo tecnico do componente.

Exemplos:

```text
api-kit_config
api-http-listener_config
secure-properties_config

autenticacao-fam_http-request
workflow-fam_http-request

autenticacao-parceiro_object-store
autenticacao-parceiro_caching-strategy
```

### Contratos e payloads

Propriedades JSON devem respeitar o contrato da API ou do backend correspondente.

Exemplos tecnicos consolidados permanecem em ingles:

```text
correlationId
statusCode
durationMs
errorCode
errorType
```

---

## Principios Arquiteturais

Esta System API deve seguir os seguintes principios:

1. permanecer proxima ao contrato do backend FAM;
2. nao implementar modelo canonico pertencente a Process API;
3. nao realizar composicoes que pertencam a camada Process;
4. nao criar camadas ou subflows apenas para representar visualmente API-led;
5. extrair logica reutilizavel apenas quando houver beneficio real de reuso ou legibilidade;
6. manter DataWeave relevante fora dos XMLs sempre que apropriado;
7. utilizar contratos fortemente tipados;
8. preservar `correlationId` para rastreabilidade;
9. manter logging tecnico independente de payloads de negocio por padrao;
10. centralizar erros tecnicos comuns no Error Handler global.

---

## Proximos Passos

Para a fase atual do projeto, esta System API sera utilizada como downstream da Process API:

```text
fam-candidato-prc-app
        |
        v
fam-relacionamento-sys-app
        |
        v
Mock FAM
```

A integracao real com os backends FAM sera ativada posteriormente, apos disponibilidade e validacao da conectividade entre CloudHub 2.0 e a infraestrutura da instituicao.

Nesse momento deverao ser validados:

- conectividade;
- DNS;
- TLS;
- autenticacao;
- token;
- cache;
- timeouts;
- contratos reais de request e response;
- tratamento dos status HTTP do backend.

---

## Resumo

```text
Aplicacao       : fam-relacionamento-sys-app
Camada          : System API
Contrato        : fam-relacionamento-sys-api
Runtime         : Mule 4.9.24 LTS
Java            : 17
Deployment      : CloudHub 2.0
Arquitetura     : API-led Connectivity
Estado Backend  : Mock
Logging         : Estruturado
Error Handling  : Centralizado
Correlation ID  : Habilitado
```