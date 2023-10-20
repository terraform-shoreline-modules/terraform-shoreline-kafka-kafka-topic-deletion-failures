
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Kafka Topic Deletion Failures.
---

Kafka Topic Deletion Failures refer to situations where attempts to delete topics in the Kafka messaging system result in errors or failures. This can occur due to a variety of reasons, including configuration issues, permissions problems, or other system errors. When these failures occur, it can impact the overall performance and functionality of the Kafka system, potentially leading to data loss or other issues.

### Parameters
```shell
export PORT="PLACEHOLDER"

export TOPIC_NAME="PLACEHOLDER"

export ZOOKEEPER_SERVER="PLACEHOLDER"

export PATH_TO_KAFKA="PLACEHOLDER"

export KAFKA_SERVER="PLACEHOLDER"

export GROUP_NAME="PLACEHOLDER"
```

## Debug

### Check the status of the Kafka broker
```shell
systemctl status kafka
```

### Check if the topic exists
```shell
${PATH_TO_KAFKA}/bin/kafka-topics.sh --zookeeper ${ZOOKEEPER_SERVER}:${PORT} --describe --topic ${TOPIC_NAME}
```

### Check if the topic has any partitions
```shell
${PATH_TO_KAFKA}/bin/kafka-topics.sh --zookeeper ${ZOOKEEPER_SERVER}:${PORT} --describe --topic ${TOPIC_NAME} | grep "PartitionCount"
```

### Check if there are any active consumers for the topic
```shell
${PATH_TO_KAFKA}/bin/kafka-consumer-groups.sh --bootstrap-server ${KAFKA_SERVER}:${PORT} --describe --group ${GROUP_NAME}
```

### Check if there are any active producers for the topic
```shell
${PATH_TO_KAFKA}/bin/kafka-console-producer.sh --broker-list ${KAFKA_SERVER}:${PORT} --topic ${TOPIC_NAME}
```

### Check the logs for any errors related to the topic deletion
```shell
tail -f ${PATH_TO_KAFKA}/logs/server.log | grep "Error deleting topic"
```

## Repair

### Verify if the topic is configured with retention policy and if it is, disable it.
```shell


#!/bin/bash



# Set the topic name

topic=${TOPIC_NAME}



# Check if the topic has a retention policy set

retention=$(kafka-configs.sh --describe --entity-type topics --entity-name $topic --zookeeper ${ZOOKEEPER_HOST}:${ZOOKEEPER_PORT} | grep retention.ms)



if [ -n "$retention" ]; then

    # Disable the retention policy

    kafka-configs.sh --alter --entity-type topics --entity-name $topic --delete-config retention.ms --zookeeper ${ZOOKEEPER_HOST}:${ZOOKEEPER_PORT}

    echo "Retention policy disabled for topic $topic"

else

    echo "No retention policy found for topic $topic"

fi


```

### Check if there are any active consumers or producers for the Kafka topic and stop them.
```shell


#!/bin/bash



# Check if there are any active consumers or producers for the Kafka topic and stop them.



# Set the topic name

topic=${TOPIC_NAME}



# Stop all active consumers

for consumer in $(kafka-consumer-groups --bootstrap-server ${KAFKA_SERVER}:${PORT} --list | grep $topic); do

  kafka-consumer-groups --bootstrap-server ${KAFKA_SERVER}:${PORT} --group $consumer --topic $topic --reset-offsets --to-earliest --execute

done



# Stop all active producers

for producer in $(ps aux | grep kafka-producer | grep $topic | awk '{print $2}'); do

  kill -9 $producer

done



echo "All active consumers and producers for topic $topic have been stopped."


```