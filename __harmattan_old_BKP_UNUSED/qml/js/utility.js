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
        var pattern = /^http:\/\/v.youku.com\/v_show\/id_([0-9a-zA-Z]+)(==|_.*)?\.html/;
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
	if(arr.indexOf("mp4hd3") >= 0){
		tmp.push("mp4hd3");
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

