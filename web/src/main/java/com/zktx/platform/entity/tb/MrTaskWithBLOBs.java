package com.zktx.platform.entity.tb;

public class MrTaskWithBLOBs extends MrTask {
    private String table_stage_info;

    private String triggle_tables;

    private String latest_running_info;

    public String getTable_stage_info() {
        return table_stage_info;
    }

    public void setTable_stage_info(String table_stage_info) {
        this.table_stage_info = table_stage_info;
    }

    public String getTriggle_tables() {
        return triggle_tables;
    }

    public void setTriggle_tables(String triggle_tables) {
        this.triggle_tables = triggle_tables;
    }

    public String getLatest_running_info() {
        return latest_running_info;
    }

    public void setLatest_running_info(String latest_running_info) {
        this.latest_running_info = latest_running_info;
    }
}