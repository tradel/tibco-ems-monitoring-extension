package com.singularity.ee.agent.systemagent.monitors.common;



import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.singularity.ee.agent.systemagent.api.MetricWriter;
import com.singularity.ee.agent.systemagent.api.TaskExecutionContext;
import com.singularity.ee.agent.systemagent.api.TaskOutput;
import com.singularity.ee.agent.systemagent.api.exception.TaskExecutionException;
import com.singularity.ee.agent.systemagent.monitors.common.JavaServersMonitor;
import com.singularity.ee.util.clock.ClockUtils;

public class TibcoEMSMonitor2 extends JavaServersMonitor
{
	private volatile String tierName;
	private volatile String database; // the database we are interested in collecting metrics on
	private volatile int refreshIntervalInExecutionTicks;
	private final Map<String, String> cachedValueMap;
	private volatile int currentNumExecutionTicks = -1;
	private volatile List<String> columnNames;

	public TibcoEMSMonitor2()
	{
		oldValueMap = Collections.synchronizedMap(new HashMap<String, String>());
		cachedValueMap = Collections.synchronizedMap(new HashMap<String, String>());
	}

	protected void parseArgs(Map<String, String> args)
	{
		super.parseArgs(args);
		tierName = getArg(args, "tier", null); // if the tier is not specified then create the metrics for all tiers
		database = getArg(args, "target-database", "postgres");
		
		// Assume all the columns we want values for are in a comma separated list
		String columnNamesString = getArg(args, "columns", null);
		
		if (columnNamesString == null || columnNamesString.length() == 0)
		{
			columnNames = Collections.emptyList();
		}
		else
		{
			columnNames = Arrays.asList(columnNamesString.split(","));
		}
		
		int refreshIntervalSecs = Integer.parseInt(getArg(args, "refresh-interval", "60"));
		
		if (refreshIntervalSecs <= 60)
		{
			refreshIntervalInExecutionTicks = 1;
		}
		else
		{
			// Convert refresh interval to milliseconds and round up to the nearest minute timeslice.
			// From that we can get the number of 60 second ticks before the next refresh.
			// We do this to prevent time drift issues from preventing this task from running.
			refreshIntervalInExecutionTicks = (int)(ClockUtils.roundUpTimestampToNextMinute(refreshIntervalSecs*1000)/60000);			
		}
		
		if (currentNumExecutionTicks == -1)
		{
			// This is the first time we've parsed the args. Assume we refresh the data 
			// the next time we execute the monitor.
			currentNumExecutionTicks = refreshIntervalInExecutionTicks;
		}
	}
	
	private boolean connect() 
	{
	
		logger.debug("Successfully connected to Postgres DB");
		return true;
		
	}

	// collects all monitoring data for this time period from database
	private Map<String, String> getValuesForColumns(List<String> columnNames,
			String query) throws Exception {
		Map<String, String> columnName2Value = new HashMap<String, String>();

		boolean debug = logger.isDebugEnabled();

		//columnName2Value.put(columnName.toUpperCase(), value);
		return Collections.synchronizedMap(columnName2Value);
	}

	public TaskOutput execute(Map<String, String> taskArguments, TaskExecutionContext taskContext)
			throws TaskExecutionException
	{
		startExecute(taskArguments, taskContext);

		try
		{
			if (++currentNumExecutionTicks >= refreshIntervalInExecutionTicks)
			{
				logger.debug("Querying fresh values for Postgres PgStatActivity Monitor.......");
				
				// Store the current values for the columns specified in the list
				valueMap = getValuesForColumns(columnNames, "select * from pg_stat_database where datname='"+database+"'");
				
				// Update the cached values
				cachedValueMap.clear();
				cachedValueMap.putAll(valueMap);
								
				currentNumExecutionTicks = 0;
			}
			else
			{
				logger.debug("Using cached values for Postgres PgStatActivity Monitor.......");
				
				// Use the cached values
				valueMap = Collections.synchronizedMap(new HashMap<String, String>(cachedValueMap));
			}	
		}
		catch (Exception ex)
		{
			throw new TaskExecutionException(ex);
		} 

		// just for debug output
		logger.debug("Starting METRIC COLLECTION for Postgres PgStatActivity Monitor.......");
	
		Set<String> uniqueColumnNames = new HashSet<String>(columnNames);
		
		printMetric("numbackends", "PgStatActivity|Num Backends", uniqueColumnNames);
		printMetric("xact_commit", "PgStatActivity|Txn Commits", uniqueColumnNames);
		printMetric("xact_rollback", "PgStatActivity|Txn Rollbacks", uniqueColumnNames);
		printMetric("blks_read", "PgStatActivity|Blocks Read", uniqueColumnNames);		
		printMetric("blks_hit", "PgStatActivity|Blocks Hit", uniqueColumnNames);		
		printMetric("tup_returned", "PgStatActivity|Tuples Returned", uniqueColumnNames);		
		printMetric("tup_fetched", "PgStatActivity|Tuples Fetched", uniqueColumnNames);	
		printMetric("tup_inserted", "PgStatActivity|Tuples Inserted", uniqueColumnNames);			
		printMetric("tup_updated", "PgStatActivity|Tuples Updated", uniqueColumnNames);
		printMetric("tup_deleted", "PgStatActivity|Tuples Deleted", uniqueColumnNames);		
		
		return this.finishExecute();
	}
	
	private void printMetric(String columnName, String metricLabel, Set<String> uniqueColumnNames)
	{
		if (uniqueColumnNames.contains(columnName))
		{
			printMetric(metricLabel, getString(columnName),
					MetricWriter.METRIC_AGGREGATION_TYPE_OBSERVATION, 
					MetricWriter.METRIC_TIME_ROLLUP_TYPE_CURRENT,
					MetricWriter.METRIC_CLUSTER_ROLLUP_TYPE_COLLECTIVE);
		}
	}

	protected String getMetricPrefix()
	{
		if (tierName != null)
		{
			return "Server|Component:"+tierName+"|Postgres Server|"+database+"|";
		}
		else
		{	
			return "Custom Metrics|Postgres Server|"+database+"|";
		}
	}

}
