// 2019 load it every parser calling.
//k .pragma library

Qt.include("youku.js");
Qt.include("videourlparser.js");
Qt.include("youkuparser.js");
Qt.include("youkuparser_new.js");
Qt.include("utility.js");
/*
Qt.include("sinaparser.js");
Qt.include("tencentparser.js");
Qt.include("letvparser.js");
Qt.include("letvcloudparser.js");
*/

var vid, type, obj; // video id, video source, callback object
var streamtypes = [], parts = []; // video stream type, video part
var index = 0, index2 = 0; // current video stream type, current video part
var parser; // video parser object
var cb_data = null; // callback data

function loadSource(id, t, ob, s, p, data){
		index = 0;
		index2 = 0;
		streamtypes = s;
		parts = p;
    vid = id;
		type = t;
		obj = ob;
		cb_data = data;
		HandleData(data);

		if(streamtypes === undefined){
			streamtypes = [type];
		}
		if(parts === undefined){
			parts = [0];
        }

        if (type === "youku"){
            parser = new YoukuParser_new();
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
		obj.load(url, type, streamtypes[index], parts[index2], vid, cb_data);
		index2++;
		if(index2 < parts.length){
			obj.addMsg("继续解析%1视频文件%2地址%3部分......".arg(type).arg(streamtypes[index]).arg(parts[index2]));
			parser.start(vid, streamtypes[index], parts[index2]);
		}
	}else{
		obj.addMsg("已经取得%1视频文件......".arg(parser.name));
		obj.load(url, type, streamtypes[index], parts[index2], vid, cb_data);
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

// handle extra data
function HandleData(data)
{
	if(!data)
		return;
	if(!data.settings)
		return;
	var settings = data.settings;
	CCODE = settings["youku_ccode"];
	CLIENT_IP = settings["youku_client_ip"];
	CKEY = settings["youku_ckey"];
}
