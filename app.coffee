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

app.get '/', (req, res) ->
  res.render 'index'

app.get '/download/:file', (req, res) ->
  res.download "./public/#{req.params.file}"

app.post "/upp", (req, res) ->
  console.log req.files
  if Array.isArray req.files.dataFile
    res.send [file.path for file in req.files.dataFile].sort( (l,r) ->
      return -1 if( l.name < r.name )
      return 1  if( l.name > r.name )
      return 0
    ).join()
  else
    res.send req.files.dataFile.path

basename = (str) ->
  (str.match /\/([^\.\/]*)\.*[^\/\.]*$/)[1]

app.post "/rnder", (req, res) ->
  console.log req.body
  {labelNameX, labelNameY, graphTitle} = req.body
  async.waterfall [
    (cb) ->
      env =
        X: labelNameX
        Y: labelNameY
        TITLE: graphTitle
        F: req.body.dataPath
        D: "pngcairo"
      exec "./c", {env:env}, (err, stdout, stderr) ->
        if err
          cb stderr
        else
          console.log stdout
          cb null, stdout.split(',')
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

http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")

