Qt.include("networkengine.js")

var YoukuParser_2017_05 = function(){

	var window = new Object();

	function getJSONP(url, callback) {
		var cbname = "cb" + (new Date()).getTime();
		url += "&callback=";
		url += cbname;
        console.log(url);

		window[cbname] = function(response) {
			callback(response);
		}

		var xhr = new XMLHttpRequest();
		xhr.onreadystatechange = function() {
			if (xhr.readyState == XMLHttpRequest.DONE) {
				//console.log(xhr.responseText);
				if (xhr.status == 200) {
					try {
						eval("window."+xhr.responseText);
					} finally {
						delete window[cbname];
					}
				} else {
					delete window[cbname];
				}
			}
		}

		xhr.open("GET", url);
		xhr.send();
	}

	function fetch(videoId, type, part) {
		var etag_url = "https://log.mmstat.com/eg.js";
		var req = new NetworkRequest("GET", etag_url);
		req.sendRequest(function(text, cb, header){
			var arr = header.split("\r\n");
			var utid;
			for(var i in arr)
			{
				var a = arr[i].split(": ");
				if(a[0] === "etag")
				{
					utid = a[1].split('"')[1];
                    var url = "https://ups.youku.com/ups/get.json?vid=%1&ccode=%2&client_ip=%3&utid=%4&client_ts=";
					var CCODE = "0501";
					var CLIENT_IP = "0.0.0.0";
					var ts = new Date().getTime();
                    url = url.arg(videoId).arg(CCODE).arg(CLIENT_IP).arg(utid);
                    url += ts;

					getJSONP(url, function(obj){
						var stream = obj.data.stream;
						for(var s in stream)
						{
                            if(stream[s].stream_type === type)
							{
								var url = stream[s].segs[part].cdn_url;
								getJSONP(url, function(res) {
									var link = res[0]["server"];
									if (link) {
										var q = link.indexOf("?");
                                        if(q !== -1)
											link = link.substring(0, q);
										console.log("url -> " + link);
										play(link);
									} else {
										showStatusText("Not found!");
									}
								});
							}
						}
					}); 
                    break;
				}
			}
		}, function(e){
			showStatusText("Can not get utid.");
		});
	}

	function query(url) {
		var pattern = /^http:\/\/v.youku.com\/v_show\/id_([0-9a-zA-Z]+)(==|_.*)?\.html/;
		if (!url.match(pattern)) {
			showStatusText("Invalid url!");
			return;
		}
		var videoId = url.match(pattern)[1];
		fetch(videoId);
	}

	function play(videoUrl) {
		YoukuParser_2017_05.prototype.success(videoUrl);
	}

	function showStatusText(text) {
		YoukuParser_2017_05.prototype.error(text);
	}

	this.start = function(vid, type, part){
		fetch(vid, type, part);
		/*
			 var typeMap = {
			 "flv": "flv", //普清
			 "mp4": "mp4", //高清
			 "flvhd2": "flv", //超清
			 "3gphd": "mp4", //高清
			 "3gp": "3gp", //普清
			 "flvhd3": "flv", //1080p原画
			 };
			 */
	}
};

YoukuParser_2017_05.prototype = new VideoParser();
YoukuParser_2017_05.prototype.constructor = YoukuParser_2017_05;
YoukuParser_2017_05.prototype.name = "优酷";

