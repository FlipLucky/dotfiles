return {
	{
		prefix = "stless",
		body = "class ${1:MyWidget} extends StatelessWidget {\n\tconst ${1:MyWidget}({super.key});\n\n\t@override\n\tWidget build(BuildContext context) {\n\t\treturn ${0:Container()};\n\t}\n}",
		desc = "Stateless Widget",
	},
	{
		prefix = "stful",
		body = "class ${1:MyWidget} extends StatefulWidget {\n\tconst ${1:MyWidget}({super.key});\n\n\t@override\n\tState<${1:MyWidget}> createState() => _${1:MyWidget}State();\n}\n\nclass _${1:MyWidget}State extends State<${1:MyWidget}> {\n\t@override\n\tWidget build(BuildContext context) {\n\t\treturn ${0:Container()};\n\t}\n}",
		desc = "Stateful Widget",
	},
}
