package com.zktx.platform.dao.tb;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.zktx.platform.entity.tb.Stage;

public interface StageMapper {
	int deleteByPrimaryKey(Integer id);

	int insert(Stage record);

	int insertSelective(Stage record);

	Stage selectByPrimaryKey(Integer id);

	int updateByPrimaryKeySelective(Stage record);

	int updateByPrimaryKeyWithBLOBs(Stage record);

	int updateByPrimaryKey(Stage record);

	// 预警查询
	public List<Stage> queryStageByTableType(@Param("table_type") Integer table_type, @Param("offset") Integer offset, @Param("limit") Integer limit);

	public Integer queryCountByTableType(@Param("table_type") Integer table_type);

	public List<Stage> queryStageByTableId(@Param("import_table_id") Integer import_table_id, @Param("offset") Integer offset, @Param("limit") Integer limit);

	public Integer queryCountByTableId(@Param("import_table_id") Integer import_table_id);

	public List<Stage> queryStageList(@Param("offset") Integer offset, @Param("limit") Integer limit, @Param("tbid") Integer tbid);

	public int queryCount();
}