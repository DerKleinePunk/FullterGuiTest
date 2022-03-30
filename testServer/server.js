'use strict';

import { createServer } from "http";
import WebSocket, { WebSocketServer } from 'ws';
import { Server as FileServer } from 'node-static';

const host = 'localhost';
const port = 8080;
const wsPath = "/messages";

const file = new FileServer('./pages/');
const fileResources = new FileServer('./resources/');

function parseCookies (request) {
    const list = [];
    var cookieHeader = request.headers?.cookie;
    
    if (!cookieHeader) return list;

    if (typeof cookieHeader !== 'string') {
        return list;
    }

    if(cookieHeader.slice(-1) !== ';') {
        cookieHeader += ';';
    }

    cookieHeader.split(`;`).forEach(function(cookie) {
        let [ name, ...rest] = cookie.split(`=`);
        name = name?.trim();
        if (!name) return;
        const value = rest.join(`=`).trim();
        if (!value) return;
        list[name] = decodeURIComponent(value);
    });

    return list;
}

const requestListener = async function (req, res) {
    console.log(req.url);
    console.log(req.method);
    console.log(req.headers?.cookie)

    if(req.url == '/pages' && req.method == 'GET') {
        req.url = 'index.html';
        req.addListener('end', () => file.serve(req, res)).resume();
        return;
    }

    if(req.url == '/api/session' && req.method == 'GET') {
        res.setHeader("Content-Type", "application/json");
        res.setHeader("Access-Control-Allow-Origin", "http://localhost:8000");
        res.setHeader("Access-Control-Allow-Credentials", "true");
        res.setHeader("Access-Control-Allow-Methods", "DELETE, POST, GET");
        
        const listCookies = parseCookies(req);
        if(!Array.isArray(listCookies)) {
            res.writeHead(404);
            res.end();
        } else if(listCookies['SessionId'] == '') {
            res.writeHead(404);
            res.end();
        } else if(Array.isArray(listCookies) && listCookies.length == 0) {
            res.writeHead(404);
            res.end();
        } else {
            res.writeHead(200);
            res.end(`{"userCtx": {"name": "admin" } }`);
        }
        
    } else if(req.url == '/api/session' && req.method == 'POST') {
        const buffers = [];

        for await (const chunk of req) {
            buffers.push(chunk);
        }
        
        const data = Buffer.concat(buffers).toString();
        console.log(data);
        res.setHeader("Content-Type", "application/json");
        res.setHeader("Access-Control-Allow-Origin", "http://localhost:8000");
        res.setHeader("Access-Control-Allow-Credentials", "true");
        res.setHeader("Access-Control-Allow-Methods", "DELETE, POST, GET");
        if(JSON.parse(data).name == 'admin'){
            res.setHeader("Set-Cookie", "SessionId=789;SameSite=Strict;Path=/;");
            res.writeHead(200);
        } else if(JSON.parse(data).name == 'Webpage'){
            res.setHeader("Set-Cookie", "SessionId=999;SameSite=Strict;Path=/;");
            res.writeHead(200);
        } else {
            res.writeHead(404);
        }
        res.end();
    } else if(req.url == '/api/session' && req.method == 'OPTIONS') {
        res.setHeader("Allow", "DELETE, POST, GET");
        res.setHeader("Access-Control-Allow-Origin", "http://localhost:8000");
        res.setHeader("Access-Control-Allow-Credentials", "true");
        res.setHeader("Access-Control-Allow-Methods", "DELETE, POST, GET");
        res.writeHead(204); // No Content
        res.end();
    } else if(req.url == '/api/session' && req.method == 'DELETE') {
        const listCookies = parseCookies(req);
        if(Array.isArray(listCookies)) {
            console.log(listCookies['SessionId']);
        } else {
            console.log("no Cookie");
        }
        res.setHeader("Access-Control-Allow-Origin", "http://localhost:8000");
        res.setHeader("Access-Control-Allow-Credentials", "true");
        res.setHeader("Access-Control-Allow-Methods", "DELETE, POST, GET");
        res.writeHead(200);
        res.end();
    } else if(req.url.substring(0, 11) == '/resources/') {
        //res.setHeader("Content-Type", "audio/mpeg");
        req.url = req.url.substring(11);
        console.log("try send file " + req.url);
        /*res.setHeader("Access-Control-Allow-Origin", "http://localhost:8000");
        res.setHeader("Access-Control-Allow-Credentials", "true");
        res.setHeader("Access-Control-Allow-Methods", "DELETE, POST, GET");*/
        req.addListener('end', () => fileResources.serve(req, res)).resume();
        return;
    } else {
        res.setHeader("Content-Type", "application/json");
        res.writeHead(200);
        res.end(`{"message": "This is a JSON response"}`);
    }
};

const server = createServer(requestListener);
server.listen(port, host, () => {
    console.log(`Server is running on http://${host}:${port}`);
});

console.log("Build Websocket Server");

/*
// We need the same instance of the session parser in express and
// WebSocket server.
//
const sessionParser = session({
    saveUninitialized: false,
    secret: '$eCuRiTy',
    resave: false
  });*/

//const wss = new WebSocketServer.Server({ port: port, path: wsPath })

//clientTracking: false das für als parameter das zu das der wss keine Clients kennt undefined
const wss = new WebSocketServer({ noServer: true })

server.on('upgrade', function (request, socket, head) {
    //console.log('Parsing session from request...');
    console.log('Upgrade Socket');

    wss.handleUpgrade(request, socket, head, function (ws) {
        wss.emit('connection', ws, request);
    });

    /*sessionParser(request, {}, () => {
      if (!request.session.userId) {
        socket.write('HTTP/1.1 401 Unauthorized\r\n\r\n');
        socket.destroy();
        return;
      }
  
      console.log('Session is parsed!');
  
      wss.handleUpgrade(request, socket, head, function (ws) {
        wss.emit('connection', ws, request);
      });
    });*/
  });

  
// Creating connection using websocket
wss.on("connection", ws => {
    console.log("new client connected");
    // sending message
    ws.on("message", function message(data, isBinary) {
        console.log(`Client has sent us: ${data}`);
        //Echo all
        wss.clients.forEach(function each(client) {
            if (client.readyState === WebSocket.OPEN) {
                console.log(` send to Client: ${data}`);
                client.send(data, { binary: isBinary });
            }
          });
    });
    // handling what to do when clients disconnects from server
    ws.on("close", () => {
        console.log("the client has disconnected");
    });
    // handling client connection error
    ws.onerror = function () {
        console.log("Some Error occurred")
    }
});