package com.singularity.jms;

/* 
 * Copyright (c) 2001-2006 TIBCO Software Inc.
 * All rights reserved.
 * For more information, please contact:
 * TIBCO Software Inc., Palo Alto, California, USA
 * 
 * $Id: tibjmsQueueReceiver.java 21731 2006-05-01 21:41:34Z $
 * 
 */

/*
 * This is a simple sample of basic QueueReceiver.
 *
 * This sampe subscribes to specified queue and
 * receives and prints all received messages.
 * This sample never quits.
 *
 * Notice that specified queue should exist in your configuration
 * or your queues configuration file should allow
 * creation of the specified queue.
 *
 * This sample can receive from dynamic queues thus it is
 * using the QueueSession.createQueue() method in order to
 * obtain the Queue object.
 *
 * Usage:  java tibjmsQueueReceiver [options]
 *
 *    where options are:
 *
 *      -server     Server URL.
 *                  If not specified this sample assumes a
 *                  serverUrl of "tcp://localhost:7222"
 *
 *      -user       User name. Default is null.
 *      -password   User password. Default is null.
 *      -queue      Queue name. Default is "queue.sample".
 *
 *
 */

import javax.jms.*;
import javax.naming.*;

public class tibjmsQueueReceiver
{
    String      serverUrl       = null;
    String      userName        = null;
    String      password        = null;
    String      queueName       = "queue.sample";
    
    public tibjmsQueueReceiver(String[] args) {

        parseArgs(args);

       /* print parameters */
        System.err.println("\n------------------------------------------------------------------------");
        System.err.println("tibjmsQueueReceiver SAMPLE");
        System.err.println("------------------------------------------------------------------------");
        System.err.println("Server....................... "+((serverUrl != null)?serverUrl:"localhost"));
        System.err.println("User......................... "+((userName != null)?userName:"(null)"));
        System.err.println("Queue........................ "+queueName);
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

        if (queueName == null)
        {
            System.err.println("Error: must specify queue name");
            usage();
        }

        System.err.println("Receiving from queue: "+queueName+"\n");
        
        try
        {
            QueueConnectionFactory factory = new com.tibco.tibjms.TibjmsQueueConnectionFactory(serverUrl);

            QueueConnection connection = factory.createQueueConnection(userName,password);

            QueueSession session = connection.createQueueSession(false,javax.jms.Session.AUTO_ACKNOWLEDGE);

            /*
             * Use createQueue() to enable receiving from dynamic queues.
             */
            javax.jms.Queue queue = session.createQueue(queueName);

            QueueReceiver receiver = session.createReceiver(queue);

            connection.start();

            /* read queue messages */
            while(true)
            {
                javax.jms.Message message = receiver.receive();
                if (message == null)
                    break;

                System.err.println("Received message: "+message);
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
        tibjmsQueueReceiver t = new tibjmsQueueReceiver(args);
    }

    void usage()
    {
        System.err.println("\nUsage: java tibjmsQueueReceiver [options]");
        System.err.println("");
        System.err.println("   where options are:");
        System.err.println("");
        System.err.println("  -server    <server URL> - EMS server URL, default is local server");
        System.err.println("  -user      <user name>  - user name, default is null");
        System.err.println("  -password  <password>   - password, default is null");
        System.err.println("  -queue     <queue-name> - queue name, default is \"queue.sample\"");
        System.err.println("  -help-ssl               - help on ssl parameters\n");
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
                System.err.println("Unrecognized parameter: "+args[i]);
                usage();
            }
        }
    }
}


