BASEDIR=$(dirname $0)

node $BASEDIR/../node_modules/jison/lib/cli.js $BASEDIR/../src/n1ql.y $BASEDIR/../src/n1ql.l -o $BASEDIR/../lib/n1ql.gen.js