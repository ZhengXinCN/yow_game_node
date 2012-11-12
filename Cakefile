fs            = require 'fs'
{print}       = require 'util'
which         = require('which')
{spawn, exec} = require 'child_process'

# ANSI Terminal Colors
bold  = '\x1B[0;1m'
red   = '\x1B[0;31m'
green = '\x1B[0;32m'
reset = '\x1B[0m'

pkg = JSON.parse fs.readFileSync('./package.json')
testCmd = pkg.scripts.test
startCmd = pkg.scripts.start
  

log = (message, color, explanation) ->
  console.log color + message + reset + ' ' + (explanation or '')

# Compiles app.coffee and src directory to the app directory
build = (callback) ->
  options = [ '-c', '-b', '-o', 'app', 'src']
  cmd = 'node_modules/coffee-script/bin/coffee'  
  coffee = spawn cmd, options
  coffee.stdout.pipe process.stdout
  coffee.stderr.pipe process.stderr
  coffee.on 'exit', (status) -> callback?() if status is 0

# mocha test
test = (callback) ->
  options = [
    '--compilers'
    'coffee:coffee-script'
    '--colors'
    '--growl'
    '--watch'
    '--globals'
    'css,js,img'
  ]
  try
    cmd = 'node_modules/.bin/mocha'
    spec = spawn cmd, options
    spec.stdout.pipe process.stdout 
    spec.stderr.pipe process.stderr
    spec.on 'exit', (status) -> callback?() if status is 0
  catch err
    log err.message, red
    log 'Mocha is not installed - try npm install mocha -g', red

task 'docs', 'Generate annotated source code with Docco', ->
  fs.readdir 'src', (err, contents) ->
    files = ("src/#{file}" for file in contents when /\.coffee$/.test file)
    try
      cmd = which.sync 'docco' 
      docco = spawn cmd, files
      docco.stdout.pipe process.stdout
      docco.stderr.pipe process.stderr
      docco.on 'exit', (status) -> callback?() if status is 0
    catch err
      log err.message, red
      log 'Docco is not installed - try npm install docco -g', red


task 'build', ->
  build -> log ":)", green

task 'spec', 'Run Mocha tests', ->
  build -> test -> log ":)", green

task 'test', 'Run Mocha tests', ->
  build -> test -> log ":)", green

task 'dev', 'start dev env', ->
  # watch_coffee
  options = ['-c', '-b', '-w', '-o', 'app', 'src']
  cmd = 'node_modules/./bin/coffee'  
  coffee = spawn cmd, options
  coffee.stdout.pipe process.stdout
  coffee.stderr.pipe process.stderr
  log 'Watching coffee files', green
  # watch_js
  supervisor = spawn 'node', ['./node_modules/.bin/node-supervisor','-w','app,views,data,assets/js', '-e', 'js|jade|json|coffee','server']
  supervisor.stdout.pipe process.stdout
  supervisor.stderr.pipe process.stderr
  log 'Watching js files and running server', green

  