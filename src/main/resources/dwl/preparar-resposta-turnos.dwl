%dw 2.0
output application/json
---
{
	"statusCode": 200,
	"message": "Consulta realizada com sucesso.",
	"result": [{
		"idAreaInteresse": 100,
		"codTurno": "N",
		"nome": "Noturno",
		"codTipoHabilitacao": "BACH",
		"idHabilitacaoFilial": 500
	}]
}