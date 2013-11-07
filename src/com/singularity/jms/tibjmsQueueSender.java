package com.singularity.jms;

/* 
 * Copyright (c) 2001-2006 TIBCO Software Inc.
 * All rights reserved.
 * For more information, please contact:
 * TIBCO Software Inc., Palo Alto, California, USA
 * 
 * $Id: tibjmsQueueSender.java 21731 2006-05-01 21:41:34Z $
 * 
 */

/*
 * This is a simple sample of basic QueueSender.
 *
 * This sample publishes specified message(s) on a specified
 * queue and quits.
 * 
 * Notice that specified queue should exist in your configuration
 * or your queues configuration file should allow
 * creation of the specified queue.
 *
 * This sample can send into dynamic queues thus it is
 * using the QueueSession.createQueue() method
 * to obtain the Queue object.
 *
 * Usage:  java tibjmsQueueSender  [options]
 *                                  <message-text1>
 *                                  ...
 *                                  <message-textN>
 *
 *
 *    where options are:
 *
 *      -server     Server URL.
 *                  If not specified this sample assumes a
 *                  serverUrl of "tcp://localhost:7222"
 *
 *      -user       User name. Default is null.
 *      -password   User password. Default is null.
 *      -queue      Queue name. Default is "queue.sample"
 *
 *
 */

import javax.jms.*;
import javax.naming.*;
import java.util.Vector;

public class tibjmsQueueSender
{
    String      serverUrl       = null;
    String      userName        = null;
    String      password        = null;
    String      queueName       = "queue.sample";
    
    String[] queues = { "tibco.singularity.queue.inbound", "tibco.singularity.queue.outbound"};
    String[] topics = { "tibco.singularity.topic.inbound", "tibco.singularity.topic.outbound"};
  
    Vector      data            = new Vector();

    public tibjmsQueueSender(String[] args) {

        parseArgs(args);

        /* print parameters */
        System.out.println("\n------------------------------------------------------------------------");
        System.out.println("tibjmsQueueSender SAMPLE");
        System.out.println("------------------------------------------------------------------------");
        System.out.println("Server....................... "+(serverUrl!=null?serverUrl:"localhost"));
        System.out.println("User......................... "+(userName!=null?userName:"(null)"));
        System.out.println("Queue........................ "+queueName);
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

        if (queueName == null)
        {
            System.err.println("Error: must specify queue name");
            usage();
        }

        if (data.size() == 0)
        {
            System.err.println("Error: must specify at least one message text");
            usage();
        }

        System.err.println("Publishing into queue: '"+queueName+"'\n");

        try
        {
            QueueConnectionFactory factory = new com.tibco.tibjms.TibjmsQueueConnectionFactory(serverUrl);
            QueueConnection connection = factory.createQueueConnection(userName,password);
            QueueSession session = connection.createQueueSession(false,javax.jms.Session.AUTO_ACKNOWLEDGE);
            QueueSender sender = null;
            /*
             * Use createQueue() to enable sending into dynamic queues.
             */
            
            for (int i = 0; i < queues.length; i++) {
            	javax.jms.Queue queue = session.createQueue(queues[i]);
            	sender = session.createSender(queue);
			}
            
            for (int i = 0; i < topics.length; i++) {
            	javax.jms.Topic topic1 = session.createTopic(topics[i]);
			}
            
            
            /* publish messages */
            for (int i=0; i<data.size(); i++)
            {
                javax.jms.TextMessage message = session.createTextMessage();
                String text = (String)data.elementAt(i);
                message.setText(text);
                sender.send(message);
                System.err.println("Sent message: "+text);
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
        tibjmsQueueSender t = new tibjmsQueueSender(args);
    }

    void usage()
    {
        System.err.println("\nUsage: java tibjmsQueueSender [options]");
        System.err.println("                                <message-text1 ... message-textN>");
        System.err.println("");
        System.err.println("   where options are:");
        System.err.println("");
        System.err.println(" -server    <server URL> - EMS server URL, default is local server");
        System.err.println(" -user      <user name>  - user name, default is null");
        System.err.println(" -password  <password>   - password, default is null");
        System.err.println(" -queue     <queue-name> - queue name, default is \"queue.sample\"");
        System.err.println(" -help-ssl               - help on ssl parameters\n");
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
            if (args[i].compareTo("-queue")==0)
            {
                if ((i+1) >= args.length) usage();
                queueName = args[i+1];
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


