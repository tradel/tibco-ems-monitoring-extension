package com.singularity.jms;


/* 

 * Copyright (c) 2001-2006 TIBCO Software Inc.
 * All rights reserved.
 * For more information, please contact:
 * TIBCO Software Inc., Palo Alto, California, USA
 * 
 * $Id: tibjmsLoadBalancedTopicPublisher.java 21731 2006-05-01 21:41:34Z $
 * 
 */

/*
 * This is a sample illustrating the use of a load balancing connection
 * factory.
 *
 * This sample creates a load balancing connection factory locally (as
 * opposed to looking one up via JNDI) which create connections to the least
 * busy server. To best illustrate the load balancing, several instances of
 * this client should be run simultaneously.
 *
 * The default behavior is for the client to create a connection factory
 * that supplies a connection to the EMS Server with the lowest number of
 * connections. To illustrate an alternative way to load balance, the
 * -balanceByRate option can be used which will create a connection
 * factory which balances across servers by returning a connection to the
 * server with the lowest total inbound and outbound rate (in bytes).
 *
 * Notice that the specified topic should exist in your configuration
 * or your topics configuration file should allow
 * creation of the specified topic. Sample configuration supplied with
 * the TIBCO Enterprise Message Service distribution allows creation of any
 * topics.
 *
 * This sample can publish into dynamic topics thus it is
 * using TopicSession.createTopic() method to obtain the Topic object.
 *
 * If this sample is used to publish messages into
 * tibjmsTopicSubscriber sample, the tibjmsTopicSubscriber
 * sample must be started first.
 *
 * If -topic is not specified this sample will use topic named
 * "topic.sample".
 *
 * Usage:  java tibjmsLoadBalancedTopicPublisher  [options]
 *                                    -servers url1 url2 ....
 *
 *  where options are:
 *
 *   -user          <user-name>      User name for publishing. Default is
 *                                   null.
 *   -password      <password>       User password for publishing. Default is
 *                                   null.
 *   -topic         <topic-name>     Topic name. Default value is
 *                                   "topic.sample".
 *   -messages      <n>              Number of messages to publish. Default is
 *                                   100.
 *   -delay         <d>              Number of seconds delay between
 *                                   publishes. Default is 1 sec.
 *   -balanceByRate                  Choose the EMS Server with lowest
 *                                   byte rate (inbound + outbound).
 */

import javax.jms.*;
import java.util.HashMap;

import com.tibco.tibjms.Tibjms;
import com.tibco.tibjms.TibjmsConnection;

public class tibjmsLoadBalancedTopicPublisher
{
    String      serverList      = "";
    String      userName        = null;
    String      password        = null;

    String      topicName       = "topic.sample";

    int         messages        = 100;
    int         delay           = 1;

    boolean     balanceByConnections = true;

    public tibjmsLoadBalancedTopicPublisher(String[] args) {

        parseArgs(args);

        /* print parameters */
        System.out.println("\n------------------------------------------------------------------------");
        System.out.println("tibjmsLoadBalancedTopicPublisher SAMPLE");
        System.out.println("------------------------------------------------------------------------");
        System.out.println("Servers...................... "+serverList);
        System.out.println("User......................... "+(userName!=null?userName:"(null)"));
        System.out.println("Topic........................ "+topicName);
        System.out.println("Messages..................... "+messages);
        System.out.println("Delay........................ "+delay);
        System.out.println("------------------------------------------------------------------------\n");

        System.err.println("Publishing on topic '"+topicName+"'\n");

        try
        {
            HashMap properties = new HashMap();
            Integer metric;
            if (balanceByConnections)
                metric = new Integer(Tibjms.FACTORY_LOAD_BALANCE_METRIC_CONNECTIONS);
            else
                metric = new Integer(Tibjms.FACTORY_LOAD_BALANCE_METRIC_BYTE_RATE);

            properties.put(Tibjms.FACTORY_LOAD_BALANCE_METRIC, metric);

            TopicConnectionFactory factory = new com.tibco.tibjms.TibjmsTopicConnectionFactory(serverList,
                null,properties);

            TopicConnection connection = factory.createTopicConnection(userName,password);

            TopicSession session = connection.createTopicSession(false,javax.jms.Session.AUTO_ACKNOWLEDGE);

            /*
             * Use createTopic() to enable publishing into dynamic topics.
             */
            javax.jms.Topic topic = session.createTopic(topicName);

            TopicPublisher publisher = session.createPublisher(topic);

            /* publish messages */
            for (int i=0; i<messages; i++)
            {
                javax.jms.TextMessage message = session.createTextMessage();
                String text = "Load balanced message "+i;
                message.setText(text);
                publisher.publish(message);
                System.err.println("Published message "+i+" to server "
                    + Tibjms.getConnectionActiveURL(connection));
                try {
                    Thread.sleep(delay*1000);
                }
                catch (InterruptedException e) {
                }
            }

            connection.close();
        }
        catch(JMSException e)
        {
            e.printStackTrace();
            System.exit(0);
        }
    }

    public static void main(String args[])
    {
        tibjmsLoadBalancedTopicPublisher t = new tibjmsLoadBalancedTopicPublisher(args);
    }

    void usage()
    {
        System.err.println("\nUsage:  java tibjmsLoadBalancedTopicPublisher  [options]");
        System.err.println("                                   -servers url1 url2 ....");
        System.err.println("");
        System.err.println(" where options are:");
        System.err.println("");
        System.err.println("  -user          <user-name>      User name for publishing. Default is");
        System.err.println("                                  null. ");
        System.err.println("  -password      <password>       User password for publishing. Default is");
        System.err.println("                                  null.");
        System.err.println("  -topic         <topic-name>     Topic name. Default value is");
        System.err.println("                                  \"topic.sample\".");
        System.err.println("  -messages      <n>              Number of messages to publish. Default is");
        System.err.println("                                  100.");
        System.err.println("  -delay         <d>              Number of seconds delay between");
        System.err.println("                                  publishes. Default is 1 sec.");
        System.err.println("  -balanceByRate                  Choose the EMS Server with lowest");
        System.err.println("                                  byte rate (inbound + outbound).");
        System.exit(0);
    }

    void parseArgs(String[] args)
    {
        int i=0;
        boolean first = true;

        while(i < args.length)
        {
            if (args[i].compareTo("-servers")==0)
            {
                if ((i+1) >= args.length) usage();
                i++;
                while (i < args.length && !(args[i].startsWith("-")))
                {
                    if (!first)
                        serverList += "|";
                    else
                        first = false;
                    serverList += args[i];
                    i++;
                }
            }
            else
            if (args[i].compareTo("-topic")==0)
            {
                if ((i+1) >= args.length) usage();
                topicName = args[i+1];
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
            if (args[i].compareTo("-messages")==0)
            {
                if ((i+1) >= args.length) usage();
                messages = Integer.parseInt(args[i+1]);
                i += 2;
            }
            else
            if (args[i].compareTo("-delay")==0)
            {
                if ((i+1) >= args.length) usage();
                delay = Integer.parseInt(args[i+1]);
                i += 2;
            }
            else
            if (args[i].compareTo("-balanceByRate")==0)
            {
                balanceByConnections = false;
                i += 1;
            }
            else
            {
                usage();
            }
        }

        if (first)
        {
            System.err.println("\nNo server urls specified.\n");
            usage();
        }
    }
}


