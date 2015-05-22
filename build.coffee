require 'shelljs/global'

rm '-rf', 'lib'
mkdir '-p', 'lib'

cp '-r', 'src/public/*', 'lib/public' if test '-e', 'src/public'
cp '.env', 'lib'

exec 'coffee --watch -o lib/ -c src/', async: true
isOpen = false
exec('nodemon ./lib/server.js', async: true)
.stdout.on 'data', (data)->
	if data.indexOf('on port') > -1 and not isOpen
		isOpen = true
		exec 'opener http://localhost:5001/', async: true
