%dw 2.0
output application/json
---
{
	event: 'API_ERROR',
	correlationId: correlationId,
	application: p('application.name'),
	version: p('application.version'),
	environment: p('environment.name'),
	errorType: ((error.errorType.namespace default '') ++ ':' ++ (error.errorType.identifier default '')),
	statusCode: (vars.httpStatus default 500) as Number,
	errorCode: vars.codigoErro default (p("error.codePrefix") ++ "-500"),
	durationMs: if ( vars.inicioRequisicaoMs != null ) (now() as Number {unit: "milliseconds"}) - (vars.inicioRequisicaoMs as Number) else null
}