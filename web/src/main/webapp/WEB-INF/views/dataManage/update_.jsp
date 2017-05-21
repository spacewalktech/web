<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
	<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>新建表</title>
<%@ include file="../header.jsp"%>
<script type="text/javascript">
	
	$(document).ready(function(){
		$("[name='export_to_es_index_warehouse']").bind('change',function(){
			var val =this.value
			$("#index_div").css('display',(val==0?'none':'block'));
		});
	});
	function doSubmit(){
		var src_keys =$("#src_keys").val();
		if(null == src_keys || src_keys.length == 0){
		    layer.msg("源表的unique键不能为空！")
		    return
		}
		var src_db = $("#src_db").val();
		var src_table = $("#src_table").val();
		if(src_db==null||src_db.length==0||src_table==null||src_table.length==0){
			layer.msg('源表名或源库名不能为空', {
				  icon: 2
				}) 
				return
		}
		
		var data ={id:$("#id").val(),table_name:$("#table_name").val(),dbname:$("#dbname").val()};
		$.post("queryCountTable",data,function(msg){
			if(msg>0){
				layer.msg("表名重复，请重新输入", {
					  icon: 2
					}) 
			}else if(msg<0){
				layer.msg('表名或库名不能为空', {
					  icon: 2
					}) 
			}else{
				submit_ready();
			}
		});
	}
	
	function submit_ready(){
		$.post("update",$("#smartForm").serialize(),function(result){
			if (result == "error") {
			    layer.msg('修改失败！', {
				  icon: 2
				}) 
			}else{
			    layer.msg('修改成功！', {
				  icon: 1
				},function(){
					var index = parent.layer.getFrameIndex(window.name);
					parent.$('#task_list').bootstrapTable('refresh');
					parent.layer.close(index);
				})
			}
		});
	}
	
	function canclepage(){
		
		var index = parent.layer.getFrameIndex(window.name);
		parent.layer.close(index);
	}
