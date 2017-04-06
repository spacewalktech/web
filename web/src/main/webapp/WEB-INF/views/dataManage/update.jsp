<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>添加任务</title>
<%@ include file="../header.jsp"%>

<script type="text/javascript">
	function doSubmit(){
		var data ={id:$("#id").val(),src_table:$("#src_table").val(),src_db:$("#src_db").val(),table_name:$("#table_name").val(),dbname:$("#dbname").val()};
		$.post("queryCountTable.do",data,function(msg){
			if(msg>0){
				layer.msg("表名重复，请重新输入", {
					  icon: 2
					}) 
			}else if(msg<0){
				layer.msg('表名或库名不能为空', {
					  icon: 2
					}) 
			}else{
				doSubmit_ready();
			}
		});
	}
	function doSubmit_ready(){
		$.post("update.do",$("#smartForm").serialize(),function(result){
			if (result == "error") {
			    layer.msg('添加失败！', {
				  icon: 2
				}) 
			}else{
			    layer.msg('添加成功！', {
				  icon: 1
				},function(){
					var index = parent.layer.getFrameIndex(window.name);
					parent.$('#task_list').bootstrapTable('refresh')
					parent.layer.close(index);
				})
			}
		});
		
	}
</script>
</head>
<body style='width: 99.5%'>
	<form class="smart-form" id="smartForm">
		<input id="id" name="id" type="hidden" value="${bloBs.id }">
		<fieldset>
			<div class="row">
				<section class="col col-1 text-right">
					<label class="text">源库</label>
				</section>
				<section class="col col-5"> 
					<label class="input">
						<input type="text" list="list_src_db"  id="src_db" name="src_db" value="${bloBs.src_db }"/> 
						<datalist id="list_src_db">
							<c:forEach var="i" items="${src_dbList}">
								<option value="${i}">${i }</option>
							</c:forEach>
						</datalist>
						<i></i>
					</label>
				</section>
				
				<section class="col col-1 text-right">
					<label class="text">源表</label>
				</section>
				<section class="col col-5"> 
					<label class="input"><input type="text" placeholder="表名" id="src_table" name="src_table" value="${bloBs.src_table }">
					</label>
				</section>
				
				<section class="col col-1 text-right">
					<label class="text">库名</label>
				</section>
				<section class="col col-5">
					<label class="input">
						<input type="text" list="list_dbname"  id="dbname" name="dbname" value="${bloBs.dbname }"/> 
						<datalist id="list_dbname">
							<c:forEach var="i" items="${dbList}">
								<option value="${i}">${i }</option>
							</c:forEach>
						</datalist>
						<i></i>
					</label>
				</section>
				
				<section class="col col-1 text-right">
				<label class="text">表名</label></section>
				<section class="col col-5">
				<label class="input"><input type="text" placeholder="表名" id="table_name" name="table_name" value="${bloBs.table_name }"/></label>
				</section>
				
				<section class="col col-1 text-right">
				<label class="text">源库类型</label></section>
				<section class="col col-5"> 
					<label class="select">
						<select id="src_db_type" name="src_db_type">
							<option value="Oracle" selected="${bloBs.src_db_type==Oracle}">Oracle</option>
							<option value="DB2" selected="${bloBs.src_db_type==DB2}">DB2</option>
							<option value="Sybase" selected="${bloBs.src_db_type==Sybase}">Sybase</option>
							<option value="SQL" selected="${bloBs.src_db_type==SQL}">SQL</option>
							<option value="Server" selected="${bloBs.src_db_type==Server}">Server</option>
							<option value="Informax" selected="${bloBs.src_db_type==Informax}">Informax</option>
							<option value="MySQL" selected="${bloBs.src_db_type==MySQL}">MySQL</option>
						</select> 
					</label> 
				</section>
				<section class="col col-1 text-right">
				<label class="text">是否激活</label></section>
				<section class="col col-5">
				
				<div class="inline-group">
						<label class="radio">
							<input type="radio" name="active" value="0" <c:if test='${bloBs.active == false }'>checked</c:if> >
							<i></i>
							是
						</label>
						<label class="radio">
							<input type="radio" name="active" value="1" <c:if test='${bloBs.active == true }'>checked</c:if> >
							<i></i>
							否
						</label>
					</div>
				</section>
			</div>
			<div class="row">
				<section class="col col-1 text-right">
				<label class="text">源库版本</label></section>
				<section class="col col-5">
				<label class="input"><input type="text" placeholder="源库版本"	id="src_db_version" name="src_db_version" value="${bloBs.src_db_version }"></label></section>

			</div>
		</fieldset>
		<footer>
		<button type="button" class="btn btn-primary" onclick="doSubmit()">确定</button>
		<button type="reset" class="btn btn-default">重置</button>
		</footer>
	</form>
</body>
</html>