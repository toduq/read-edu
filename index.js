var Mecab, PORT, app, body_parser, express, fs, helmet, hiraganize, https, mecab, options;

PORT = process.env['NODE_PORT'] || 3000;

Mecab = require('mecab-async');

if (process.env['NODE_DICDIR']) {
  Mecab.command = "mecab -d " + process.env['NODE_DICDIR'];
  console.log("mecat command : " + Mecab.command);
}

mecab = new Mecab();

express = require('express');

body_parser = require('body-parser');

helmet = require('helmet');

app = express();

app.use(body_parser.json());

app.use(body_parser.urlencoded({
  extended: true
}));

app.use(helmet());

app.use(express["static"](__dirname + '/public'));

app.post('/convert', function(req, res) {
  var ref, text;
  text = req.body.text;
  if (!((0 <= (ref = text.length) && ref <= 10000))) {
    return res.send("invalid length");
  }
  console.log("text is " + text);
  return mecab.parse(text, function(err, result) {
    if (err) {
      throw err;
    }
    result = result.map(function(val) {
      var org, yomi;
      if (val[0] === 'EOS') {
        return '';
      }
      org = val[0];
      yomi = hiraganize(val[val.length - 2]);
      if (hiraganize(org) === yomi || yomi === '*') {
        return org;
      } else {
        return [org, yomi];
      }
    });
    return res.send(result);
  });
});

if (process.env['NODE_CERTDIR']) {
  fs = require('fs');
  options = {
    key: fs.readFileSync(process.env['NODE_CERTDIR'] + 'privkey.pem'),
    cert: fs.readFileSync(process.env['NODE_CERTDIR'] + 'fullchain.pem'),
    ca: fs.readFileSync(process.env['NODE_CERTDIR'] + 'chain.pem')
  };
  https = require('https');
  https.createServer(options, app).listen(443);
  console.log('HTTPS enabled');
}

app.listen(PORT);

console.log("started on " + PORT);

console.log("__dirname is " + __dirname);

hiraganize = function(word) {
  return word.replace(/[\u30a1-\u30f6]/g, function(match) {
    return String.fromCharCode(match.charCodeAt(0) - 0x60);
  });
};
