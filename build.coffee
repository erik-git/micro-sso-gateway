require 'shelljs/global'

rm '-rf', 'lib'
mkdir '-p', 'lib'

cp '-r', 'src/views/*', 'lib/views' if test '-e', 'src/views'
cp '-r', 'src/public/*', 'lib/public' if test '-e', 'src/public'
cp '-r', 'src/css/*', 'lib/public' if test '-e', 'src/css'
cp '.env', 'lib'

exec 'coffee --watch -o lib/ -c src/', async: true

exec 'node-sass src/sass/style.scss lib/public/style.css cat src/sass/style.css ', async: true

exec 'nodemon ./lib/server.js', async: true
