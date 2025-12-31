return {
	{
		prefix = "pubf",
		body = "public function ${1:name}(${2:type} $${3:var}): ${4:void}\n{\n\t${0}\n}",
		desc = "Public function",
	},
	{
		prefix = "testt",
		body = "/** @test */\npublic function it_${1:does_something}(): void\n{\n\t${0}\n}",
		desc = "PHPUnit test method",
	},
	{
		prefix = "vd",
		body = "var_dump(${1});\ndie();",
		desc = "Quick debug dump and die",
	},
	{
		prefix = "newphp",
		body = "<?php \n\ndeclare(strict_types=1);\n\n",
		desc = "Start of a new file with strict typing",
	},
	{
		prefix = "ncl",
		body = "class ${1:name} {\n\n\tpublic function __construct(\n\t\t${0}\n\t)\n\t{}\n\n}",
		desc = "New Class",
	},
	{
		prefix = "prp",
		body = "private readonly ${1:type} $${0},",
		desc = "Private Property",
	},
	{
		prefix = "plp",
		body = "public readonly ${1:type} $${0},",
		desc = "Public Property",
	},
}
