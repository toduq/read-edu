PORT = process.env['NODE_PORT'] || 3000

# mecab
Mecab = require 'mecab-async'
if process.env['NODE_DICDIR']
	Mecab.command = "mecab -d #{process.env['NODE_DICDIR']}"
	console.log "mecat command : #{Mecab.command}"
mecab = new Mecab()

# express
express = require 'express'
body_parser = require 'body-parser'
app = express()
app.use body_parser.json()
app.use body_parser.urlencoded({extended: true})
app.use express.static(__dirname + '/public')

app.post '/convert', (req, res) ->
	text = req.body.text
	unless 0 <= text.length <= 10000
		return res.send("invalid length")
	console.log "text is #{text}"

	mecab.parse text, (err, result) ->
		throw err if(err)
		result = result.map (val) ->
			return '' if val[0] == 'EOS'
			org = val[0]
			yomi = hiraganize val[val.length-2]
			if hiraganize(org) == yomi || yomi == '*'
				org
			else
				[org, yomi]
		res.send result

# https
if process.env['NODE_CERTDIR']
	fs = require 'fs'
	options = {
		key:  fs.readFileSync process.env['NODE_CERTDIR'] + 'privkey.pem'
		cert: fs.readFileSync process.env['NODE_CERTDIR'] + 'cert.pem'
	};
	https = require 'https'
	https.createServer(options, app).listen 443
	console.log 'HTTPS enabled'

app.listen PORT
console.log "started on #{PORT}"
console.log "__dirname is #{__dirname}"

hiraganize = (word) ->
	word.replace /[\u30a1-\u30f6]/g, (match) ->
		String.fromCharCode match.charCodeAt(0) - 0x60