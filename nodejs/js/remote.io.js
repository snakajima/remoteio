(function() {
    var guid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
        var r = Math.random()*16|0, v = c == 'x' ? r : (r&0x3|0x8);
        return v.toString(16);
    });
    var verbs = [];
    var room = (function() {
        var _room = localStorage.getItem("room.1")
        return (_room==undefined) ? "Lobby" : _room;
    })();
    var remoteIO = {
      setVerbs:function(_verbs) { verbs = _verbs; },
      // to be overridden by the app
      onFocus:function(focus) {},
      onVerb:function(verb) {},
    };

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
                remoteIO.onFocus(data.focus);
            }
            break;
        case 'switch':
            if (data.guid == guid) {
                localStorage.setItem("room", data.room);
                socket.emit('/room/join', {name: data.room});
            }
            break;
        case 'custom':
            remoteIO.onVerb(data.verb);
            break;
        case 'scene':
            console.log("scene =", data.name, data.path);
            window.location.href = data.path;
            break;
        }
    });
    window.remoteIO = remoteIO;
})()

 
