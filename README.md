# remote.io

Remote.io is an apolication framework, which makes it possible to remote-control a set of web pages from an iOS device, such as switching pages, executing application specific commands, scrolling (panning) and zooming.  

## Architecture

It consists of a Chat Server (chatrooms.js), an iOS application (the remote controller) and a JavaScript library (remote.io.js). 

## Chat Server (chatrooms.js)

The Chat Server is a Node.js server built on top of the socket.io. It handles two messages, "/room/join" and "/room/message". 

Here is a prototypical implementation of Node.js server using chartoom.js.

```
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
```

#### /room/join

The client sends this message with a JSON object specifying the room name:
>{ name: "*room name*" }

#### /room/message

The client sends this message, which will be broadcasted to all the clients including the sender. The server simply relays the attached JSON object. 

The client sends this message with a JSON object specifying a command, and optional parameters specific to the command. 
>{ cmd: "*command*", *param1*:*value1*, *param2*:*value2*, ... }

## iOS Application (the remote controller)

The iOS Application is a universal remote controller, which connects to the Chat Server, presents the UI (specified by the *config.json* file and some data retrieved from other clients = web pages), and allows the operator to control web pages. 

It presents a set of pages using UINavigatoinController. At the root page, it presents the list of chat rooms (defined in the *config.json* file) to go to. 

When the user selects one of chat rooms, it navigates to the *scene controller* page, which presents the list of *scenes* (defined in the *config.json* file). 

When the user selects one of scenes, it navigates to the *controller* screen, but also broadcasts the "swich" command to all the clients in that chat room, along with the scene name and the relative URL (defined in the *config.json* file).
>{ cmd: "switch", 
>  scene:{ name:"*scene name*", path:"*relative URL" } }  

## remote.io.js 

Remote.io.js is a client-side JavaScript library, which processes message from the remote controller. Every web pages to be controlled by the remote controller must include this library along with socket.io.js. 

This library places a single object "remoteIO" in the global name space, and all the commication will be done via this object. 

#### remoteIO.setVerbs(commands)
Each web page should specify the context-specific commands (array of strings) by calling setVerbs method. Those commands will be presented in the *controller* screen of the remote controller. 

#### remoteIO.onFocus(focus)
Each web page should specify this callback function which will be called when the remote controller sets or remotes the focus on the page. 

#### remoteIO.onCommand(command)
Each web page should specify this callback function which will be called when the operator selects one of context-specific commands on the remote controller. 

```
<html>
  <head>
	<title>Home</title>
    <style>
        .focus_true {
            background:yellow;
        }
    </style>
	<script src="/socket.io/socket.io.js"></script>
	<script src="/js/remote.io.js"></script>
    <script>
        remoteIO.setVerbs(["Red", "Green", "Yello"]);
        remoteIO.onFocus = function(focus) {
            document.getElementById('body').className = "focus_" + focus;
        };
        remoteIO.onCommand = function(verb) {
            document.getElementById('verb').innerText = verb;
        };
    </script>
  </head>
  <body id='body'>
    <h1>Home</h1>
    <p>Last verb: <span id='verb'></span></p>
  </body>
</html>
```
