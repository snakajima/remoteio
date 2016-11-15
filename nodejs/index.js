const fs = require('fs');
const express = require('express');
const app = express();
const path = require('path');

const serverPort = 8888;
var server = require('http').createServer(app);
server.listen(serverPort, function(){
	console.log('listening on *:' + serverPort);
});
app.get('/', function(req, res){
	res.sendFile('index.html', { root: path.join(__dirname, './html') });
});
app.get('/html/:filename', function(req, res){
	res.sendFile(req.params.filename, { root: path.join(__dirname, './html') });
});
app.get('/css/:filename', function(req, res){
	res.sendFile(req.params.filename, { root: path.join(__dirname, './css') });
});
app.get('/js/:filename', function(req, res){
	res.sendFile(req.params.filename, { root: path.join(__dirname, './js') });
});

const io = require('socket.io')(server);
const rooms = require('./rooms');
rooms(io)
