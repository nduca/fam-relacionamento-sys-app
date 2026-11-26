%dw 2.0
output multipart/form-data
---
{
	parts: {
		userIdentity: {
			content: p("fam.token.parameters.userIdentity")
		},
		passwordIdentity: {
			content: p("fam.token.parameters.passwordIdentity")
		}
	}
}