</script>
</head>
<body style='width: 99.5%'>
		<div id="content">
                    <form class="form-horizontal" id="smartForm">
						<input id="id" name="id" type="hidden" value="${bloBs.id }">
                     <fieldset>
		                <legend>库名/表名</legend>
                        <div class="form-group">
                        	 <label for="disabledSelect"  class="col-sm-2 control-label text-right">库名：</label>
                        	 <div class="col-sm-4">
									<input type="text" list="list_dbname"  id="dbname" name="dbname" class="form-control" value="${bloBs.dbname }"/> 
									<datalist id="list_dbname">
										<c:forEach var="i" items="${dbList}">
											<option value="${i}">${i }</option>
										</c:forEach>
									</datalist>
									<i></i>
							</div>
							<div class="col-sm-6 control-label text-left">
										<font color="red"><b>*</b></font>
									</div>
                        </div>
                        <div class="form-group">
                           <label for="disabledSelect"  class="col-sm-2 control-label text-right">表名：</label>
                           <div class="col-sm-4">
								<input type="text" placeholder="表名" id="table_name" name="table_name" class="form-control" value="${bloBs.table_name }">
                           </div>
                           <div class="col-sm-6 control-label text-left">
										<font color="red"><b>*</b></font>
									</div>
                        </div>
                        <div class="form-group">
                           <label for="disabledSelect"  class="col-sm-2 control-label text-right">描述信息：</label>
                           <div class="col-sm-8">
								<textarea class="form-control" rows="3"></textarea> 
                           </div>
                        </div>
                          <div class="col-sm-2 control-label text-left">
										<font color="red"><b> </b></font>
									</div>
                    </fieldset>
                     <fieldset>
                         <legend>源库/源表</legend>
                        <div class="form-group">
                           <label for="disabledSelect"  class="col-sm-2 control-label text-right">源库：</label>
                           <div class="col-sm-5">
									<input type="text" list="list_src_db"  id="src_db" name="src_db" class="form-control" value="${bloBs.src_db }" /> 
									<datalist id="list_src_db">
										<c:forEach var="i" items="${src_dbList}">
											<option value="${i}">${i }</option>
										</c:forEach>
									</datalist>
									<i></i>
                           </div>
                             <div class="col-sm-5 control-label text-left">
										<font color="red"><b>*</b></font>
									</div>
                        </div>
                        <div class="form-group">
                           <label for="disabledSelect"  class="col-sm-2 control-label text-right">源表：</label>
                           <div class="col-sm-5">
								<input class="form-control" type="text" placeholder="源表" id="src_table" name="src_table" value="${bloBs.src_table }">
                           </div>
                             <div class="col-sm-5 control-label text-left">
										<font color="red"><b>*</b></font>
									</div>
                        </div>
                        <div class="form-group">
							<label for="disabledSelect"  class="col-sm-2 control-label text-right">源库类型：</label>
							<div class="col-sm-5">
                              <select id="src_db_type" name="src_db_type" class="form-control">
										<option value="Oracle" <c:if test="${bloBs.src_db_type == 'Oracle'}">selected</c:if>>Oracle</option>
										<option value="Spark SQL" <c:if test="${bloBs.src_db_type == 'Spark SQL'}">selected</c:if>>Spark SQL</option>
										<option value="DB2" <c:if test="${bloBs.src_db_type == 'DB2'}">selected</c:if>>DB2</option>
										<option value="Sybase" <c:if test="${bloBs.src_db_type == 'Sybase'}">selected</c:if>>Sybase</option>
										<option value="Hive" <c:if test="${bloBs.src_db_type == 'Hive'}">selected</c:if>>Hive</option>
										<option value="SQL Server" <c:if test="${bloBs.src_db_type == 'SQL Server'}">selected</c:if>>SQL Server</option>
										<option value="Infomix" <c:if test="${bloBs.src_db_type == 'Infomix'}">selected</c:if>>Infomix</option>
										<option value="MySQL" <c:if test="${bloBs.src_db_type == 'MySQL'}">selected</c:if>">MySQL</option>
								</select> 
                           </div>
                           <div class="col-sm-5 control-label text-left">
										<font color="red"><b>*</b></font>
									</div>
                        </div>
                        <div class="form-group">
							<label for="disabledSelect"  class="col-sm-2 control-label text-right">源表的unique键：</label>
							<div class="col-sm-5">
								<input class="form-control" type="text" placeholder="源表的unique键，可能多个   key1;key2;" id="src_keys" name="src_keys" value="${bloBs.src_keys }">
                           </div>
                           <div class="col-sm-5 control-label text-left">
										<font color="red"><b>*</b></font>
									</div>
                        </div>
                         </fieldset>
                         <fieldset>
		                <legend>开关</legend>
		                	<div class="form-group">
								<label for="disabledSelect"  class="col-sm-2 control-label text-right">即席查询：</label>
				
								<div class="col-sm-2">
										<div class="checkbox-inline">
									        <label>
									            <input type="radio" name="export_to_sql_warehouse" value="1" <c:if test='${bloBs.export_to_sql_warehouse == true }'>checked</c:if>> 是
									        </label>
									    </div>
									    <div class="checkbox-inline">
									        <label>
									            <input type="radio" name="export_to_sql_warehouse" value="0" <c:if test='${bloBs.export_to_sql_warehouse == false }'>checked</c:if>> 否
									        </label>
									    </div>
									</div>
								<div class="col-sm-8 control-label text-left">
										<a href="">高级定义？</a>
									</div>
						   </div>
		                	<div class="form-group">
								<label for="disabledSelect"  class="col-sm-2 control-label text-right">全文检索：</label>
				
								<div class="col-sm-2">
										<div class="checkbox-inline">
									        <label>
									            <input type="radio" name="export_to_es_index_warehouse" value="1"  <c:if test='${bloBs.export_to_es_index_warehouse == true }'>checked</c:if>> 是
									        </label>
									    </div>
									    <div class="checkbox-inline">
									        <label>
									            <input type="radio" name="export_to_es_index_warehouse" value="0" <c:if test='${bloBs.export_to_es_index_warehouse == false }'>checked</c:if>> 否
									        </label>
									    </div>
									</div>
								<div class="col-sm-8 control-label text-left">
										<a href="">高级定义？</a>
									</div>
						   </div>
		                	<div class="form-group">
								<label for="disabledSelect"  class="col-sm-2 control-label text-right">是否激活：</label>
				
								<div class="col-sm-2">
										<div class="checkbox-inline">
									        <label>
									            <input type="radio" name="active" value="0" <c:if test='${bloBs.active == false }'>checked</c:if> > 是
									        </label>
									    </div>
									    <div class="checkbox-inline">
									        <label>
									            <input type="radio" name="active" value="1" <c:if test='${bloBs.active == true }'>checked</c:if> > 否
									        </label>
									    </div>
									</div>
									<div class="col-sm-8 control-label text-left">
										<a href="">高级定义？</a>
									</div>
						   </div>
		                </fieldset>
		                <div class="text-center">
							<button type="button" class="btn btn-primary"  onclick="doSubmit()">提交</button>
							<button type="button" class="btn btn-default" onclick="canclepage()">取消</button>
						</div>
                    </form>
                </div>       
</body>
</html>