package com.zktx.platform.service.importtable;

import java.util.List;

import com.zktx.platform.entity.tb.ImportTablesPo;
import com.zktx.platform.entity.tb.ImportTablesWithBLOBs;

public interface ImportTableService {

	public List<ImportTablesWithBLOBs> findBySource(int source);
	
	public List<ImportTablesWithBLOBs> findByPagination(ImportTablesPo record , Integer fromRowId , Integer num);
	
	public int insertSelective(ImportTablesWithBLOBs record);
	
	public int updateByPrimaryKeySelective(ImportTablesWithBLOBs record);
	
	public int deleteByPrimaryKey(Integer id);
	
}
