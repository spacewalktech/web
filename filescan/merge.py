# -*- coding: utf-8 -*-：
# 合并上传完成的文件

import os
import time
import common.config.config as common_config
import common.dao.table_schema as tb_table_schema
from pyspark.sql import SparkSession
from pyspark.sql.types import *
from hdfs import *
import common.dao.import_tables as import_tables
import common.db.db_config as db
from common.util.util import CommandExecutor
from common.util.util import CommonUtil as common_util
from sqlalchemy import desc
import json

setting = None

env = common_util.getParam("env")

if env == "pro":
    setting = common_config.pro_path
else:
    setting = common_config.dev_path

# master 的地址
spark_master_ip = setting.get("spark_master_ip")

# warehouse的位置
spark_warehouse = setting.get("spark_warehouse")

# parquet文件的隐藏列
hidden_colum = "resvd_stage_id,resvd_flag,resvd_create_time,resvd_latest_update_time"

# 隐藏列数组
hidden_colum_array = ["resvd_stage_id", "resvd_flag", "resvd_create_time", "resvd_latest_update_time"]

# 存放parquet文件的地址
parquet_path = setting.get("parquet_path")


# 获取当前的时间
def get_time_format():
    return time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(time.time()))


# 获取hdfs上文件的大小
def get_hdfs_file_size(file_path):
    cmd_exec = CommandExecutor('/opt/spacewalk/hadoop/bin/hdfs', "dfs", "-du", "-h", file_path)
    output = cmd_exec.execute_output()
    outputs = output.split("\n")
    return outputs[0].split("  ")[0].replace(' ', '')


# 修改文件大小和记录书
def update_table_size(file_size, data_count, table_id):
    ImportTable = import_tables.ImportTable
    importtable = db.session.query(ImportTable).filter(ImportTable.id == table_id).first()
    importtable.size = file_size
    importtable.data_count = data_count
    db.session.commit()


# 将斜杠的日期转换为横杠的日期
def get_create_df_schema(table_id):
    TableSchema = tb_table_schema.TableSchema
    schema = db.session.query(TableSchema).filter_by(table_id=table_id).order_by(desc(TableSchema.id)).first()
    origin_schema = json.loads(schema.schema)
    tem_ary = []
    for s in origin_schema.get("schema"):
        t = s.get("type")
        if 'time' in t or 'date' in t:
            r = 'replace(' + str(s.get("name")) + ', '/', '-') as ' + str(s.get("name"))
            tem_ary.append(r)
        else:
            tem_ary.append(s.get("name"))
    return ",".join(tem_ary)


