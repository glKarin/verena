.pragma library

var CCODE = "0521";
var CCODE_TUDOU = "0512";
var CLIENT_IP = "192.168.1.1";
var CKEY = "DIl58SLFxFNndSV1GFNnMQVYkx1PP5tKe1siZu/86PR1u/Wh1Ptd+WOZsHHWxysSfAOhNJpdVWsdVJNsfJ8Sxd8WKVvNfAS8aS8fAOzYARzPyPc3JvtnPHjTdKfESTdnuTW6ZPvk2pNDh4uFzotgdMEFkzQ5wZVXl2Pf1/Y6hLK0OnCNxBj3+nb0v72gZ6b0td+WOZsHHWxysSo/0y9D2K42SaB8Y/+aD2K42SaB8Y/+ahU+WOZsHcrxysooUeND";

var ETAG_URL = "https://log.mmstat.com/eg.js";
var GETVIDEO_URL = "https://ups.youku.com/ups/get.json";
var GETVIDEO_URL_FMT = "https://ups.youku.com/ups/get.json?vid=%1&ccode=%2&client_ip=%3&utid=%4&client_ts=%5&ckey=%6"; // &password=%7

var GETVIDEO_URL_FMT_2014 = "http://v.youku.com/player/getPlaylist/VideoIDS/%1/Pf/4/ctype/12/ev/1?__";
var GETVIDEO_URL_FMT_2016 = "http://play.youku.com/play/get.json?vid=%1&ct=12";

function GetCna(json, header)
{
	// find in response header
	var arr = header.split("\r\n");
	for(var i in arr)
	{
		var a = arr[i].split(": ");
		var etag = a[0].toLowerCase();
		if(etag === "etag")
		{
			var utid = a[1].split('"')[1];
			utid = encodeURI(utid);
			return utid;
		}
	}
	return false;
}

function YoukuRemakeCdnUrl(url_in)
{
	if(!url_in)
		return "";
	var dispatcher_url = "vali.cp31.ott.cibntv.net";
	if(url_in.indexOf(dispatcher_url) != -1)
		return url_in;
	else if(url_in.indexOf("k.youku.com") != -1)
		return url_in;
	else
	{
		var parts = url_in.split("://", 2);
		var parts_2 = parts[1].split("/");
		parts_2[0] = dispatcher_url;
		var url_out_2 = parts_2.join("/");
		return parts[0] + "://" + url_out_2;
	}
}
