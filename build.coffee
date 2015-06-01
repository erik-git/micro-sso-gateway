require 'shelljs/global'

rm '-rf', 'lib'
mkdir '-p', 'lib'

cp '-r', 'src/public/*', 'lib/public' if test '-e', 'src/public'
cp '.env', 'lib'

exec 'coffee --watch -o lib/ -c src/', async: true
exec 'nodemon ./lib/server.js', async: true
