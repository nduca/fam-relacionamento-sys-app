%dw 2.0
output application/json
---
{
	"statusCode": 200,
	"message": "Consulta realizada com sucesso.",
	"result": [{
		"idPs": 123,
		"nome": "Vestibular",
		"idFormaInscricao": 10,
		"nomeServico": "Processo Seletivo Online",
		"valorInscricao": 50,
		"existeTaxa": true,
		"ordem": 1
	}]
}