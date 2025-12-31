return {
	{
		prefix = "errn",
		body = "if err != nil {\n\treturn ${1:err}\n}",
		desc = "Standard error return",
	},
	{
		prefix = "fnc",
		body = "func ${1:name}(${2}) ${3:error} {\n\t${0}\n}",
		desc = "Function definition",
	},
}
