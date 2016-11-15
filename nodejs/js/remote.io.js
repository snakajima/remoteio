var guid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    var r = Math.random()*16|0, v = c == 'x' ? r : (r&0x3|0x8);
    return v.toString(16);
});
var verbs = ["Walk", "Run", "Stop"];
var room = (function() {
    var _room = localStorage.getItem("room")
    return (_room==undefined) ? "Lobby" : _room;
})();

var socket = io({});
socket.on('connect', function() {
    console.log("connect", guid, room);
    socket.emit('/room/join', {name: room});
});
socket.on('/room/join/success', function(data) {
    console.log("/room/join/success");
});
socket.on('/room/message', function(data) {
    console.log("/room/message", data);
    switch(data.cmd) {
    case 'scan':
        socket.emit('/room/message', {cmd:"advertise", guid:guid, verbs:verbs});
        break;
    case 'focus':
        if (data.guid == guid) {
            document.getElementById('body').className = "focus_" + data.focus
        }
        break;
    case 'switch':
        if (data.guid == guid) {
            localStorage.setItem("room", data.room);
            socket.emit('/room/join', {name: data.room});
        }
        break;
    case 'custom':
        document.getElementById('verb').innerText = data.verb;
        break;
    }
});
