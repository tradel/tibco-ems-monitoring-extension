package com.singularity.ee.agent.systemagent.monitors.common;

import javax.jms.Message;
import javax.jms.Queue;
import javax.jms.QueueConnection;
import javax.jms.JMSException;
import javax.jms.QueueSession;
import javax.jms.TextMessage;

import com.tibco.tibjms.Tibjms;
import com.tibco.tibjms.TibjmsConnectionFactory;
import com.tibco.tibjms.TibjmsQueueConnectionFactory;

public class MessageTester {
	

	public QueueConnection createConnection() {
		
		TibjmsQueueConnectionFactory factory = new TibjmsQueueConnectionFactory("tcp://hughsmac:7222", "Tester1");
		
		try {
			return factory.createQueueConnection("admin","admin");
			
		} catch (JMSException e) {
			
			e.printStackTrace();
			return null;
		}
		
	}
	
	public void createMessages() {
		
		QueueConnection conn = createConnection();
		if (conn != null)
		{
			
			System.out.println(conn.toString());
			try {
				printLines(conn.getMetaData().getJMSProviderName());
				printLines(conn.getClass().getName());
				QueueSession session = conn.createQueueSession(false, Tibjms.NO_ACKNOWLEDGE);
				Queue que1 = new com.tibco.tibjms.TibjmsQueue("DEMO_QUEUE_04");

				while(true){
					
					TextMessage message = session.createTextMessage();
					String mesg = "Demo Message One" + new java.util.Date().toString();
					message.setText(mesg);
					session.createSender(que1).send(message);
					printLines(mesg);
					
					try {
						Thread.sleep(10000);
					} catch (InterruptedException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
	
				}
				
				
				
				
				
					
			} catch (JMSException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			

		}

	}
	
	
	
	public void printLines(String value) {
		
		System.out.println(value);
		
	}
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		new MessageTester().createMessages();

	}

}
