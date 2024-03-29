package org.sample.socket.server;

import java.io.IOException;
import java.util.HashMap;
import java.util.Set;
import java.util.concurrent.CopyOnWriteArraySet;

import javax.websocket.EncodeException;
import javax.websocket.OnClose;
import javax.websocket.OnError;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.PathParam;
import javax.websocket.server.ServerEndpoint;

import org.sample.socket.message.Message;
import org.sample.socket.message.MessageDecoder;
import org.sample.socket.message.MessageEncoder;

@ServerEndpoint(value = "/ws/{username}", decoders = MessageDecoder.class, encoders = MessageEncoder.class)
public class WebSocketServer {

	private Session session;
	private static Set<WebSocketServer> wsEndpoints = new CopyOnWriteArraySet<>();
	private static HashMap<String, String> users = new HashMap<>();
	
	@OnOpen
	public void onOpen(Session session, @PathParam("username") String username) throws IOException, EncodeException {
		System.out.println("open");
		this.session = session;
		wsEndpoints.add(this);
        users.put(session.getId(), username);
 
        Message message = new Message();
        message.setFrom(username);
        message.setContent("Connected!");
        broadcast(message);
	}

	@OnMessage
	public void onMessage(Session session, Message message) throws IOException, EncodeException {
		message.setFrom(users.get(session.getId()));
		if(message.getTo() != null && !"".equals(message.getTo())) {
			sendTarget(message);
		}else {
			broadcast(message);	
		}
	}

	@OnClose
	public void onClose(Session session) throws IOException, EncodeException {
		System.out.println("close");
		wsEndpoints.remove(this);
        Message message = new Message();
        message.setFrom(users.get(session.getId()));
        message.setContent("Disconnected!");
        users.remove(session.getId());
        broadcast(message);
	}

	@OnError
	public void onError(Session session, Throwable throwable) {
		// Do error handling here
	}
	
	private static void sendTarget(Message message) throws IOException, EncodeException {
		wsEndpoints.forEach(endpoint -> {
            synchronized (endpoint) {
                try {
                	String userId = endpoint.users.get((endpoint.session.getId()));
                	if(userId.equals(message.getTo())) {
                		endpoint.session.getBasicRemote().sendObject(message);
                	}
                } catch (IOException | EncodeException e) {
                    e.printStackTrace();
                }
            }
        });
	}
	
	private static void broadcast(Message message)  throws IOException, EncodeException {
		wsEndpoints.forEach(endpoint -> {
            synchronized (endpoint) {
            	try {
					endpoint.session.getBasicRemote().sendObject(message);
				} catch (IOException e) {
					e.printStackTrace();
				} catch (EncodeException e) {
					e.printStackTrace();
				}
            }
        });
	}
	
}