# 更新parquet文件
def merge(data_path, data_type, src_db, src_table, keys_array, schema_str, stage_id, table_id):
    print schema_str

    # 多个键位的联合主键
    union_key = "concat(" + ",_,".join(keys_array) + ") as union_key ,"
    print '--->table union_key is : ' + union_key
    # 用来记录更新的数据信息
    count_info = {}

    # 启动spark任务
    spark = SparkSession.builder.appName(" python merge table [ " + src_db + "_" + src_table + " ]").config("spark.master", spark_master_ip).config("spark.sql.warehouse.dir", "hdfs://hadoop01:9000/user/spark-with-hive/warehouse").getOrCreate()
    # 表的schema
    schema_string = schema_str + "," + hidden_colum

    # 构建DF的schema
    fields = [StructField(field_name, StringType(), False) for field_name in schema_str.split(",")]
    schema_df = StructType(fields)

    # hdfs的client
    client = Client('http://hadoop01:50070')

    # 全量更新
    if data_type == "full":

        # 如果是正式环境需要从hdfs上读取
        df = None
        print '-----------------开始全量更新--------------------' + get_time_format()

        # 对文件后缀的兼容
        file_names = os.listdir(data_path)
        print data_path
        suffix = ''
        for t in file_names:
            print t
            if 'data_full' in t and t.startswith('.') is False:
                suffix = t[t.rfind('.') + 1: len(t)]
                break

        # 将文件加载到hdfs上   /opt/spacewalk/data/orgin_file/test_db/test_table/processing/20170901_12_09_30
        hdfs_path = '/spacewalk/hdfs/orgin_file/' + src_db + '/' + src_table
        print suffix
        # 修改path，开始读取
        try:
            print '--->开始创建hdfs文件夹'
            client.makedirs(hdfs_path)
            print '--->开始上传源文件到hdfs目录'
            client.upload(hdfs_path, data_path)
            print '--->上传完成'
        except Exception as e:
            print '--->上传异常，开始采用覆盖模式'
            client.upload(hdfs_path, data_path, overwrite=True)
        # 读取数据
        print '--->开始读取hdfs上源文件'
        df = spark.read.format('csv').schema(schema_df).option("delimiter", "|").load(hdfs_path + data_path.split('processing')[1] + "/data_full." + suffix)
        # file_size = common_util.getFileSize( data_path + "/data_full." + suffix);
        file_size = get_hdfs_file_size(hdfs_path + data_path.split('processing')[1] + "/data_full." + suffix)
        print '--->文件大小为 : ' + file_size
        count = df.count()
        print '--->从hdfs上读取到的数据的记录数为 : ' + str(count)
        update_table_size(file_size, count, table_id)
        # 创建4个隐藏列
        print '--->开始创建隐藏列'
        hidden_cloum = [(stage_id, 0, get_time_format(), get_time_format())]
        hidden_df = spark.createDataFrame(hidden_cloum, hidden_colum_array)

        # 创建新的datafeame
        print '--->开始创建带有隐藏列的DataFrame'
        new_data = df.crossJoin(hidden_df)

        # 需要对列进行排序，不然会按照schema的字典顺序排列
        new_data.createOrReplaceTempView(src_db + "_" + src_table + "_temp")

        # schema_string 在这里将 时间类型的字段加上replace,将斜杠替换为横杠
        df_schema = get_create_df_schema(table_id)

        print df_schema

        new_schema_org_df = spark.sql("select " + schema_string + " from " + src_db + "_" + src_table + "_temp")

        # 写成parquet文件
        print "--->准备将DataFrame写成pqrquet文件,文件路径 : " + parquet_path + src_db + "/" + src_table + ".parquet"
        new_schema_org_df.write.format("parquet").mode("overwrite").save(parquet_path + src_db + "/" + src_table + ".parquet")
        print "--->准备将DataFrame写成json文件,文件路径 : " + parquet_path + src_db + "/" + src_table + ".json"
        new_schema_org_df.write.format("json").mode("overwrite").save(parquet_path + src_db + "/" + src_table + ".json")
        print '--->写成文件成功'
        # 删除hdfs临时目录
        client.delete('/spacewalk/hdfs/orgin_file/' + src_db + "/" + src_table, recursive=True)

        # 返回统计信息
        count_info["inserted_num"] = count
        count_info["record_num"] = count
        print '---------------------全量更新完成,全量更新数目 : ' + str(count) + '-----------------' + get_time_format()
        return count_info
    # 增量更新
    else:
        print '----------------开始进行增量更新-------------------' + get_time_format()
        # 加载原有parquet文件
        org_parquet_df = spark.read.load(parquet_path + src_db + "/" + src_table + ".parquet", format='parquet')
        total_num = org_parquet_df.count()
        print '--->源文件加载完毕,源文件记录数 ：' + str(org_parquet_df.count())
        # 创建表
        org_parquet_df.createOrReplaceTempView(src_db + "_" + src_table)

        # 创建带有唯一列的dataframe
        org_parquet_df = spark.sql(" select " + union_key + schema_string + " from " + src_db + "_" + src_table)

        # 修改和添加的 dataframe
        update_df = None

        # 用来记录变化的数据的主键，如果是联合的主键需要转化
        id_arry = []

        # 更新的数量
        update_count = 0

        # 添加的数量
        insert_count = 0
        print '--->开始创建隐藏列'
        # 构建额外的4个隐藏字段dataframe : resvd_stage_id,resvd_flag,resvd_create_time,resvd_latest_update_time
        hidden_cloum = [(stage_id, 0, get_time_format(), get_time_format())]
        hidden_df = spark.createDataFrame(hidden_cloum, hidden_colum_array)

        fields = [StructField(field_name, StringType(), False) for field_name in schema_str.split(",")]
        schema_df = StructType(fields)

        # 对文件后缀的兼容
        file_names = os.listdir(data_path)
        suffix = ''
        for t in file_names:
            if 'data_' in t:
                suffix = t[t.rfind('.') + 1: len(t)]
                break

        if os.path.exists(data_path + "/data_insert_updated." + suffix):
            print "--->开始增量更新"
            # 将文件加载到hdfs上   /opt/spacewalk/data/orgin_file/test_db/test_table/processing/20170901_12_09_30
            hdfs_path = '/spacewalk/hdfs/orgin_file/' + src_db + '/' + src_table
            # 修改path，开始读取
            try:
                print '--->开始创建hdfs目录'
                client.makedirs(hdfs_path)
                print '--->开始上传源数据文件到hdfs'
                client.upload(hdfs_path, data_path)
                print '--->上传完成'
            except Exception, e:
                print '--->上传异常,开始采用覆盖模式'
                client.upload(hdfs_path, data_path, overwrite=True)
            # 读取数据
            print '--->开始读取hdfs上的源文件'
            update_df = spark.read.format('csv').schema(schema_df).option("delimiter", "|").load(hdfs_path + data_path.split('processing')[1] + "/data_insert_updated." + suffix)

            # 总的数量
            update_insert_count = update_df.count()
            print '--->此次增量更新的数据总量为 : ' + str(update_insert_count)
            # 创建表
            update_df.createOrReplaceTempView(src_db + "_" + src_table + "_insert_update")

            # 创建带有唯一列的dataframe
            print '--->开始创建带有唯一列的DataFrame'
            update_df = spark.sql(" select " + union_key + schema_str + " from " + src_db + "_" + src_table + "_insert_update")

            # 构造逗号分割的主键串
            ids = update_df.select("union_key").collect()
            for delete_id in ids:
                id_arry.append("'" + str(delete_id.union_key) + "'")
            update_ids = ",".join(id_arry)

            # 查询在源数据里面的数据个数
            update_count = org_parquet_df.filter("union_key in (" + update_ids + ")").count()
            print '--->更新的数据数量 : ' + str(update_count)
            # 减去得到添加的数据个数
            insert_count = update_insert_count - update_count
            print '--->添加的数据数量 : ' + str(insert_count)
            # 构建带有隐藏列的df
            print '--->开始构建带有隐藏列的DataFrame'
            update_df = update_df.crossJoin(hidden_df)

        # 删除的 dataframe
        delete_df = None

        # 删除的数据的个数
        delete_count = 0

        # 构建额外的4个隐藏字段
        hidden_cloum = [(stage_id, 1, get_time_format(), get_time_format())]
        hidden_df = spark.createDataFrame(hidden_cloum, hidden_colum_array)

        # 有 data_deleted.txt 文件
        if os.path.exists(data_path + "/data_deleted." + suffix):
            print '--->开始删除的更新'
            # 将文件加载到hdfs上   /opt/spacewalk/data/orgin_file/test_db/test_table/processing/20170901_12_09_30
            hdfs_path = '/spacewalk/hdfs/orgin_file/' + src_db + '/' + src_table
            # 修改path，开始读取
            try:
                print '--->开始创建hdfs目录'
                client.makedirs(hdfs_path)
                print '--->开始上传删除数据的源文件到hdfs'
                client.upload(hdfs_path, data_path)
            except Exception, e:
                print '--->上传失败。开始覆盖操作'
                client.upload(hdfs_path, data_path, overwrite=True)
            # 读取数据
            print '--->开始加载源文件'
            delete_df = spark.read.format('csv').schema(schema_df).option("delimiter", "|").load(hdfs_path + data_path.split('processing')[1] + "/data_deleted." + suffix)

            # 构建多个unique的列
            delete_df.createOrReplaceTempView(src_db + "_" + src_table + "_delete")

            # 创建带有唯一列的dataframe
            print '--->开始创建带有唯一列的Dataframe'
            delete_df = spark.sql(" select " + union_key + schema_str + " from " + src_db + "_" + src_table + "_delete")

            # 删除的数据数量
            delete_count = delete_df.count()
            print '--->删除的数量 : ' + str(delete_count)
            # 将id主键放入变化数据数组
            ids = delete_df.select("union_key").collect()
            for delete_id in ids:
                id_arry.append("'" + delete_id.union_key + "'")

            # 构建带有隐藏列的df
            delete_df = delete_df.crossJoin(hidden_df)

        # 获取没有变化的源dataframe concat(newusercode) as union_key
        print '--->开始创建没有修改和删除记录的干净DataFrame'
        clean_org_df = org_parquet_df.filter("union_key not in (" + ",".join(id_arry) + ")")

        # 将修改的和删除的dataframe append到源数据dataframe上去
        end_df = clean_org_df
        print '--->开始将修改增加或删除的DataFrame union 在一起'
        if update_df is not None:
            end_df = end_df.union(update_df)

        if delete_df is not None:
            end_df = end_df.union(delete_df)

        # 写入到指定的文件位置
        end_df.createOrReplaceTempView(src_db + "_" + src_table + "_temp")
        new_schema_org_df = spark.sql("select " + schema_string + " from " + src_db + "_" + src_table + "_temp")

        print '--->开始将DataFrame写成temp文件'
        new_schema_org_df.write.format("parquet").mode("overwrite").save(parquet_path + src_db + "/" + src_table + "_temp.parquet")
        print '--->开始将DataFrame写成json文件'
        new_schema_org_df.write.format("json").mode("overwrite").save(parquet_path + src_db + "/" + src_table + ".json")

        # 删除hdfs上原有数据
        print '--->删除hdfs上原有的文件'
        client.delete('/spacewalk/hdfs/parquet_file/' + src_db + "/" + src_table + ".parquet", recursive=True)

        # 将temp文件改名为正式文件
        print '--->将temp文件命名为正式文件'
        client.rename('/spacewalk/hdfs/parquet_file/' + src_db + "/" + src_table + "_temp.parquet", '/spacewalk/hdfs/parquet_file/' + src_db + "/" + src_table + ".parquet")

        file_size = get_hdfs_file_size('/spacewalk/hdfs/parquet_file/' + src_db + "/" + src_table + ".parquet")
        print '--->文件大小为 : ' + file_size

        total_num = total_num + insert_count - delete_count

        update_table_size(file_size, total_num, table_id)

        # 返回统计信息
        count_info["inserted_num"] = insert_count
        count_info["updated_num"] = update_count
        count_info["deleted_num"] = delete_count
        count_info["record_num"] = insert_count + update_count + delete_count

        return count_info
