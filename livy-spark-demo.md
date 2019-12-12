# Calculating Potential Reach with Apache Spark

## What is Livy?
- Apache Spark REST Service
- Interactive sessions and batch processing using common HTTP methods (GET, POST, etc)
- Incubating project with the Apache Software Foundation

Additional Features (from Livy's webpage)
- Have long running Spark Contexts that can be used for multiple Spark jobs, by multiple clients
- Share cached RDDs or Dataframes across multiple jobs and clients
- Multiple Spark Contexts can be managed simultaneously, and the Spark Contexts run on the cluster (YARN/Mesos) instead of the Livy Server, for good fault tolerance and concurrency
- Ensure security via secure authenticated communication

## Interactively Query with Spark as your Engine
Livy interactive `sessions` work similarly to `spark-shell` or `pyspark`. Simply start the session and start submitting code snippets.  

### Start the `session`
Make a `POST` to Livy specifying some basic parameters:
1. such as the `session` `kind` (in this case `"kind": "pyspark"`), 
2. the `name` of your `session` so you can query that `session` later (`"name": "reachCalculation"`),
3. and any Python files (`pyFiles`) you'd like to be included in the `session` (`"pyFiles": ["/root/query/python/"]`).
4. and obviously the header (`"Content-Type: application/json"`), host name with port number (`localhost:8998`), and what type of workload you're running (i.e., `sessions` vs `batch`)

```
curl -X POST --data '{"kind": "pyspark", "name": "reachCalculation", "pyFiles": ["/root/query/python/"]}' -H "Content-Type: application/json" localhost:8998/sessions/
```

### Returning Basic Session Information
Submit a `GET` and specify the host name, port, the session name to return basic information about the Spark session.
```
curl -X GET localhost:8998/sessions/reachCalculation
```

### Submitting an Interactive Statement
Interactive statements (i.e., chunks of code) are submitted with a `POST` using `{"code": "<your code snippet(s) here>"}`. Each submitted statement is assigned an ID in the UI. In this example, Spark will read a CSV file of merchant transactions and return a record count.
```
curl -X POST --data '{"code": "from reach import reachcalculator as rc; rc.calculate_reach(rc.read_hdfs(\"/root/data/merchants.csv\"))"}' -H "Content-Type: application/json" localhost:8998/sessions/reachCalculation/statements
```

### Retrieving Query Results
Specify the session name and statement line (represented as an integer) to return the results.
```
curl -X GET localhost:8998/sessions/reachCalculation/statements/0
```

### Stopping the Session
When we want to stop the session, simply `DELETE` it.
```
curl -X DELETE localhost:8998/sessions/reachCalculation
```