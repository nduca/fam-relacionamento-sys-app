%dw 2.0
output application/json
---
{
	"statusCode": 200,
	"message": "Consulta realizada com sucesso.",
	"result": [{
		"id": 123,
		"codTipoHabilitacao": "BACH",
		"tipoHabilitacao": "Bacharelado",
		"cursoTipo": "GRADUACAO",
		"codCurso": "ADS",
		"visualizacao": "Analise e Desenvolvimento de Sistemas"
	}]
}