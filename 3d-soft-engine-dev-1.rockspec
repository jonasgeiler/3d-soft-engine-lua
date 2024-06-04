rockspec_format = '3.0'
package = '3d-soft-engine'
version = 'dev-1'
source = {
	url = 'git+https://github.com/jonasgeiler/3d-soft-engine-lua',
}
description = {
	license = 'MIT',
}
dependencies = {
	'lua 5.1',
	'fenster 1.0.1',
	'dkjson 2.7',
}
build = {
	type = 'none',
}
test = {
	type = 'command',
	command = 'luajit main.lua',
}
