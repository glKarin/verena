Qt.include("videourlparser.js");
Qt.include("youkuparser.js");
Qt.include("youkuparser_2017_05.js");
Qt.include("utility.js");

var vid, type, obj;
var streamtypes = [], parts = [];
var index = 0, index2 = 0;
var parser;

function loadSource(id, t, ob, s, p){
		index = 0;
		index2 = 0;
		streamtypes = s;
		parts = p;
    vid = id;
		type = t;
		obj = ob;
		if(streamtypes === undefined){
			streamtypes = [type];
		}
		if(parts === undefined){
			parts = [0];
        }

        if (type === "youku"){
            parser = new YoukuParser_2017_05();
         }else if (type === "youku_play"){
            parser = new YoukuParser(); // UNUSED not work
		}else{ 
			//support more sources in future?
			obj.addMsg("未支持的视频源：%1".arg(type));
			return;
		}

		if(type === "youku"){
			obj.addMsg("正在解析%1视频文件%2地址%3部分......".arg(parser.name).arg(streamtypes[index]).arg(parts[index2]));
			parser.start(vid, streamtypes[index], parts[index2]);
		}else{
			obj.addMsg("正在解析%1视频文件......".arg(parser.name));
			parser.start(vid);
		}
}

VideoParser.prototype.success = function(url){
	if(type === "youku"){
		obj.addMsg("已经取得%1视频文件%2地址%3部分......".arg(parser.name).arg(streamtypes[index]).arg(parts[index2]));
		obj.load(url, type, streamtypes[index], parts[index2], vid);
		index2++;
		if(index2 < parts.length){
			obj.addMsg("继续解析%1视频文件%2地址%3部分......".arg(type).arg(streamtypes[index]).arg(parts[index2]));
			parser.start(vid, streamtypes[index], parts[index2]);
		}
	}else{
		obj.addMsg("已经取得%1视频文件......".arg(parser.name));
		obj.load(url, type, streamtypes[index], parts[index2], vid);
	}
}

VideoParser.prototype.error = function(message){
	if(type === "youku"){
		obj.addMsg("解析%1视频文件%2地址%3部分失败......".arg(parser.name).arg(streamtypes[index]).arg(parts[index2]));
		index++;
		if(index < streamtypes.length){
			index2 = 0;
			obj.addMsg("重新解析%1视频文件%2地址%3部分......".arg(parser.name).arg(streamtypes[index]).arg(parts[index2]));
			parser.start(vid, streamtypes[index], parts[index2]);
		}
	}else{
		obj.addMsg("解析%1视频文件失败......".arg(parser.name));
	}
}

