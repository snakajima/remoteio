const express = require('express');
const app = express();
const path = require('path');

const serverPort = 8888;
var server = require('http').createServer(app);

server.listen(serverPort, () => {
	console.log('listening on *:' + serverPort);
});

app.get('/', (req, res) => {
	res.sendFile('index.html', { root: path.join(__dirname, './html') });
});
app.get('/html/:filename', (req, res) => {
	res.sendFile(req.params.filename, { root: path.join(__dirname, './html') });
});
app.get('/css/:filename', (req, res) => {
	res.sendFile(req.params.filename, { root: path.join(__dirname, './css') });
});
app.get('/js/:filename', (req, res) => {
	res.sendFile(req.params.filename, { root: path.join(__dirname, './js') });
});

const io = require('socket.io')(server);
const chatrooms = require('./chatrooms');
chatrooms(io)
