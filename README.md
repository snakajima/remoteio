# remote.io

Remote.io is an apolication framework, which makes it possible to remote-control a set of web pages from an iOS device, such as switching pages and executing application specific commands.  

## Architecture

It consists of a Chat Server (chatrooms.js), an iOS application (the remote controller) and a JavaScript library (remote.io.js). 

## Chat Server (chatrooms.js)

The Chat Server is a Node.js server built on top of the socket.io. It handles two messages, "/room/join" and "/room/message". 

Here is a prototypical implementation of Node.js server using chartoom.js.

```
const express = require('express');
const app = express();
const path = require('path');

const serverPort = 8080;
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

#### remoteIO.onFocus(focus)
Each web page should specify this callback function which will be called when the remote controller sets or remotes the focus on the page. 
- *focus*: focus mode (Boolean)

#### remoteIO.onCommand(command)
Each web page may specify this callback function which will be called when the operator selects one of scene-specific commands on the remote controller. 
- *command*: scene-specific command (String)

#### remote.handlePan(state, pos, tx)
Each web page may specify this callback function to handle "Pan" messages from the remote controller.
- *state*: either "began", "changed", "ended" or "cancelled"
- *pos*: position ({ x:*x*, y:*y* })
- *tx*: translation ({ x:*x*, y:*y* })

#### remote.handlePinch(state, pos, tx)
Each web page may specify this callback function to handle "Pinch & Zoom" messages from the remote controller.
- *state*: either "began", "changed", "ended" or "cancelled"
- *pos*: position ({ x:*x*, y:*y* })
- *scale*: scale (Float)

#### remoteIO.onScene(scene)
By default, remote.io.js switches a different page when the operator selects a scene (to the URL specified in "path" paremeter). Each web page may override the default behavior by providing this callback function. The *scene* is the object associated with the selected scene, which has "name" and "path" (both strings) but also contain application specific parameters, such as "altenativePath". This is useful when the application wants to control sets of web pages at the same time (presented in different browsers or even different machines).  

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
## Config File (config.json)

The config file is an application specific JSON file, which speicifies a set of *chat rooms* (array of strings) and a set of scenes (array of scene objects).

Each scen object must have the *name* (string), the *path* (string) and *commands* (array of string), but may also have additional application-specific parameters.

```
{
    "rooms":[
        "Lobby", "Room 1", "Room 2", "Room 3"
    ],
    "scenes":[
        { "name":"Main", "path":"/",
          "commands":["Yellow", "Blue", "Green"],
          "pathB":"/html/indexB.html" },
        { "name":"Demo 1", "path":"/html/demo1.html",
          "commands":["Black", "White"],
          "pathB":"/html/demo1B.html" },
        { "name":"Demo 2", "path":"/html/demo2.html",
          "commands":["Car", "Bike", "Boat"],
          "pathB":"/html/demo2B.html" }
    ]
}
```
