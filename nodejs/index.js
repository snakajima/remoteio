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

const io = require('socket.io')(server);
const rooms = require('./rooms');
rooms(io)
