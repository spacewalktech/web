<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE HTML>
<html lang="en-US">

<head>
    <meta charset="UTF-8">
    <title>ueditor demo</title>
  	<script type="text/javascript" src="${root }/resources/js/syntaxhighlighter_3.0.83/scripts/shCore.js"></script>
  	<script type="text/javascript" src="${root }/resources/js/syntaxhighlighter_3.0.83/scripts/shBrushSql.js"></script>
  	<script type="text/javascript" src="${root }/resources/js/syntaxhighlighter_3.0.83/scripts/shBrushJava.js"></script>
 	<link type="text/css" rel="stylesheet" href="${root }/resources/js/syntaxhighlighter_3.0.83/styles/shCore.css"/>
 	<link type="text/css" rel="Stylesheet" href="${root }/resources/js/syntaxhighlighter_3.0.83/styles/shThemeDefault.css" /> 
 	<script type="text/javascript">SyntaxHighlighter.all();</script> 
 	<script type="text/javascript">
 	  function getContent() {
 	        var arr = [];
 	        arr.push(UE.getEditor('editor').getContent());
 	        alert(arr.join("\n"));
 	    }
 	</script>
</head>

<body>

	 <div style="width:99%"> 
            <form action="" method="post"> 
               	 标题：<input type="text" name="title" style="width:90%"/><br/> 
             	   内容： 
               		 <textarea id="container" name="content" type="text/plain">
							
               		 </textarea><br/><!--加载编辑器的容器--> 
               		 <input type="button" onclick="getContent()" value="预览" /> 
            </form> 
        </div> 
        <div>
	        <script type="syntaxhighlighter" class="brush: java;">
				class  Persson extends Object{private int i=1;  protected final static int AGE=10 
			   		public   void  sum(int a,int b) { 
			      	return a+b; 
			   		} 
			   		public  static  void main(string []  s){ 
			   		} 
				} 
			</script>
			 <input type="submit" value="编辑" /> 
			 <input type="submit" value="提交" /> 
        </div>
    <!-- 加载编辑器的容器 -->
    <script id="editor" class="brush: sql" name="editor" type="text/plain">
      
    </script>
    <!-- 配置文件 -->
    <script type="text/javascript" src="${root }/resources/js/ueditor1_4/ueditor.config.js"></script>
    <!-- 编辑器源码文件 -->
    <script type="text/javascript" src="${root }/resources/js/ueditor1_4/ueditor.all.js"></script>
    <script type="text/javascript" charset="utf-8" src="${root }/resources/js/ueditor1_4/lang/zh-cn/zh-cn.js"></script>
    <!-- 实例化编辑器 -->
    <!-- 实例化编辑器 --> 
<script type="text/javascript"> 
    var ue = UE.getEditor("container",{toolbars:[ 
        [ 
            //'anchor', //锚点 
            'undo', //撤销 
            'redo', //重做 
            'bold', //加粗 
            //'indent', //首行缩进 
            //'snapscreen', //截图（需要插件，一般不开）； 
            'italic', //斜体 
            'underline', //下划线 
            'strikethrough', //删除线 
            'subscript', //下标 
            //'fontborder', //字符边框 
            'superscript', //上标 
            //'formatmatch', //格式刷 
            //'source', //源代码 
            //'blockquote', //引用 
            //'pasteplain', //纯文本粘贴模式 
            'selectall', //全选 
            //'print', //打印 
            'preview', //预览 
            'horizontal', //分隔线 
            'removeformat', //清除格式 
            //'time', //时间 
            //'date', //日期 
            'unlink', //取消链接 
            //'insertrow', //前插入行 
            //'insertcol', //前插入列 
            //'mergeright', //右合并单元格 
            //'mergedown', //下合并单元格 
            //'deleterow', //删除行 
            //'deletecol', //删除列 
            //'splittorows', //拆分成行 
            //'splittocols', //拆分成列 
            //'splittocells', //完全拆分单元格 
            //'deletecaption', //删除表格标题 
            //'inserttitle', //插入标题 
            //'mergecells', //合并多个单元格 
            //'deletetable', //删除表格 
            //'cleardoc', //清空文档 
            //'insertparagraphbeforetable', //"表格前插入行" 
            'insertcode', //代码语言 
            'fontfamily', //字体 
            'fontsize', //字号 
            //'paragraph', //段落格式 
            'simpleupload', //单图上传 
            //'insertimage', //多图上传 
            //'edittable', //表格属性 
            //'edittd', //单元格属性 
            'link', //超链接 
            //'emotion', //表情 
            'spechars', //特殊字符 
            'searchreplace', //查询替换 
            //'map', //Baidu地图 
            //'gmap', //Google地图 
            //'insertvideo', //视频 
            //'help', //帮助 
            'justifyleft', //居左对齐 
            'justifyright', //居右对齐 
            'justifycenter', //居中对齐 
            'justifyjustify', //两端对齐 
            'forecolor', //字体颜色 
            //'backcolor', //背景色 
            //'insertorderedlist', //有序列表 
            //'insertunorderedlist', //无序列表 
            //'fullscreen', //全屏 
            //'directionalityltr', //从左向右输入 
            //'directionalityrtl', //从右向左输入 
            //'rowspacingtop', //段前距 
            //'rowspacingbottom', //段后距 
            //'pagebreak', //分页 
            //'insertframe', //插入Iframe 
            //'imagenone', //默认 
            //'imageleft', //左浮动 
            //'imageright', //右浮动 
            //'attachment', //附件 
            //'imagecenter', //居中 
            //'wordimage', //图片转存 
            //'lineheight', //行间距 
            //'edittip ', //编辑提示 
            //'customstyle', //自定义标题 
            //'autotypeset', //自动排版 
            //'webapp', //百度应用 
            //'touppercase', //字母大写 
            //'tolowercase', //字母小写 
            //'background', //背景 
            //'template', //模板 
            //'scrawl', //涂鸦 
            //'music', //音乐 
            //'inserttable', //插入表格 
            //'drafts', // 从草稿箱加载 
            //'charts', // 图表 
        ] 
    ]}); 
</script> 
</body>

</html>