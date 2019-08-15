package org.sample.socket.client;

import java.net.URI;

import javax.websocket.ClientEndpoint;
import javax.websocket.CloseReason;
import javax.websocket.ContainerProvider;
import javax.websocket.OnClose;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.WebSocketContainer;

import org.sample.socket.message.Message;
import org.sample.socket.message.MessageDecoder;
import org.sample.socket.message.MessageEncoder;

@ClientEndpoint(decoders = MessageDecoder.class, encoders = MessageEncoder.class)
public class WebSocketClient {
	Session userSession = null;

	public WebSocketClient(URI endpointURI) {
		try {
			WebSocketContainer container = ContainerProvider.getWebSocketContainer();
			container.setDefaultMaxSessionIdleTimeout(3000);
			container.connectToServer(this, endpointURI);
			System.out.println(container.getDefaultMaxSessionIdleTimeout()); 
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
	}

	@OnOpen
	public void onOpen(Session userSession) {
		System.out.println("opening websocket");
		this.userSession = userSession;
	}

	@OnClose
	public void onClose(Session userSession, CloseReason reason) {
		System.out.println("closing websocket : " + reason);
		this.userSession = null;
	}

	@OnMessage
	public void onMessage(String message) {
		System.out.println("msg :" + message);
	}

	public void sendMessage(Message message) {
		this.userSession.getAsyncRemote().sendObject(message);
	}

}
