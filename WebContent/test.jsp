<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>

<input type="text" id="username"  />
<button type="button" onclick="connect();">connect</button>
<div>
to user : <input type="text" id="to"  />  msg: <input type="text" id="msg" value="test11"  />
<button type="button" onclick="send();">send</button>
</div>

<div id="log" style="height: 500px;overflow-y: auto;"></div><button type="button" onclick="clearBtn();">clear</button>

</body>
<script>
function initNotification(){
	Notification.requestPermission(function (status) {
	    if (Notification.permission !== status) {
	      Notification.permission = status;
	    }
	});
};initNotification();
function callNotification(theBody,theTitle) {
	  var options = {
	      body: theBody,
	      icon: 'http://localhost:8080/images/ezgif-2-2de21bd25764.gif'
	  }
	  var n = new Notification(theTitle,options);
};
callNotification('title', '환영합니다');

var ws;
function connect() {
	if(ws != null && ws.readyState == 1){
		ws.close();
	}
	var username = document.getElementById("username").value;
    ws = new WebSocket("ws://localhost:8080/chat/"+ username);
    ws.onmessage = function(event) {
        var message = JSON.parse(event.data);
        var log = document.getElementById("log");
        log.innerHTML += message.from + " : " + message.content + "<br/>";
    };
};

function send() {
	var to = document.getElementById("to").value;
	var content = document.getElementById("msg").value;
    var json = JSON.stringify({
        "content":content,
        "to":to
    });
    ws.send(json);
};
function clearBtn(){
	var log = document.getElementById("log");
	log.innerHTML = '';
}
</script>

</html>