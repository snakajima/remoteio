module.exports = function(io) {
  io.on('connection', function(socket) {
    console.log('connection');
    
    socket.on('/room/join', function(data) {
      console.log('/room/join', data.name);
      socket.join(data.name);
      io.sockets.adapter.sids[socket.id].ROOM = data.name;
      socket.emit('/room/join/success');
    });
    
    socket.on('/room/message', function(data) {
      var room = io.sockets.adapter.sids[socket.id].ROOM;
      console.log('message', room, data);
      io.sockets.in(room).emit('/room/message', data);
    });
  });
}
