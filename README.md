Title:       Tibco EMS plugin for AppDynamics machine agent
Author:      Todd Radel
Affiliation: AppDynamics Inc.
Email:       tradel@appdynamics.com
Date:        7 November 2013
CSS:         /Applications/Marked.app/Contents/Resources/swiss.css

TibcoEMSMonitor
===============

## Introduction

An AppDynamics Machine Agent add-on to report metrics from a [Tibco EMS server][] and its queues.

Tibco EMS is messaging middleware that provides persistent queues as well as a publish/subscribe mechanism. It can be used as a JMS provider, or it can be used directly via native API's.

This eXtension requires the Java Machine Agent.


## Prerequisites

Before starting this monitor, make sure your EMS server is configured to report statistics. You can do this by editing the file `tibemsd.conf` in your `TIBCO_HOME`, or by using the `tibemsadmin` command line utility.

#### Configuring statistics by editing tibemsd.conf

1. Add the following line to `tibemsd.conf`:

        statistics = enabled

1. Restart Tibco EMS.

#### Configuring statistics using the command line

Use the `tibemsadmin` utility to change the server configuration.

        root# tibemsadmin -server localhost:7222

        TIBCO Enterprise Message Service Administration Tool.
        Copyright 2003-2013 by TIBCO Software Inc.
        All rights reserved.

        Version 8.0.0 V9 6/7/2013

        Login name (admin):
        Password:
        Connected to: tcp://localhost:7222
        Type 'help' for commands help, 'exit' to exit:
        tcp://localhost:7222> set server statistics=enabled
        Server parameters have been changed
        tcp://localhost:7222> quit
        bye


## Installation

1. Download TibcoEMSMonitor.zip from AppSphere.
1. Copy TibcoEMSMonitor.zip into the directory where you installed the machine agent, under `$AGENT_HOME/monitors`.
1. Unzip the file. This will create a new directory called `TibcoEMSMonitor`.
1. In `$AGENT_HOME/monitors/TibcoEMSMonitor`, edit the file `monitor.xml` and configure the plugin for your Tibco EMS installation.
1. Restart the machine agent.

## Configuration

Configuration for this monitor is in the `monitor.xml` file in the monitor directory. All of the configurable options are in the `<task-arguments>` section.

hostname
: Name or IP address of the Tibco EMS server. Required.

port
: TCP port number where the Tibco server is listening. The default value is 7222. Required.

userid
: Administrative user ID for the Tibco admin interface. The default value is "admin". Required.

password
: Password for the administrative user ID. The default value is an empty password. Required.

tier
: Name of the tier in AppDynamics for which the monitor should register its metrics. If not specified, the metrics will be registered on all tiers. Optional.

emsservername
: An additional folder to create under the "Custom Metrics" folder. Optional.

showTempQueues
: If set to true, the monitor will report metrics on temporary queues (defined as any queue whose name starts with `$TMP$.`). **NOTE:** Enabling this option can potentially cause the agent to overflow its metric limit.

showSysQueues
: If set to true, the monitor will report metrics on system queues (defined as any queue whose name starts with `$sys.`).




## Metrics Provided

### Global Instance Metrics

| Metric Name          | Description                                                           |
| :------------------- | :-------------------------------------------------------------------- |
| DiskReadRate         | Rate at which messages are being read from disk, in bytes per second  |
| DiskWriteRate        | Rate at which messages are being written to disk, in bytes per second |
| ConnectionCount      | Current number of connections                                         |
| MaxConnections       | Maximum number of connections allowed by the server                   |
| ProducerCount        | Total number of producers                                             |
| ConsumerCount        | Total number of consumers                                             |
| PendingMessageCount  | Total number of pending messages                                      |
| PendingMessageSize   | Total size of pending messages in bytes                               |
| InboundMessageCount  | Number of inbound messages                                            |
| InboundMessageRate   | Number of inbound messages per second                                 |
| InboundBytesRate     | Volume of inbound bytes per second                                    |
| OutboundMessageCount | Number of outbound messages                                           |
| OutboundMessageRate  | Number of outbound messages per second                                |
| OutboundBytesRate    | Volume of outbound bytes per second                                   |


### Per-Queue Metrics

| Metric Name           | Description |
| :-------------------- | :---------- |
| ConsumerCount         | Number of consumers for this destination |
| ReceiverCount         | Number of active receivers on this queue |
| DeliveredMessageCount | Total number of messages that have been delivered to consumer applications but have not yet been acknowledged |
| PendingMessageCount   | Total number of pending messages for this destination |
| InTransitCount        | Total number of messages that have been delivered to the queue owner but have not yet been acknowledged |
| FlowControlMaxBytes   | Volume of pending messages (in bytes) at which flow control is enabled for this destination |
| PendingMessageSize    | Total size for all pending messages for this destination |
| MaxMsgs               | Maximum number of messages that the server will store for pending messages bound for this destination |
| MaxBytes              | Maximum number of message bytes that the server will store for pending messages bound for this destination |
| InboundByteRate       | Bytes received per second |
| InboundMessageRate    | Messages received per second |
| InboundByteCount      | Total number of bytes received |
| InboundMessageCount   | Total number of messages received |
| OutboundByteRate      | Bytes sent per second |
| OutboundMessageRate   | Messages sent per second |
| OutboundByteCount     | Total number of bytes sent |
| OutboundMessageCount  | Total number of messages sent |


## Caution

This monitor can potentially register hundred of new metrics, depending on how many queues are in EMS. By default, the Machine Agent will only report 200 metrics to the controller, so you may need to increase that limit when installing this monitor. To increase the metric limit, you must add a parameter when starting the Machine Agent, like this:

```bash
java -Dappdynamics.agent.maxMetrics=1000 -jar machineagent.jar
```

Please note that the maximum value you can provide is 5000.


## Support

For any questions or feature requests, please contact the [AppDynamics Center of Excellence][].

**Version:** 2.1.1  
**Controller Compatibility:** 3.6 or later  
**Last Updated:** 11/17/2013  
**Author:** Todd Radel  

------------------------------------------------------------------------------

## Release Notes

### Version 2.1.1
- Added inbound and outbound message/byte count and rate for each queue.
- General code cleanup.
- Re-released to AppSphere.

[Tibco EMS server]: http://www.tibco.com/products/automation/messaging/enterprise-messaging/enterprise-message-service/default.jsp
[AppDynamics Center of Excellence]: mailto:ace-request@appdynamics.com
[help@appdynamics.com]: mailto:help@appdynamics.com
