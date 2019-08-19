<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>chat test</title>
<link rel="stylesheet" type="text/css" href="/css/common.css" />
<style>
.container{margin:20px;border: 2px solid #ccc;}
.container ul.contents {overflow: hidden;height: 500px;}
.container ul li.chat_wrap{float: left;width:80%;background: #b2c7d9;overflow: hidden;}
.container ul li.chat_wrap #log{height: 430px;overflow: auto;}
.container ul li.chat_wrap #log ul{padding:12px;}
.container ul li.chat_wrap #log ul li{overflow: hidden;margin-bottom: 10px;}
.container ul li.chat_wrap #log ul li .user_msg_wrap{float: left;}
.container ul li.chat_wrap #log ul li div label{display:inline-block;}
.container ul li.chat_wrap #log ul li div label.username{margin-top:5px;margin-left: 5px;}
.container ul li.chat_wrap #log ul li div label.msg{background: #fff;border-radius:3px; padding: 5px;}
.container ul li.chat_wrap #log ul li div label.whisper{color: #aaf;}
.container ul li.chat_wrap #log ul li .user_msg_box{margin-top:5px;}

.container ul li.chat_wrap .msg_wrap{float: left;padding: 10px;background: #b2c7d9;width:calc(100% - 20px);}
.container ul li.chat_wrap .msg_wrap #to{width:80px;height: 50px;border: 1px solid #ddd; border-radius: 3px;}
.container ul li.chat_wrap .msg_wrap #msg{width:calc(100% - 140px);height: 50px;border: 1px solid #ddd; border-radius: 3px;}
.container ul li.chat_wrap .msg_wrap #send{width:50px;height: 50px;color:#888;background: #eee;border: 1px solid #ddd; border-radius:3px; }

.container ul li.user_wrap{float:left;border-left:2px solid #ccc;width:19%;height: 500px;}
.container ul li.user_wrap .profile{padding: 10px 20px;}

</style>
</head>
<body>
<div class="container">
	<ul class="contents">
		<li class="chat_wrap">
			<div id="log">
				<ul id="log_wrap">
					<li>
						<div class="title_line user_msg_wrap"><img src="/images/user.png"/></div>
						<div class="textbox user_msg_wrap">
							<div><label class="username">☆☆☆</label></div>
							<div class="user_msg_box"><img src="/images/msg.png"/><label class="msg">환영합니다.</label></div>
						</div>
					</li>
				</ul>
			</div>
			<div class="msg_wrap">
				<select id="to">
					<option value="">전체</option>
				</select>
				<textarea id="msg"></textarea>
				<button type="button" id="send" onclick="send();">전송</button>
			</div>
		</li>
		<li class="user_wrap">
			<ul></ul>
		</li>
	</ul>
</div>
<script src="https://code.jquery.com/jquery-3.4.1.min.js"></script>
<script>
var username = null;
while(true){
	username = prompt('아이디를 입력해주세요.');
	if(username != null && username != ''){
		connect();
		break;
	}
}
var ws;
function connect() {
	if(ws != null && ws.readyState == 1){
		ws.close();
	}
    ws = new WebSocket("ws://210.16.195.70:8080/chat/"+ username);
    ws.onmessage = function(event) {
        var message = JSON.parse(event.data);
        switch(message.content){
	        case 'Connected!':
	        	var users = message.users;
	        	var profileHtml = '';
	        	var optionsHtml = '<option value="">전체</option>';
	        	for(var i=0; i <users.length; i++){
	        		profileHtml += '<li class="profile" data-id="'+users[i]+'">'+users[i]+'</li>'
	        		if(username != users[i]){
	        			optionsHtml += '<option value="'+users[i]+'">'+users[i]+'</option>';	
	        		}
	        	}
	        	$('.user_wrap ul').html(profileHtml);
	        	$('#to').html(optionsHtml);	
	        	callNotification(message.from + '님이 입장하셨습니다.', '환영합니다', 'http://210.16.195.70:8080/images/ezgif-2-2de21bd25764.gif');
	        	break;
	        	
	        case 'Disconnected!':
	        	$('.profile[data-id="'+message.from+'"]').remove();
	        	$('#to option[value="'+message.from+'"]').remove();
	        	callNotification(message.from + '님이 퇴장하셨습니다.', '다음에 또 봐요', 'http://210.16.195.70:8080/images/ezgif-2-f89001447bb3.gif');
	        	break;
	        	
	        default:
	        	var whisper = (message.to != '' && message.to != null) ? 'whisper' : '';
	        	appendMsg(message.from, message.content, whisper);
	        	break;
        }
        $('#log').scrollTop($('#log_wrap').height()+100);
    };
};
function send() {
	if($.trim($('#msg').val()) == '') return;
    var json = JSON.stringify({
        "content":$('#msg').val(),
        "to":$('#to').val()
    });
    ws.send(json);
    whisper();
    $('#msg').val('');
};
function appendMsg(username, content, whisper){
	var text = ''; 
    text += '<li>'; 
    text += 	'<div class="title_line user_msg_wrap"><img src="/images/user.png"/></div>';
    text += 		'<div class="textbox user_msg_wrap">';
    text += 		'<div><label class="username">'+username+'</label></div>';
    text += 		'<div class="user_msg_box"><img src="/images/msg.png"/><label class="msg '+whisper+'">'+content+'</label></div>';
    text += 	'</div>';		
    text += '</li>';
    $('#log_wrap').append(text);	
};
function whisper(){
	if($('#to').val() != ''){
		appendMsg(username, $('#msg').val(), 'whisper');
		$('#log').scrollTop($('#log_wrap').height()+100);
	}
};
$('#msg').keydown(function(e){
	if(e.keyCode == 13){
		send();
	}
});
function initNotification(){
	Notification.requestPermission(function (status) {
	    if (Notification.permission !== status) {
	      Notification.permission = status;
	    }
	});
};initNotification();
function callNotification(theBody,theTitle, theIcon) {
	  var options = {
	      body: theBody,
	      icon: theIcon
	  }
	  var n = new Notification(theTitle,options);
};
</script>
</body>
</html>