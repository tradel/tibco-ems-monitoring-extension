package com.appdynamics.tibco.ems.systopicsubscriber;

/**
 *  This class will (adopted from the EMS samples)
 *  be used to durably subscribe to system topics published
 *  by the Tibco Hawk micro-agent embedded inside the Tibco
 *  Enterprise Messaging Service (EMS).
 *  
 * Copyright (c) AppDynamics, Inc.
 * @author Pranta Das
 * February 2, 2012.
 *
 */

import javax.jms.*;
import javax.naming.Context;

public class SystemTopicSubscriber implements MessageListener, ExceptionListener
{
    static Context jndiContext = null;

    static final String  providerContextFactory =
                            "com.tibco.tibjms.naming.TibjmsInitialContextFactory";

    static final String  defaultProtocol = "tibjmsnaming";

    static final String  defaultProviderURL =
                            defaultProtocol + "://localhost:7222";

    String      serverUrl       = null;
    String      userName        = "admin";
    String      password        = null;

    String      durableName     = "ad_subscriber";

    final static String sysTopics[][] = {
            {"$sys.monitor.admin.change", "The administrator has made a change to the configuration."},
            {"$sys.monitor.connection.connect", "A user attempts to connect to the server."},
            {"$sys.monitor.connection.disconnect", "A user connection is disconnected."},
            {"$sys.monitor.connection.error", "An error occurs on a user connection."},
            {"$sys.monitor.consumer.create", "A consumer is created."},
            {"$sys.monitor.consumer.destroy", "A consumer is destroyed."},
            {"$sys.monitor.flow.engaged", "Stored messages rise above a destination’s limit, engaging the flow control feature."},
            {"$sys.monitor.flow.disengaged", "Stored messages fall below a destination’s limit, disengaging the flow control feature."},
            {"$sys.monitor.limits.connection", "Maximum number of hosts or connections is reached."},
            {"$sys.monitor.limits.queue", "Maximum bytes for queue storage is reached."},
            {"$sys.monitor.limits.server", "Server memory limit is reached."},
            {"$sys.monitor.limits.topic", "Maximum bytes for durable subscriptions is reached."},
            {"$sys.monitor.multicast.stats", "The message published contains low-level PGM statistics from the server and multicast daemons."},
            {"$sys.monitor.multicast.status", "A message consumer subscribes or attempts to subscribe to a multicast-enabled topic."},
            {"$sys.monitor.producer.create", "A producer is created."},
            {"$sys.monitor.producer.destroy", "A producer is destroyed."},
            {"$sys.monitor.queue.create", "A dynamic queue is created."},
            {"$sys.monitor.route.connect", "A route connection is attempted."},
            {"$sys.monitor.route.disconnect", "A route connection is disconnected."},
            {"$sys.monitor.route.error", "An error occurs on a route connection."},
            {"$sys.monitor.route.interest", "A change in registered interest occurs on the route."},
            {"$sys.monitor.server.info", "The server sends information about an event; for example, a log file is rotated."},
            {"$sys.monitor.server.warning", "The primary server detects a disconnection from the backup server."},
            {"$sys.monitor.topic.create", "A dynamic topic is created."},
            {"$sys.monitor.tx.action", "A local transaction commits or rolls back."},
            {"$sys.monitor.xa.action", "An XA transaction commits or rolls back."},

            /**
             * In addition to the above, one can subscribe to destination specific monitor topics:
             *
             * $sys.monitor.D.E.destination
             *
             *       A message is handled by a destination. The name of
             *       this monitor topic includes two qualifiers (D and E)
             *       and the name of the destination you wish to monitor.
             *       D signifies the type of destination and whether to
             *       include the entire message:
             *
             *       - T : topic, include full message (as a byte array)
             *       into each event
             *       - t : topic, do not include full message into each
             *       event
             *       - Q : queue, include full message (as a byte array)
             *       into each event
             *       - q : queue, do not include full message into each
             *       event
             *
             *       E signifies the type of event:
             *
             *       - r for receive
             *       - s for send
             *       - a for acknowledge
             *       - p for premature exit of message
             *       - * for all event types
             *
             *       For example, $sys.monitor.T.r.corp.News is the
             *       topic for monitoring any received messages to the topic
             *       named corp.News. The message body of any received
             *       messages is included in monitor messages on this
             *       topic. The topic $sys.monitor.q.*.corp.* monitors
             *       all message events (send, receive, acknowledge) for all
             *       queues matching the name corp.*. The message body
             *       is not included in this topic's messages.
             */
   };

