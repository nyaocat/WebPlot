express = require "express"
http    = require "http"
path    = require "path"
{exec}  = require "child_process"
fs      = require "fs"
app     = express()
async   = require 'async'
nodemailer    = require 'nodemailer'
require 'coffee-script'
querystring = require 'querystring'

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

mail = nodemailer.mail

app.post '/ankt', (req, res) ->
  console.log req.body
  mail
    from: 'webplot@sakura.ikulab.org'
    to: 'n@nyaocat.jp'
    subject: 'WebPlot アンケート'
    text: req.body.ankt
  res.send 'ok'

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

server = http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")

io = require('socket.io').listen(server)

io.sockets.on 'connection', (socket) ->
  socket.on 'rnder', (data) ->
    socket.emit 'rnders', "レンダリング中です……"
    data = querystring.parse data
    {labelNameX, labelNameY, graphTitle, graphType} = data
    unless (graphType is "c1") or (graphType is "c2") or (graphType is "l1")
      return setTimeout ->
        socket.emit 'rndere', "認識されないグラフタイプ指定です"
      , 1000
    async.waterfall [
      (cb) ->
        env =
          X: labelNameX
          Y: labelNameY
          TITLE: graphTitle
          F: data.dataPath
          D: "pngcairo"
        exec "./#{graphType}", {env:env}, (err, stdout, stderr) ->
          if err
            cb stderr
          else
            console.log stdout
            cb null, stdout.split(',')
      (files, cb) ->
        socket.emit 'rnders', "アニメーション生成中です……"
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
          socket.emit 'rndere', JSON.stringify(err)
        else
          socket.emit 'rnderf', ret
