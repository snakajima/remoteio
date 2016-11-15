module.exports = function(io) {
  var _self = this;
  var rooms = {};
  
  console.log(rooms);
  
  function Room(_name) {
    this.name = _name;
  }
  
  io.on('connection', function(socket) {
    console.log('connection');
    
    socket.on('/room/join', function(data) {
      console.log('join', rooms, data.name, rooms[data.name]);
      if (rooms[data.name] == undefined) {
        rooms[data.name] = new Room(data.name);
        console.log('room created', rooms);
      }
      socket.join(data.name);
      io.sockets.adapter.sids[socket.id].ROOM = data.name;
      socket.emit('/room/join/success');
    });
    
    socket.on('/room/message', function(data) {
      var room = rooms[io.sockets.adapter.sids[socket.id].ROOM];
      console.log('message', room);
      io.sockets.emit('/room/message', data);
    });
  });
}
