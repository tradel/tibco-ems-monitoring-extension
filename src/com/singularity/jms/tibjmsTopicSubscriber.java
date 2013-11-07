package com.singularity.jms;

/* 
 * Copyright (c) 2001-2006 TIBCO Software Inc.
 * All rights reserved.
 * For more information, please contact:
 * TIBCO Software Inc., Palo Alto, California, USA
 * 
 * $Id: tibjmsTopicSubscriber.java 21731 2006-05-01 21:41:34Z $
 * 
 */

/*
 * This is a simple sample of a basic TopicSubscriber.
 *
 * This sampe subscribes to specified topic and
 * receives and prints all received messages.
 * This sample never quits.
 *
 * Notice that the specified topic should exist in your configuration
 * or your topics configuration file should allow
 * creation of the specified topic.
 *
 * This sample can subscribe to dynamic topics thus it is
 * using TopicSession.createTopic() method to obtain the Topic object.
 *
 * If this sample is used to receive messages published by
 * tibjmsTopicPublisher sample, it must be started prior
 * to running the tibjmsTopicPublisher sample.
 *
 * Usage:  java tibjmsTopicSubscriber [options]
 *
 *    where options are:
 *
 *      -server     Server URL.
 *                  If not specified this sample assumes a
 *                  serverUrl of "tcp://localhost:7222"
 *
 *      -user       User name. Default is null.
 *      -password   User password. Default is null.
 *      -topic      Topic name. DEfault is "topic.sample"
 *
 *
 */

import javax.jms.*;
import javax.naming.*;

public class tibjmsTopicSubscriber
{
    String      serverUrl       = null;
    String      userName        = null;
    String      password        = null;
    String      topicName       = "topic.sample";

    public tibjmsTopicSubscriber(String[] args) {

        parseArgs(args);

       /* print parameters */
        System.err.println("\n------------------------------------------------------------------------");
        System.err.println("tibjmsTopicSubscriber SAMPLE");
        System.err.println("------------------------------------------------------------------------");
        System.err.println("Server....................... "+((serverUrl != null)?serverUrl:"localhost"));
        System.err.println("User......................... "+((userName != null)?userName:"(null)"));
        System.err.println("Topic........................ "+topicName);
        System.err.println("------------------------------------------------------------------------\n");

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


        if (topicName == null) {
            System.err.println("Error: must specify topic name");
            usage();
        }

        System.err.println("Subscribing to topic: "+topicName);

        try
        {
            TopicConnectionFactory factory = new com.tibco.tibjms.TibjmsTopicConnectionFactory(serverUrl);

            TopicConnection connection = factory.createTopicConnection(userName,password);

            TopicSession session = connection.createTopicSession(false,javax.jms.Session.AUTO_ACKNOWLEDGE);

            /*
             * Use createTopic() to enable subscriptions to dynamic topics.
             */
            javax.jms.Topic topic = session.createTopic(topicName);

            TopicSubscriber subscriber = session.createSubscriber(topic);

            connection.start();

            /* read topic messages */
            while(true)
            {
                javax.jms.Message message = subscriber.receive();
                if (message == null)
                    break;

                System.err.println("Received message: "+ message);
                    
            }
            
            connection.close();
        }
        catch(JMSException e)
        {
            System.err.println("JMSException: "+e.getMessage()+", provider="+e.getErrorCode());
            e.printStackTrace();
            System.exit(0);
        }
    }

    public static void main(String args[])
    {
        tibjmsTopicSubscriber t = new tibjmsTopicSubscriber(args);
    }

    void usage()
    {
        System.err.println("\nUsage: java tibjmsTopicSubscriber [options]");
        System.err.println("");
        System.err.println("   where options are:");
        System.err.println("");
        System.err.println(" -server   <server URL> - EMS server URL, default is local server");
        System.err.println(" -user     <user name>  - user name, default is null");
        System.err.println(" -password <password>   - password, default is null");
        System.err.println(" -topic    <topic-name> - topic name, default is \"topic.sample\"");
        System.err.println(" -help-ssl              - help on ssl parameters\n");
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
                System.err.println("Unrecognized parameter: "+args[i]);
                usage();
            }
        }
    }
}


