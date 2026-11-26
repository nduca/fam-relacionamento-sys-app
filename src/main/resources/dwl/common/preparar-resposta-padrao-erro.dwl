%dw 2.0
output application/json
var detalhes = vars.detalhesErro default []
---
{
	codigo: vars.codigoErro default (p("error.codePrefix") ++ "-500"),
	mensagem: vars.mensagemErro default "Erro interno.",
	(detalhes: detalhes) if (!isEmpty(detalhes)),
	correlationId: correlationId
}