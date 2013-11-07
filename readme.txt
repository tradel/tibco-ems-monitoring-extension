et Tibco EMS Monitor for the Machine Agent 
---------------------------------------


tcp://localhost:7222> quit
bye
hughsmac:bin hbrien$ ./tibemsadmin

TIBCO Enterprise Message Service Administration Tool.
Copyright 2003-2011 by TIBCO Software Inc.
All rights reserved.

Version 6.1.0 V6 8/4/2011

Type 'help' for commands help, 'exit' to exit:
> connect
Login name (admin): admin
Password: 
Connected to: tcp://localhost:7222
tcp://localhost:7222> set server statistics=enabled
Server parameters have been changed
tcp://localhost:7222> 



A machine needs only one active machine agent installation at a time. Make sure you don't 
have any previous running installation processes before you install.

1. Edit the controller-info.xml file to point to installed controller host and controller port.

Go to <agent_install_dir>/conf/controller-info.xml and change the following tags:

 <controller-host></controller-host>
 <controller-port></controller-port>
 <controller-ssl-enabled>false</controller-ssl-enabled> , change to "true" if HTTPS is enabled between the agent and the controller. 

If the machine agent is connecting to a multi-tenant controller or the AppDynamics SaaS controller 
set the account name and access key 
(Otherwise these values are optional):
 
 <account-name></account-name>
 <account-access-key></account-access-key> 

If the machine agent is being installed on a machine which does not have the app server agent, 
or the machine agent will be installed BEFORE the app server agent, these tags may be added:

 <application-name></application-name>  , the name of the application this machine belongs to.
 <tier-name></tier-name>  , the tier this machine is associated with.
 <node-name></node-name>  , the node name assigned to this machine.
 
This information can also be specified using environment variables or system properties:

Using Environment Variables to specify the information in controller-info.xml
--------------------------------------------------------------------------------


Controller Host APPDYNAMICS_CONTROLLER_HOST_NAME
Controller Port APPDYNAMICS_CONTROLLER_PORT
Agent Account Name APPDYNAMICS_AGENT_ACCOUNT_NAME
Agent Account Access Key APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY
Application Name    APPDYNAMICS_AGENT_APPLICATION_NAME
Tier Name   APPDYNAMICS_AGENT_TIER_NAME
Node Name   APPDYNAMICS_AGENT_NODE_NAME
SSL  Enabled  APPDYNAMICS_CONTROLLER_SSL_ENABLED


Using System Properties to specify the information in controller-info.xml
--------------------------------------------------------------------------------


Controller Host appdynamics.controller.hostName
Controller Port appdynamics.controller.port
Agent Account Name appdynamics.agent.accountName
Agent Account Access Key appdynamics.agent.accountAccessKey
Application Name    appdynamics.agent.applicationName
Tier Name   appdynamics.agent.tierName
Node Name   appdynamics.agent.nodeName
SSL Enabled appdynamics.controller.ssl.enabled 
 

2. The machine agent does not ship with a JRE. It runs with any JRE version 1.5 or higher.

The following command will start it -


java -jar machineagent.jar


The machineagent.jar file would be in the directory where you extracted the machine agent.

3. Verify that the agent has been installed correctly.

Check that you have received the following message that the java agent was started successfully in the agent.log file in your <agent_install_dir>/logs/agent.log folder.
This message is also printed on the stdout of the process.

Started APPDYNAMICS Machine Agent Successfully.


4. If you are installing the machine agent on a machine which has a running app server agent, the hardware data is automatically assigned to the app server node/s running
   on the machine.

5. If you are installing the machine agent on a machine which does not have a running app server agent i.e. on a database server/ Message server, or if you did not 
specify the Application Name and Tier Name explicitly in Step 1

   a) you will have to register the machine agent and associate it with an application.
   b) once the relevant database server/message server is discovered in a business transaction, click on the display name link and then on 'Resolve' to associate
      the hardware data to the right tier.


Creating and running a custom monitor/script to send data to the controller as part of the machine agent.
------------------------------------------------------------------------------------------------------------

   A custom monitor has a script attached to it which writes data to the STDOUT of the process in a specific format. This is parsed automatically by the
   machine agent and sent as data to the controller every minute. Every metric has a name and a value which is converted to a java 'long' value.

   The format of the line is

   name=<metric name>,value=<long value>

   The metric names must start either with "Hardware Resources|" or with "Custom Metrics|". You can use "|" separator
   for further hierarchy in the metric name. For example:
    "Hardware Resources|Disks|Total Disk Usage %"
    "Hardware Resources|Disks|Disk 1|Current Disk Usage %"

    "Custom Metrics|MySQL|Avg Query Time"
    "Custom Metrics|Apache|Avg Wait Time"

   If you have multiple metrics, print a different line for each one of them. For example:
    name=Hardware Resources|Disks|Total Disk Usage %, value=23
    name=Hardware Resources|Disks|Disk 1|Current Disk Usage %, value=56
    name=Custom Metrics|MySQL|Avg Query Time, value=500
    name=Custom Metrics|Apache|Avg Wait Time, value=800

Please Refer to http://help.appdynamics.com/entries/318710-use-custom-monitor-to-extend-appdynamics-monitoring-capability for more help with adding custom metrics.

Connecting to the Controller through a Proxy Server
--------------------------------------------------

Use the following system properties to set the host and port of the proxy server so that it can route requests to the controller.

com.singularity.httpclientwrapper.proxyHost=<host>
com.singularity.httpclientwrapper.proxyPort=<port>


Specifying custom host name
---------------------------

The host name for the machine on which the Agent is running is used as an identifying property for the Agent Node. 
If the machine host name is not constant or if you prefer to use a specific name of your choice, please specify the 
following system property as part of your startup command.

-Dappdynamics.agent.uniqueHostId=<host-name>


Uploading custom metrics with HTTP URL
---------------------------------------
1) Start Machine agent with an additional parameter.
java -Dmetric.http.listener=true -jar machineagent.jar

This starts an http listener on port 8293. To use a different port , use the system property metric.http.listener.port.

2) Use the metric upload URL to upload metrics, e.g.
http://localhost:8293/machineagent/metrics?name=Custom Metrics|ACME|Cache Access&value=20&type=sum
to sum up all values for the last minute.

http://localhost:8293/machineagent/metrics?name=Hardware Resources|ACME|Cache Size&value=50&type=average
to average all values for last minute 

In the example above 'Custom Metrics|ACME|Cache Access' is the name of the metric here.

