%dw 2.0
output application/json
---
{
	event: 'API_RESPONSE',
	correlationId: correlationId,
	application: p('application.name'),
	version: p('application.version'),
	environment: p('environment.name'),
	statusCode: (vars.httpStatus default 200) as Number,
	durationMs: if ( vars.inicioRequisicaoMs != null ) (now() as Number {unit: "milliseconds"}) - (vars.inicioRequisicaoMs as Number) else null
}