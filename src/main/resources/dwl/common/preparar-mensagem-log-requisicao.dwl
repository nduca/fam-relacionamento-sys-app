%dw 2.0
output application/json
---
{
	event: 'API_REQUEST',
	correlationId: correlationId,
	application: p('application.name'),
	version: p('application.version'),
	environment: p('environment.name'),
	method: attributes.method default null,
	path: attributes.requestPath default null
}