{print}   = require 'util'
{spawn}   = require 'child_process'
uglify    = require 'uglify-js'
fs        = require 'fs'
path      = require 'path'

compress = ->
  file = 'assets.js'
  out = "#{path.basename(file, ".js")}.min.js"
  try
    code = fs.readFileSync(file).toString()
  catch e
    return false
  ast = uglify.parser.parse code
  ast = uglify.uglify.ast_mangle ast
  ast = uglify.uglify.ast_squeeze ast
  fs.writeFileSync out, uglify.uglify.gen_code ast
  print "Complete compressing #{file} => #{out} \n\n"

task 'compress', 'Compress assets.js => assets.min.js', ->
  compress()
  
task 'build', 'Build from ./', ->
  coffee = spawn 'coffee', ['-c', '-o', '.', '.']
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()
  coffee.on 'exit', (code) ->
    compress() if code is 0

task 'watch', 'Watch ./ for changes', ->
  coffee = spawn 'coffee', ['-w', '-c', '-o', '.', '.']
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()
