package org.sample.socket.client;

import java.net.URI;
import java.net.URISyntaxException;

import org.sample.socket.message.Message;

public class ClientInterface {

	private String websocketUri = "ws://localhost:8080/ws/";
	
	public ClientInterface() {
		try {
            WebSocketClient clientEndPoint = new WebSocketClient(new URI(websocketUri+"test"));

            Message message = new Message();
            message.setTo("test");
            message.setContent("test_message");
            clientEndPoint.sendMessage(message);

        } catch (URISyntaxException ex) {
            System.err.println("URISyntaxException exception: " + ex.getMessage());
        }
	}
	
}
