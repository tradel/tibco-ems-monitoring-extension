package com.singularity.jms;
/* 
 * Copyright (c) 2001-2006 TIBCO Software Inc.
 * All rights reserved.
 * For more information, please contact:
 * TIBCO Software Inc., Palo Alto, California, USA
 * 
 * $Id: tibjmsTopicPublisher.java 21731 2006-05-01 21:41:34Z $
 * 
 */

/*
 * This is a simple sample of a basic TopicPublisher.
 *
 * This sample publishes specified message(s) on a specified
 * topic and quits.
 *
 * Notice that the specified topic should exist in your configuration
 * or your topics configuration file should allow
 * creation of the specified topic. Sample configuration supplied with
 * the TIBCO Enterprise Message Service distribution allows creation of
 * any topics.
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
 * Usage:  java tibjmsTopicPublisher  [options]
 *                                    <message-text1>
 *                                    ...
 *                                    <message-textN>
 *
 *  where options are:
 *
 *   -server    <server-URL>  Server URL.
 *                            If not specified this sample assumes a
 *                            serverUrl of "tcp://localhost:7222"
 *   -user      <user-name>   User name. Default is null.
 *   -password  <password>    User password. Default is null.
 *   -topic     <topic-name>  Topic name. Default value is "topic.sample"
 *
 */

import javax.jms.*;
import javax.naming.*;
import java.util.Vector;

public class tibjmsTopicPublisher
{
    String      serverUrl       = null;
    String      userName        = null;
    String      password        = null;

    String      topicName       = "topic.sample";

    Vector      data            = new Vector();
    
    public tibjmsTopicPublisher(String[] args) {

        parseArgs(args);

        /* print parameters */
        System.out.println("\n------------------------------------------------------------------------");
        System.out.println("tibjmsTopicPublisher SAMPLE");
        System.out.println("------------------------------------------------------------------------");
        System.out.println("Server....................... "+(serverUrl!=null?serverUrl:"localhost"));
        System.out.println("User......................... "+(userName!=null?userName:"(null)"));
        System.out.println("Topic........................ "+topicName);
        System.out.println("Message Text................. ");
        for(int i=0;i<data.size();i++) 
        {
            System.out.println("\t"+data.elementAt(i));
        }
        System.out.println("------------------------------------------------------------------------\n");

        try 
        {
            tibjmsUtilities.initSSLParams(serverUrl,args);
        }
        catch (JMSSecurityException e)
        {
            System.err.println("JMSSecurityException: "+e.getMessage()+", provider="+e.getErrorCode());
            e.printStackTrace();
            System.exit(0);
        }

        if (topicName == null)
        {
            System.err.println("Error: must specify topic name");
            usage();
        }

        if (data.size() == 0)
        {
            System.err.println("Error: must specify at least one message text");
            usage();
        }

        System.err.println("Publishing on topic '"+topicName+"'\n");

        try
        {
            TopicConnectionFactory factory = new com.tibco.tibjms.TibjmsTopicConnectionFactory(serverUrl);

            TopicConnection connection = factory.createTopicConnection(userName,password);

            TopicSession session = connection.createTopicSession(false,javax.jms.Session.AUTO_ACKNOWLEDGE);

            /*
             * Use createTopic() to enable publishing into dynamic topics.
             */
            javax.jms.Topic topic = session.createTopic(topicName);

            TopicPublisher publisher = session.createPublisher(topic);

            /* publish messages */
            for (int i=0; i<data.size(); i++)
            {
                javax.jms.TextMessage message = session.createTextMessage();
                String text = (String)data.elementAt(i);
                message.setText(text);
                publisher.publish(message);
                System.err.println("Published message: "+text);
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
        tibjmsTopicPublisher t = new tibjmsTopicPublisher(args);
    }

    void usage()
    {
        System.err.println("\nUsage: java tibjmsTopicPublisher [options]");
        System.err.println("                            <message-text-1>");
        System.err.println("                           [<message-text-2>] ...");
        System.err.println("");
        System.err.println("   where options are:");
        System.err.println("");
        System.err.println("   -server   <server URL>  - EMS server URL, default is local server");
        System.err.println("   -user     <user name>   - user name, default is null");
        System.err.println("   -password <password>    - password, default is null");
        System.err.println("   -topic    <topic-name>  - topic name, default is \"topic.sample\"");
        System.err.println("   -help-ssl               - help on ssl parameters\n");
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
            if (args[i].compareTo("-help-ssl")==0)
            {
                tibjmsUtilities.sslUsage();
            }
            else
            if(args[i].startsWith("-ssl"))
            {
                i += 2;
            }
            else
            {
                data.addElement(args[i]);
                i++;
            }
        }
    }
}


