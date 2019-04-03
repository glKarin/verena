Qt.include("networkengine.js")

var YoukuParser_new = function(){

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
				console.log(xhr.responseText);
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
		var req = new NetworkRequest("GET", ETAG_URL);
		req.sendRequest(function(text, cb, header){
			var utid = GetCna(text, header);
			var ts = (new Date().getTime() / 1000).toString();
			//var url = GETVIDEO_URL_FMT.arg(Youku_HandleVID(videoId)).arg(CCODE).arg(CLIENT_IP).arg(utid).arg(ts).arg(encodeURI(CKEY));

			var opt = {
				vid: videoId,
				ccode: CCODE,
				client_ip: CLIENT_IP,
				utid: utid,
				client_ts: ts,
				ckey: encodeURI(CKEY),
					//password: pwd,
			};
			var req = new NetworkRequest("GET", GETVIDEO_URL);
			req.addParameters(opt);
			req.sendRequest(
			//getJSONP(url, 
				function(obj){
				var stream = obj.data.stream;
				for(var s in stream)
				{
					if(stream[s].stream_type === type)
					{
						var url = stream[s].segs[part].cdn_url;
						if (url) {
							var link = YoukuRemakeCdnUrl(url);
							/*
								 var q = link.indexOf("?");
								 if(q !== -1)
								 link = link.substring(0, q);
								 */
							console.log("url -> " + link);
							play(link);
						} else {
							showStatusText("Not found!");
						}
						break;
					}
				}
			}); 
		}, function(e){
			showStatusText("Can not get utid.");
		});
	}

	function Youku_HandleVID(vid)
	{
		if(!vid)
			return vid;
		if(vid.length === 17 && vid.indexOf("==") === 15)
		{
			return vid.substring(0, 15);
		}
		return vid;
	}

	function query(url) {
		var pattern = /^https?:\/\/v.youku.com\/v_show\/id_([0-9a-zA-Z]+)(==|_.*)?\.html/;
		if (!url.match(pattern)) {
			showStatusText("Invalid url!");
			return;
		}
		var videoId = url.match(pattern)[1];
		fetch(videoId);
	}

	function play(videoUrl) {
		YoukuParser_new.prototype.success(videoUrl);
	}

	function showStatusText(text) {
		YoukuParser_new.prototype.error(text);
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

YoukuParser_new.prototype = new VideoParser();
YoukuParser_new.prototype.constructor = YoukuParser_new;
YoukuParser_new.prototype.name = "优酷";

