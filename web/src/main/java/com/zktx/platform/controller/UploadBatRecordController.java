package com.zktx.platform.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.zktx.platform.entity.tb.UploadBatRecord;
import com.zktx.platform.log2.SystemControllerLog;
import com.zktx.platform.service.importtable.UploadBatRecordService;

@Controller
@RequestMapping("/uploadBatRecord")
public class UploadBatRecordController {

	@Autowired
	UploadBatRecordService service;

	@SystemControllerLog(description = "进入批量上传记录列表")
	@RequestMapping("/index")
	public String ToUploadRcord() {
		System.out.println("uploadRcord------");
		return "/unDataManage/uploadRecordList";
	}

	@SystemControllerLog(description = "查询批量上传记录列表")
	@RequestMapping("/queryList")
	public @ResponseBody Map<String, Object> queryList(Integer offset, Integer limit) {
		try {
			int count = service.queryCount();
			List<UploadBatRecord> list = service.queryList(offset, limit);
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("total", count);
			map.put("rows", list);
			return map;
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}
}
