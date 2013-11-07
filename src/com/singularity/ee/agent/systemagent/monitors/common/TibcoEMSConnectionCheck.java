package com.singularity.ee.agent.systemagent.monitors.common;

import java.util.HashMap;
import java.util.Map;

import javax.management.Query;

import com.tibco.tibjms.admin.ConnectionInfo;
import com.tibco.tibjms.admin.ConsumerInfo;
import com.tibco.tibjms.admin.DetailedDestStat;
import com.tibco.tibjms.admin.QueueInfo;
import com.tibco.tibjms.admin.TibjmsAdmin;
import com.tibco.tibjms.admin.TibjmsAdminException;


public class TibcoEMSConnectionCheck {

	String[] serverURL = {
			"tcp://tparhetibu027.nielsen.com:57223",
			"tcp://tparhetibu027.nielsen.com:57225",
			"tcp://tparhetibu034.nielsen.com:57222",
			"tcp://tparhetibu035.nielsen.com:57222"};

	String userid = "appdynamicpocuser";
	String password = "appdynamicpocpwd";
	
	Map<TibjmsAdmin, Boolean> connectionSuccessMap = new HashMap<TibjmsAdmin, Boolean>();
	
	
	TibjmsAdmin tibcoAdmin = null;
	
	public void execute() {

			for (int i = 0; i < serverURL.length; i++) {
				try {
					tibcoAdmin = new TibjmsAdmin(serverURL[i], userid, password);
					System.out.println(tibcoAdmin.toString());
					System.out.println("Connection " + serverURL[i]  + " Successful");
					
					connectionSuccessMap.put(tibcoAdmin, new Boolean(true));
					
				} catch (TibjmsAdminException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
	}
	
	public void printResult() {
		for (TibjmsAdmin connection : connectionSuccessMap.keySet()) {
			System.out.println(connection + " : " +  connectionSuccessMap.get(connection));
		}
	}
	
	
	
	public static void main(String[] args) {
		
		TibcoEMSConnectionCheck connection = new TibcoEMSConnectionCheck();
		connection.execute();
		connection.printResult();
		connection.cleanup();
	}

	private void cleanup() {
		
		for (TibjmsAdmin connection : connectionSuccessMap.keySet()) {
			try {
				connection.close();
				System.out.println(connection + " Closed");
			} catch (TibjmsAdminException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			
		}
	
		
	}
	
	
	

	
	
}
