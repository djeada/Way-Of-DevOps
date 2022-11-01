𝗠𝗟𝗢𝗽𝘀 𝗙𝘂𝗻𝗱𝗮𝗺𝗲𝗻𝘁𝗮𝗹𝘀 or 𝗪𝗵𝗮𝘁 𝗘𝘃𝗲𝗿𝘆 #MachineLearningEngineer 𝗦𝗵𝗼𝘂𝗹𝗱 𝗞𝗻𝗼𝘄. 

𝗠𝗼𝗱𝗲𝗹 𝗢𝗯𝘀𝗲𝗿𝘃𝗮𝗯𝗶𝗹𝗶𝘁𝘆 - 𝗥𝗲𝗮𝗹 𝗧𝗶𝗺𝗲.

Your Machine Learning Systems can fail in more ways than regular software. Machine Learning Observability System is where you will continuously monitor ML Application Health and Performance.
 
There are end-to-end platforms that try to provide all of the later described capabilities, we will look into how an in-house built system could look as the concepts will be fundamentally similar.

To provide a holistic view of your Machine Learning Model Health in Production - Observability System needs at least:
 
𝗢𝗽𝗲𝗿𝗮𝘁𝗶𝗼𝗻𝗮𝗹 𝗠𝗼𝗻𝗶𝘁𝗼𝗿𝗶𝗻𝗴:
 
➡️ Here you monitor regular software operational metrics. 
➡️ This would include response latency, inference latency of your ML Services, how many requests per second are made etc.
 
𝘌𝘹𝘢𝘮𝘱𝘭𝘦 𝘴𝘵𝘢𝘤𝘬:
 
👉 Prometheus for storing Metrics and alerting.
👉 Grafana mounted on Prometheus for exploring metrics.
 
𝗔𝗽𝗽𝗹𝗶𝗰𝗮𝘁𝗶𝗼𝗻 𝗟𝗼𝗴𝗴𝗶𝗻𝗴:
 
➡️ As in any regular software system you will need to collect your application logs centrally.
➡️ This would include errors, response codes, debug logs if there is a need to dig deeper.
 
𝘌𝘹𝘢𝘮𝘱𝘭𝘦 𝘴𝘵𝘢𝘤𝘬:
 
👉 fluentD Sidecars forwarding logs to ElasticSearch clusters.
👉 Kibana mounted on ElasticSearch for log search and exploration.
 
𝗔𝗻𝗮𝗹𝘆𝘁𝗶𝗰𝗮𝗹 𝗟𝗼𝗴𝘀:
 
This is a key area to Machine Learning Observability. You track Analytical Logs of your Applications - both Product Applications and your Machine Learning Service. These Logs will include application specific data like:
 
➡️ What prediction was made by ML Service.
➡️ What action was performed by the Product Application after receiving the Inference result.
➡️ What was the feature input to the ML Service.
➡️ …
 
➡️ Some of the features for inference will still be calculated on the fly due to latency requirements. Here you can identify any remaining Training/Serving Skew.
➡️ You will be able to monitor business related metrics. Click Through Rate, Revenue Per User etc.
➡️ You will catch any Data or Concept Drift happening within your online systems.
 
𝘌𝘹𝘢𝘮𝘱𝘭𝘦 𝘴𝘵𝘢𝘤𝘬:
 
👉 fluentD Sidecars forwarding logs to a Kafka Topic.
 
𝘉𝘢𝘵𝘤𝘩:
 
👉 Data is written to object storage and later to a Data Warehouse.
👉 A/B Testing Systems and BI Tooling are mounted on the Data Warehouse for Analytical purposes.
 
𝘙𝘦𝘢𝘭 𝘛𝘪𝘮𝘦:
 
👉 Flink Cluster reads Data from Kafka, performs windowed Transformations and Aggregations and either Alerts on thresholds or Forwards the data to Low Latency Read capable storage.

![1667289015227](https://user-images.githubusercontent.com/37275728/199279472-d0731019-cad6-4109-b9c5-78e858f38788.jpeg)

