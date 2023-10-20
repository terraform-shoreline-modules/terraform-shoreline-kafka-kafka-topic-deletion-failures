resource "shoreline_notebook" "kafka_topic_deletion_failures" {
  name       = "kafka_topic_deletion_failures"
  data       = file("${path.module}/data/kafka_topic_deletion_failures.json")
  depends_on = [shoreline_action.invoke_disable_topic_retention,shoreline_action.invoke_stop_kafka_consumers_producers]
}

resource "shoreline_file" "disable_topic_retention" {
  name             = "disable_topic_retention"
  input_file       = "${path.module}/data/disable_topic_retention.sh"
  md5              = filemd5("${path.module}/data/disable_topic_retention.sh")
  description      = "Verify if the topic is configured with retention policy and if it is, disable it."
  destination_path = "/tmp/disable_topic_retention.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "stop_kafka_consumers_producers" {
  name             = "stop_kafka_consumers_producers"
  input_file       = "${path.module}/data/stop_kafka_consumers_producers.sh"
  md5              = filemd5("${path.module}/data/stop_kafka_consumers_producers.sh")
  description      = "Check if there are any active consumers or producers for the Kafka topic and stop them."
  destination_path = "/tmp/stop_kafka_consumers_producers.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_disable_topic_retention" {
  name        = "invoke_disable_topic_retention"
  description = "Verify if the topic is configured with retention policy and if it is, disable it."
  command     = "`chmod +x /tmp/disable_topic_retention.sh && /tmp/disable_topic_retention.sh`"
  params      = ["TOPIC_NAME"]
  file_deps   = ["disable_topic_retention"]
  enabled     = true
  depends_on  = [shoreline_file.disable_topic_retention]
}

resource "shoreline_action" "invoke_stop_kafka_consumers_producers" {
  name        = "invoke_stop_kafka_consumers_producers"
  description = "Check if there are any active consumers or producers for the Kafka topic and stop them."
  command     = "`chmod +x /tmp/stop_kafka_consumers_producers.sh && /tmp/stop_kafka_consumers_producers.sh`"
  params      = ["PORT","TOPIC_NAME","KAFKA_SERVER"]
  file_deps   = ["stop_kafka_consumers_producers"]
  enabled     = true
  depends_on  = [shoreline_file.stop_kafka_consumers_producers]
}

