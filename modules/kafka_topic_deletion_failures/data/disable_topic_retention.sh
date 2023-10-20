

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