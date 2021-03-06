# -*- coding: utf-8 -*-：

import os
import time
import common.config.config as common_config, common.util.util as common_util
from pyspark.sql import SparkSession
from pyspark.sql.types import *
from hdfs import *
from impala.dbapi import connect
from common.util.util import CommandExecutor, HDFSUtil, HiveUtil


# spark = SparkSession.builder.appName(" python test ").config("spark.master", "yarn").config("spark.sql.warehouse.dir", "hdfs://hadoop01:9000/user/spark-with-hive/warehouse").getOrCreate()
# schema_str = "usercode,username,comcodetype,companyname,comcode,manorgcode,manorgname,groupusercode,newusercode,idtypecode,idtypename,identifynumber,articlecode,phonenumber,faxnumber,mobilephone,email,postaddress,postcode,remark,tcol1,tcol2,tcol3,tcol4,tcol5,validstatus,flag,resvd_stage_id,resvd_flag,resvd_create_time,resvd_latest_update_time"
# fields = [StructField(field_name, StringType(), False) for field_name in schema_str.split(",")]
# schema_df = StructType(fields)
# df = spark.read.format('json').schema(schema_df).load("hdfs://hadoop01:9000/spacewalk/hdfs/parquet_file/spark/utiisales.json")
# df.filter("resvd_flag = 1").limit(10).show()
# df = spark.read.load('/spacewalk/hdfs/parquet_file/spark/utiisales.parquet')
# df.filter('resvd_flag = 1').show()
#client = Client('http://192.168.1.71:50070')
#client.download('/user/spark/lib/', '/Users/lzf/Movies/lib')
#spark = SparkSession.builder.appName("export data to spark").config("spark.master", "yarn").config("spark.sql.warehouse.dir", "hdfs://hadoop01:9000/user/spark-with-hive/warehouse").getOrCreate()
#df = spark.read.format('jdbc').option('url', 'jdbc:hive2://hadoop01:10001/lzf_test').option('dbtable', 'test_es').option("user", "hadoop").option("password", "hadoop").load()
#print '---'
#print df.count()
#print '---'
# while True:
#     print 1
#     time.sleep(3)

# conn = connect(host='hadoop01', port=10000, auth_mechanism='PLAIN')
# cur = conn.cursor()
# cur.execute('show databases')
# print cur.fetchall()

conn = connect(host='hadoop01', port=10001, auth_mechanism='PLAIN', user='hadoop', password='hadoop')
cur = conn.cursor()
cur.execute('show columns in ahpicc.prplwideclaim_1')

data = cur.fetchall()

for i in data:
    print str(i).replace('(','').replace(')','').replace(',','').replace('\'','')

#cmd_exec = CommandExecutor('/opt/spacewalk/hadoop/bin/hdfs', "dfs", "-du", "-h",'/bank.csv')
#output = cmd_exec.execute_output()
#outputs = output.split("\n")
#print outputs[0].split("  ")[0].replace(' ','')
