package com.singularity.ee.agent.systemagent.monitors.common;

import javax.management.Query;

import com.tibco.tibjms.admin.ConnectionInfo;
import com.tibco.tibjms.admin.ConsumerInfo;
import com.tibco.tibjms.admin.DetailedDestStat;
import com.tibco.tibjms.admin.QueueInfo;
import com.tibco.tibjms.admin.TibjmsAdmin;
import com.tibco.tibjms.admin.TibjmsAdminException;


public class TibcoEMS {

	String[] serverURL = {"tcp://hughsmac:7222"};

	String userid = "admin";
	String password = "admin";
	
	
	
	
	
	public void start() {
		try {
			TibjmsAdmin tibcoAdmin = new TibjmsAdmin(serverURL[0], userid, password);
			
			System.out.println("Connection Information");
			ConnectionInfo[] connectionInformation =  tibcoAdmin.getSystemConnections();
			for (int i = 0; i < connectionInformation.length; i++) {
				ConnectionInfo connectionInfo = connectionInformation[i];
				System.out.println("=====================================");
				String host = connectionInfo.getHost();
				System.out.println("Host\t"+ host);
				System.out.println("Connection Product Count\t" +  connectionInfo.getProducerCount());
				System.out.println("Address\t" + connectionInfo.getAddress());
				System.out.println("Client Type\t" + connectionInfo.getClientType());
				System.out.println("Session Count\t " + connectionInfo.getSessionCount());
			}
			
			
			ConsumerInfo[] consumers = 	 tibcoAdmin.getConsumersStatistics();
			System.out.println("Consumer Information");
			
			for (int i = 0; i < consumers.length; i++) {
				ConsumerInfo consumerInfo = consumers[i];
			    System.out.println("Durable Name\t\t" + consumerInfo.getDurableName());
			    System.out.println("===============================");
			    
			    
			    ConsumerInfo.Details details = consumerInfo.getDetails();
			    if (details != null) {
			    	System.out.println("ElapsedSinceLastSent " + consumerInfo.getDetails().getElapsedSinceLastSent());
			    	System.out.println("TotalAcknowledgedCount " + consumerInfo.getDetails().getTotalAcknowledgedCount());
			    	System.out.println("CurrentMsgCountSentByServer " + consumerInfo.getDetails().getCurrentMsgCountSentByServer());
			    }
			    System.out.println("DestinationName\t\t" + consumerInfo.getDestinationName());
			    System.out.println("Username\t\t" + consumerInfo.getUsername());
			    System.out.println("PendingMessageCount\t\t" + consumerInfo.getPendingMessageCount());
			    System.out.println("PendingMessageSize\t\t" + consumerInfo.getPendingMessageSize());
			    System.out.println("Selector\t\t" + consumerInfo.getSelector());
				System.out.println("ConnectionID\t" + consumerInfo.getConnectionID());
				System.out.println("");
			}
			
			System.out.println("");
			System.out.println("Queue Information");
			QueueInfo[] queueInformation = tibcoAdmin.getQueuesStatistics();
			for (int i = 0; i < queueInformation.length; i++) {
				QueueInfo queueInfo = queueInformation[i];
				System.out.println(queueInfo.getName());
				System.out.println("================================");
				System.out.println("Consumer Count\t\t\t" + queueInfo.getConsumerCount());
				System.out.println("Delivered Message Count\t\t" + queueInfo.getDeliveredMessageCount());
				System.out.println("Flow Control Max Bytes\t\t" + queueInfo.getFlowControlMaxBytes());
				System.out.println("Pending Message Count\t\t" + queueInfo.getPendingMessageCount());
				System.out.println("");
			}
			
			
			System.out.println("Closing Connection to Server");
			tibcoAdmin.close();
			
		
		} catch (TibjmsAdminException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
	}
	public static void main(String[] args) {
		new TibcoEMS().start();
		
	}
	
	
	

	
	
}
