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
    //预警查询
    public List<Stage> queryStageByTableType(@Param("table_type") Integer table_type , @Param("status") Integer status);
    
}