    public static void main(String[] args) throws Exception
    {
       new SystemTopicSubscriber(args);

    }

    public SystemTopicSubscriber(String[] args) {

        parseArgs(args);

        TopicConnectionFactory factory = null;

        TopicConnection connection = null;

        TopicSession session = null;

        javax.jms.Topic topic = null;

        TopicSubscriber subscriber = null;

        try

        {

            factory = new com.tibco.tibjms.TibjmsTopicConnectionFactory(serverUrl);

            connection = factory.createTopicConnection(userName,password);

            session = connection.createTopicSession(false,javax.jms.Session.AUTO_ACKNOWLEDGE);

            for (int i=0; i < sysTopics.length; i++)
            {

                /*
                 * Lookup the topic and subscribe to it.
                 */
                try
                {
                    topic = session.createTopic(sysTopics[i][0]);                }
                catch(Exception e)
                {
                    System.out.println("Unable to create topic:"+sysTopics[i][0]);
                    continue;
                }

                System.err.println("Creating a durable subscriber to topic: "+sysTopics[i][0]);

                subscriber = session.createDurableSubscriber(topic,durableName+sysTopics[i][0]);

                subscriber.setMessageListener(this);
            }

            connection.setExceptionListener(this);
            connection.start();

            /* read topic messages */
            System.out.print("Waiting for messages");

            while(true)
            {
                Thread.sleep(1000);
                System.out.print(".");

            }

            //connection.close();

        }
        catch(Throwable e)
        {
            e.printStackTrace();
            System.exit(0);
        }
    }

    /**
       This method is called asynchronously by JMS when a message arrives
       at the topic. Client applications must not throw any exceptions in
       the onMessage method.
       @param message A JMS message.
     */
    public void onMessage(Message message)
    {
    	com.tibco.tibjms.TibjmsMapMessage msg = (com.tibco.tibjms.TibjmsMapMessage) message;
        System.out.println("received: " + msg.toString());
    }

    /**
       This method is called asynchronously by JMS when some error occurs.
       When using an asynchronous message listener it is recommended to use
       an exception listener also since JMS have no way to report errors
       otherwise.
       @param exception A JMS exception.
     */
    public void onException(JMSException exception)
    {
       System.err.println("something bad happended: " + exception);
    }
    void usage()
    {
        System.err.println("\nUsage: java SystemTopicSubscriber [options]");
        System.err.println("");
        System.err.println("   where options are:");
        System.err.println("");
        System.err.println(" -server   <server URL> - EMS server URL, default is local server");
        System.err.println(" -user     <user name>  - user name, default is null");
        System.err.println(" -password <password>   - password, default is null");
        System.exit(0);
    }

    void parseArgs(String[] args)
    {
        int i=0;

        while(i < args.length)
        {
            if (args[i].compareTo("-server")==0)
            {
                if ((i+1) >= args.length) usage();
                serverUrl = args[i+1];
                i += 2;
            }
            else
            if (args[i].compareTo("-user")==0)
            {
                if ((i+1) >= args.length) usage();
                userName = args[i+1];
                i += 2;
            }
            else
            if (args[i].compareTo("-password")==0)
            {
                if ((i+1) >= args.length) usage();
                password = args[i+1];
                i += 2;
            }
            else
            if (args[i].compareTo("-help")==0)
            {
                usage();
            }
            else
            {
                System.err.println("Unrecognized parameter: "+args[i]);
                usage();
            }
        }
    }
}