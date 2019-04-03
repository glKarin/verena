.pragma library

function castMS2S(t) {
	var format = "mm:ss";
	if(t >= 3600000){
		return parseInt(t / 3600000) + ":" + Qt.formatTime(new Date(t % 3600000), format);
	}else{
		return Qt.formatTime(new Date(t % 3600000), format);
	}
}

function getYoukuVideoIDFromLink(url) {
	if(url){
        //var pattern = /^http:\/\/v.youku.com\/v_show\/id_([0-9a-zA-Z]+)(==|_.*)?\.html/;
		var pattern = /^https?:\/\/v.youku.com\/v_show\/id_([0-9a-zA-Z]+)(==|_.*)?\.html/;
		if (!url.match(pattern)) {
			return "";
		}
		var videoId = url.match(pattern)[1];
		return videoId;
	}else{
		return ""
	}
}

function castGender(g){
	if(g === "m"){
		return "男";
	}else if(g === "f"){
		return "女";
	}else{
		return "未知";
	}
}

function sortStreamtypes(arr){
	var tmp = [];
	if(arr.indexOf("3gphd") >= 0){
		tmp.push("3gphd");
	}
	if(arr.indexOf("flv") >= 0){
		tmp.push("flv");
	}
	if(arr.indexOf("mp4") >= 0){
		tmp.push("mp4");
	}
	if(arr.indexOf("mp4hd") >= 0){
		tmp.push("mp4hd");
	}
	if(arr.indexOf("flvhd") >= 0){
		tmp.push("flvhd");
	}
	/*
	if(arr.indexOf("3gp") >= 0){
		tmp.push("3gp");
	}
	*/
	if(arr.indexOf("mp4hd2") >= 0){
		tmp.push("mp4hd2");
	}
	if(arr.indexOf("mp4hd2v2") >= 0){
		tmp.push("mp4hd2v2");
	}
	if(arr.indexOf("hd2") >= 0){
		tmp.push("hd2");
	}
	if(arr.indexOf("hd2v2") >= 0){
		tmp.push("hd2v2");
	}
	if(arr.indexOf("mp4hd3") >= 0){
		tmp.push("mp4hd3");
	}
	if(arr.indexOf("mp4hd3v2") >= 0){
		tmp.push("mp4hd3v2");
	}
	if(arr.indexOf("hd3") >= 0){
		tmp.push("hd3");
	}
	if(arr.indexOf("hd3v2") >= 0){
		tmp.push("hd3v2");
	}
	return tmp;
}

function isFunction(func) {
	return typeof(func) === "function";
	/*
	try {
		if (typeof(eval(funcName)) == "function") {
			return true;
		}
	} catch(e) {}
	return false;
	*/
}

function FormatSize(i)
{
	var K_SIZE = 1024;
	var M_SIZE = 1048576;
	var G_SIZE = 1073741824;

	if(i >= 0 && i < K_SIZE)
		return "" + i + "B";
	else if(i >= K_SIZE && i < M_SIZE)
		return "%1K".arg(parseInt(i * 100 / K_SIZE) / 100);
	else if(i >= M_SIZE && i < G_SIZE)
		return "%1M".arg(parseInt(i * 100 / M_SIZE) / 100);
	else
		return "%1G".arg(parseInt(i * 100 / G_SIZE) / 100);
}
