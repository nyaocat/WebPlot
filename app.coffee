express = require "express"
http    = require "http"
path    = require "path"
{exec}  = require "child_process"
fs      = require "fs"
app     = express()
async   = require 'async'
require 'coffee-script'

# all environments
app.set "port", process.env.PORT or 8000
app.set "views", __dirname + "/views"
app.set "view engine", "jade"
app.use express.favicon()
app.use express.logger("dev")
app.use express.bodyParser
  uploadDir : "/tmp"
app.use express.methodOverride()
app.use app.router
app.use express.static(path.join(__dirname, "public"))

# development only
app.use express.errorHandler()  if "development" is app.get("env")

app.get "/", (req, res) ->
  res.sendfile 'public/index.html'

app.get "/t", (req, res) ->
  res.redirect "https://docs.google.com/presentation/d/18WeBl7R9LaM91Fx9ouRyDb8jWGGhRsZMr09GTtEfMqM/edit?usp=sharing"


app.post "/upp", (req, res) ->
  console.log "uppp!"
  console.log req.files.dataFile
  if Array.isArray req.files.dataFile
    res.send [file.path for file in req.files.dataFile].join()
  else
    res.send req.files.dataFile.path

basename = (str) ->
  (str.match /\/([^\.\/]*)\.*[^\/\.]*$/)[1]

app.post "/rnder", (req, res) ->
  console.log req.body
  {labelNameX, labelNameY, graphTitle} = req.body
  async.waterfall [
    (cb) ->
      async.map req.body.dataPath.split(','), ((inpath, cb) ->
        outpath = "public/images/#{basename inpath}.png"
        exec "env X=#{labelNameX} Y=#{labelNameY} TITLE=#{graphTitle} F=#{inpath} ./c -dev pngcairo -o #{outpath}", (err, stdout, stderr) ->
          if err
            cb stderr
          else
            cb null, outpath
      ), cb
    (files, cb) ->
      async.parallel {
        thumb: (cb) ->
          exec "convert -loop 0 -delay 10 #{files.join(' ')} public/#{basename files[0]}.gif", (err, stdout, stderr) ->
            if err
              cb stderr
            else
              cb null, "#{basename files[0]}.gif",
        orig:  (cb) ->
          cb null, "anim.gif"
      }, cb
  ], (err, ret) ->
      if err?
        res.send {err: JSON.stringify err}
      else
        res.json ret

app.post "/rnderold", (req, res) ->
  console.log JSON.stringify(req.body)

  #exec "echo '#{JSON.stringify req.body}' | lua bbb.lua", (err, stdout, stderr) ->
  #  if err?
  #    console.log stdout
  #    console.error stderr
  #    return res.send 500
#
  #  console.log stdout

  b = req.body

  console.log "convert -loop 0 `env F=#{req.body.dataPath} TITLE=hoge lua 01.lua` public/anim.gif"
  exec "convert -loop 0 `env F=#{b.dataPath} TITLE=#{b.graphTitle} X=#{b.labelNameX} Y=#{b.labelNameY} lua 01.lua` public/anim.gif",(err, stdout, stderr) ->
    if err?
      console.log stdout
      console.error stderr
      return res.send 500
    res.json {
      thumb: "/anim.gif"
      orig: "/anim.gif"
    }


  #setTimeout ->
  #  res.json {
  #    thumb: "/bb.png"
  #    orig: "/dumy.png"
  #  }
  #, 1000


http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")

