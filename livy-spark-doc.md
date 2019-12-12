
# Employing Apache Livy for the Web-based Execution of Spark Applications

__Author:__ Matt Milunski | Slalom

## What is Livy?
- Incubating project with the Apache Software Foundation
- Apache Spark REST Service ("Spark from Anywhere")
- Interactive sessions and batch processing using common HTTP methods (GET, POST, etc)

### Additional Features (from Livy's webpage)
- Have long running Spark Contexts that can be used for multiple Spark jobs, by multiple clients
- Share cached RDDs or Dataframes across multiple jobs and clients
- Multiple Spark Contexts can be managed simultaneously, and the Spark Contexts run on the cluster (YARN/Mesos) instead of the Livy Server, for good fault tolerance and concurrency
- Ensure security via secure authenticated communication

## Interactively using Spark with Livy's REST API
- Livy interactive `sessions` work similarly to calling `spark-shell` or `pyspark` in the Terminal. 
- Simply start the session and start submitting code snippets.  

### Start the `session`
Make a `POST` to Livy specifying some basic parameters:
1. such as the `session` `kind` (in this case `"kind": "pyspark"`), 
2. the `name` of your `session` so you can query that `session` later (`"name": "reachCalculation"`),
3. and any Python files (`pyFiles`) you'd like to be included in the `session` (`"pyFiles": ["/root/query/python/"]`).
4. and obviously the header (`"Content-Type: application/json"`), host name with port number (`localhost:8998`), and what type of workload you're running (i.e., `sessions` vs `batch`)


```python
!curl -X POST \
--data '{"kind": "pyspark", "name": "reachCalculation", "pyFiles": ["/root/query/python/"]}' \
-H "Content-Type: application/json" \
localhost:8998/sessions/  
```

    {"id":0,"name":"reachCalculation","appId":null,"owner":null,"proxyUser":null,"state":"starting","kind":"pyspark","appInfo":{"driverLogUrl":null,"sparkUiUrl":null},"log":["stdout: ","\nstderr: "]}

### Returning Basic Session Information
Submit a `GET` and specify the host name, port, the session name to return basic information about the Spark session.


```python
!curl -X GET localhost:8998/sessions/reachCalculation
```

    {"id":0,"name":"reachCalculation","appId":null,"owner":null,"proxyUser":null,"state":"idle","kind":"pyspark","appInfo":{"driverLogUrl":null,"sparkUiUrl":null},"log":["19/11/05 22:00:50 INFO BlockManager: Using org.apache.spark.storage.RandomBlockReplicationPolicy for block replication policy","19/11/05 22:00:50 INFO BlockManagerMaster: Registering BlockManager BlockManagerId(driver, 172.17.0.2, 46013, None)","19/11/05 22:00:50 INFO BlockManagerMasterEndpoint: Registering block manager 172.17.0.2:46013 with 366.3 MB RAM, BlockManagerId(driver, 172.17.0.2, 46013, None)","19/11/05 22:00:50 INFO BlockManagerMaster: Registered BlockManager BlockManagerId(driver, 172.17.0.2, 46013, None)","19/11/05 22:00:50 INFO BlockManager: Initialized BlockManager: BlockManagerId(driver, 172.17.0.2, 46013, None)","19/11/05 22:00:51 INFO SparkEntries: Spark context finished initialization in 2500ms","19/11/05 22:00:51 INFO SharedState: Setting hive.metastore.warehouse.dir ('null') to the value of spark.sql.warehouse.dir ('file:/root/spark-warehouse').","19/11/05 22:00:51 INFO SharedState: Warehouse path is 'file:/root/spark-warehouse'.","19/11/05 22:00:52 INFO StateStoreCoordinatorRef: Registered StateStoreCoordinator endpoint","19/11/05 22:00:52 INFO SparkEntries: Created Spark session."]}

### Submitting an Interactive Statement
Interactive statements (i.e., chunks of code) are submitted with a `POST` using `{"code": "<your code snippet(s) here>"}`. Each submitted statement is assigned an ID in the UI. In this example, Spark will read a CSV file of merchant transactions and return a record count.


```python
!curl -X POST \
--data '{"code": "from reach import reachcalculator as rc; rc.calculate_reach(rc.read_hdfs(\"/root/data/merchants.csv\"))"}' \
-H "Content-Type: application/json" \
localhost:8998/sessions/reachCalculation/statements
```

    {"id":0,"code":"from reach import reachcalculator as rc; rc.calculate_reach(rc.read_hdfs(\"/root/data/merchants.csv\"))","state":"waiting","output":null,"progress":0.0}

### Retrieving Query Results
Specify the session name and statement line (represented as an integer) to return the results.


```python
!curl -X GET localhost:8998/sessions/reachCalculation/statements/0
```

    {"id":0,"code":"from reach import reachcalculator as rc; rc.calculate_reach(rc.read_hdfs(\"/root/data/merchants.csv\"))","state":"available","output":{"status":"ok","execution_count":0,"data":{"text/plain":"9128"}},"progress":1.0}

### Stopping the Session
When we want to stop the session, simply `DELETE` it.


```python
!curl -X DELETE localhost:8998/sessions/reachCalculation
```
