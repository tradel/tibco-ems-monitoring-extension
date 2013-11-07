package com.singularity.ee.agent.systemagent.monitors.common;

import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.jms.ExceptionListener;
import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.MessageListener;
import javax.jms.TopicConnection;
import javax.jms.TopicConnectionFactory;
import javax.jms.TopicSession;
import javax.jms.TopicSubscriber;

import com.singularity.ee.agent.systemagent.api.MetricWriter;
import com.singularity.ee.agent.systemagent.api.TaskExecutionContext;
import com.singularity.ee.agent.systemagent.api.TaskOutput;
import com.singularity.ee.agent.systemagent.api.exception.TaskExecutionException;
import com.singularity.ee.util.clock.ClockUtils;
import com.tibco.tibjms.admin.ConnectionInfo;
import com.tibco.tibjms.admin.QueueInfo;
import com.tibco.tibjms.admin.TibjmsAdmin;
import com.tibco.tibjms.admin.TibjmsAdminException;

public class TibcoEnterpriseEventMonitor extends JavaServersMonitor implements
		MessageListener, ExceptionListener {
	private volatile String tierName;
	private volatile int refreshIntervalInExecutionTicks;
	private final Map<String, String> cachedValueMap;
	private volatile int currentNumExecutionTicks = -1;
	private volatile List<String> columnNames;

	private volatile String userid;
	private volatile String password;
	private volatile String hostname;
	private volatile String port;

	TopicConnectionFactory factory = null;
	TopicConnection connection = null;
	TopicSession session = null;
	javax.jms.Topic topic = null;
	TopicSubscriber subscriber = null;
	String durableName = "ad_subscriber";

	public TibcoEnterpriseEventMonitor() {
		oldValueMap = Collections.synchronizedMap(new HashMap<String, String>());
		cachedValueMap = Collections.synchronizedMap(new HashMap<String, String>());
	}

	final static String sysTopics[][] = {

	{ "$sys.monitor.Q.*.com.appd.*", "Performance of logs" }

	};

	// { "com.appd.*", "Stats on all com.appd.* queue" },

	/**
	 * In addition to the above, one can subscribe to destination specific
	 * monitor topics:
	 * 
	 * $sys.monitor.D.E.destination
	 * 
	 * A message is handled by a destination. The name of this monitor topic
	 * includes two qualifiers (D and E) and the name of the destination you
	 * wish to monitor. D signifies the type of destination and whether to
	 * include the entire message:
	 * 
	 * - T : topic, include full message (as a byte array) into each event - t :
	 * topic, do not include full message into each event - Q : queue, include
	 * full message (as a byte array) into each event - q : queue, do not
	 * include full message into each event
	 * 
	 * E signifies the type of event:
	 * 
	 * - r for receive - s for send - a for acknowledge - p for premature exit
	 * of message - * for all event types
	 * 
	 * For example, $sys.monitor.T.r.corp.News is the topic for monitoring any
	 * received messages to the topic named corp.News. The message body of any
	 * received messages is included in monitor messages on this topic. The
	 * topic $sys.monitor.q.*.corp.* monitors all message events (send, receive,
	 * acknowledge) for all queues matching the name corp.*. The message body is
	 * not included in this topic's messages.
	 */

	protected void parseArgs(Map<String, String> args) {
		super.parseArgs(args);
		tierName = getArg(args, "tier", null); // if the tier is not specified
												// then create the metrics for
												// all tiers
		userid = getArg(args, "userid", null);
		password = getArg(args, "password", null);
		hostname = getArg(args, "hostname", null);
		port = getArg(args, "port", "7222");
		
		int refreshIntervalSecs = Integer.parseInt(getArg(args,
				"refresh-interval", "60"));

		if (refreshIntervalSecs <= 60) {
			refreshIntervalInExecutionTicks = 1;
		} else {
			// Convert refresh interval to milliseconds and round up to the
			// nearest minute timeslice.
			// From that we can get the number of 60 second ticks before the
			// next refresh.
			// We do this to prevent time drift issues from preventing this task
			// from running.
			refreshIntervalInExecutionTicks = (int) (ClockUtils
					.roundUpTimestampToNextMinute(refreshIntervalSecs * 1000) / 60000);
		}

		if (currentNumExecutionTicks == -1) {
			// This is the first time we've parsed the args. Assume we refresh
			// the data
			// the next time we execute the monitor.
			currentNumExecutionTicks = refreshIntervalInExecutionTicks;
		}
	}

	private TibjmsAdmin connect() throws TibjmsAdminException {

		TibjmsAdmin tibcoAdmin = new TibjmsAdmin("tcp://" + hostname + ":"
				+ port, userid, password);

		return tibcoAdmin;
	}

	// collects all monitoring data for this time period from database
	private Map<String, String> putValuesIntoMap() throws Exception {
		Map<String, String> columnName2Value = new HashMap<String, String>();

		TibjmsAdmin conn = null;
		boolean debug = logger.isDebugEnabled();
		try {
			conn = connect();
			// get most accurate time
			currentTime = System.currentTimeMillis();
			columnName2Value.put("Queue_NAME" + "|ConsumerCount".toUpperCase(),	"23");
			

			System.out.println("Closing Connection to Server");
			conn.close();

		} catch (Exception ex) {
			logger.error("Error getting performance data from Tibco EMS.", ex);
			throw ex;
		} finally {

		}
		return Collections.synchronizedMap(columnName2Value);
	}

	public TaskOutput execute(Map<String, String> taskArguments, TaskExecutionContext taskContext) throws TaskExecutionException {
		startExecute(taskArguments, taskContext);

		// just for debug output
		logger.debug("Starting Listener.......");

		Map<String, String> map;
		try {
			map = this.putValuesIntoMap();
			Iterator keys = map.keySet().iterator();
			while (keys.hasNext()) {
				String key = (String) keys.next();
				String value = map.get(key);
				printMetric(key, value);
				if (logger.isDebugEnabled()) {
					logger.debug("Key :" + key + " : " + value);
				}

			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return this.finishExecute();
	}

	public void startSubscriber() {
		try

		{
			factory = new com.tibco.tibjms.TibjmsTopicConnectionFactory(
					"tcp://" + hostname + ":" + port);
			connection = factory.createTopicConnection(userName, password);
			session = connection.createTopicSession(false,
					javax.jms.Session.AUTO_ACKNOWLEDGE);
			for (int i = 0; i < sysTopics.length; i++) {
				/*
				 * Lookup the topic and subscribe to it.
				 */
				try {
					topic = session.createTopic(sysTopics[i][0]);

				} catch (Exception e) {
					System.out.println("Unable to create topic:" + sysTopics[i][0]);
					continue;
				}
				System.out.println("Creating a durable subscriber to topic: "
						+ sysTopics[i][0]);
				subscriber = session.createDurableSubscriber(topic, durableName
						+ sysTopics[i][0]);
				subscriber.setMessageListener(this);
			}
			connection.setExceptionListener(this);
			connection.start();

			/* read topic messages */
			System.out.print("Waiting for messages");

			while (true) {
				Thread.sleep(1000);
				System.out.print(".");
			}

			// connection.close();
		} catch (Throwable e) {
			e.printStackTrace();
			System.exit(0);
		}
	}

	private void printMetric(String name, String value) {
		printMetric(name, value,
				MetricWriter.METRIC_AGGREGATION_TYPE_OBSERVATION,
				MetricWriter.METRIC_TIME_ROLLUP_TYPE_CURRENT,
				MetricWriter.METRIC_CLUSTER_ROLLUP_TYPE_COLLECTIVE);

	}

	protected String getMetricPrefix() {
		if (tierName != null) {
			return "Server|Component:" + tierName + "|Tibco EMS Server|";
		} else {
			return "Custom Metrics|Tibco EMS Server|";
		}
	}

	@Override
	public void onException(JMSException arg0) {
		// TODO Auto-generated method stub

	}

	@Override
	public void onMessage(Message arg0) {
		// TODO Auto-generated method stub

	}

}
