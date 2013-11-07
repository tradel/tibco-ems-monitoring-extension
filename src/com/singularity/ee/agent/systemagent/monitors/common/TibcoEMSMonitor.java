package com.singularity.ee.agent.systemagent.monitors.common;

import java.sql.Connection;
import java.sql.Statement;
import java.util.Date;
import java.util.Map;

import com.singularity.ee.agent.systemagent.api.MetricWriter;
import com.singularity.ee.agent.systemagent.api.TaskExecutionContext;
import com.singularity.ee.agent.systemagent.api.TaskOutput;
import com.singularity.ee.agent.systemagent.api.exception.TaskExecutionException;

public class TibcoEMSMonitor extends JavaServersMonitor {

	Connection conn = null;
	
	private volatile String tierName;
	private volatile String userid;
	private volatile String password;
	private volatile String hostname;
	private volatile String port;
	
	
	@Override
	public TaskOutput execute(Map<String, String> taskArguments, TaskExecutionContext taskContext)
			throws TaskExecutionException
	{
		startExecute(taskArguments, taskContext);

		try
		{
			populate(valueMap, new String[]{"show global variables", "show global status"});
		}
		catch (Exception ex)
		{
			throw new TaskExecutionException(ex);
		}

		String adminChange = "$sys.monitor.admin.change"; //The administrator has made a change to the configuration.
		String userConnects = "$sys.monitor.connection.connect"; //A user attempts to connect to the server.
		String userDisconnects = "$sys.monitor.connection.disconnect"; //A user connection is disconnected.
		String userErrorConnection = "$sys.monitor.connection.error"; //An error occurs on a user connection.
		String consumerCreate = "$sys.monitor.consumer.create"; //A consumer is created.
		String consumerDestroy = "$sys.monitor.consumer.destroy"; //A consumer is destroyed.
		String monitorMessageFlow = "$sys.monitor.flow.engaged"; //Stored messages rise above a destination’s limit,

		logger.debug("Starting METRIC COLLECTION for Tibco EMS Monitor.......");

		
		
		print("Resource Utilization|Total Active Threads", "10.0");
				
		return this.finishExecute();
	}
	
	
	// collects all monitoring data for this time period from database
	private void populate(Map<String, String> valueMap, String[] queries) throws Exception
	{

		boolean debug = logger.isDebugEnabled();
		valueMap.put("Queue1|Size".toUpperCase(), new Long(new Date().getTime()).toString());
		valueMap.put("Queue2|Size".toUpperCase(), new Long(new Date().getTime()).toString());
		valueMap.put("Queue3|Size".toUpperCase(), new Long(new Date().getTime()).toString());
		valueMap.put("Queue4|Size".toUpperCase(), new Long(new Date().getTime()).toString());
		valueMap.put("Queue5|Size".toUpperCase(), new Long(new Date().getTime()).toString());
		valueMap.put("Queue6|Size".toUpperCase(), new Long(new Date().getTime()).toString());
		valueMap.put("Queue7|Size".toUpperCase(), new Long(new Date().getTime()).toString());
	    currentTime = System.currentTimeMillis();
	}
		

	protected String getMetricPrefix()
	{
		if (tierName != null)
		{
			return "Server|Component:"+tierName+"|EMS Server|";
		}
		else
		{	
			return "Custom Metrics|EMS Server|";
		}
	}
	
	
	protected void parseArgs(Map<String, String> args)
	{
		super.parseArgs(args);
		tierName = getArg(args, "tier", null); // if the tier is not specified then create the metrics for all tiers
		userid = getArg(args, "userid", null);
		password = getArg(args, "password", null);
		hostname = getArg(args, "hostname", null);
		port = getArg(args, "port", "7222");
	}
	
	
	public void print(String metricName, String value) {
		
		printMetric(metricName, getString(value),
				MetricWriter.METRIC_AGGREGATION_TYPE_OBSERVATION, MetricWriter.METRIC_TIME_ROLLUP_TYPE_CURRENT,
				MetricWriter.METRIC_CLUSTER_ROLLUP_TYPE_COLLECTIVE);
		
	}
	

	private String connect() 
	{
		return "";
	}


	

}
