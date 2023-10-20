

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