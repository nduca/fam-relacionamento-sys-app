%dw 2.0
output application/json
---
{
	"statusCode": 200,
	"message": "Consulta realizada com sucesso.",
	"result": [{
		"id": 10,
		"codigo": "POLO-SP-01",
		"nome": "Polo Sao Paulo",
		"uf": "SP",
		"estado": "Sao Paulo",
		"cidade": "Sao Paulo",
		"bairro": "Centro",
		"endereco": "Rua Exemplo",
		"numero": "100",
		"cep": "01000-000",
		"idPais": 1,
		"status": "ATIVO",
		"visualizacao": "Polo Sao Paulo - Centro"
	}]
}