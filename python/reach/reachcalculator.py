# functions for reach calculation
from pyspark.sql import SparkSession

spark = SparkSession.builder.getOrCreate()
def read_hdfs(filepath, session=spark):
"""
Currently reads a CSV from the Docker image, but should be changed to read from HDFS.
Args:   filepath = a directory path specifying the file to load into Spark
        session = default is `spark`, but change it to whatever you named your SparkSession
Returns: A Spark DataFrame
"""
    spark = session
    hdfs_file = spark.read.format("csv")\
        .option("inferSchema", True)\
        .option("header", True)\
        .load(filepath)
    return hdfs_file

def calculate_reach(spark_df):
"""
Performs a row count on a Spark DataFrame
Args: a Spark DataFrame
Returns: an integer
"""
    return spark_df.count()


