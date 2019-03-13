.pragma library

var AJAX_DEBUG_NONE = 0;
var AJAX_DEBUG_REQ_URL = 1;
var AJAX_DEBUG_RESP_CONTENT = 1 << 1;
var AJAX_DEBUG_RESP_HEADER = 1 << 2;
var AJAX_DEBUG_ALL = ~0;

var NetworkRequest = function (method, url){
	this.method = method;
	this.url = url;
	this.parameters = new Object();
	this.encodedParams = function(){
		var arga = [];
		for (var i in this.parameters){
			arga.push(i + "=" + encodeURIComponent(this.parameters[i]));
		}
		return arga.join("&");
	}
	this.dbg = AJAX_DEBUG_NONE;
	//this.dbg = AJAX_DEBUG_ALL;
}

NetworkRequest.prototype.addParameters = function(params){
	for (var i in params) this.parameters[i] = params[i];
}

NetworkRequest.prototype.sendRequest = function(onSuccess, onFailed){
	var xhr = new XMLHttpRequest();
	var self = this;
	xhr.onreadystatechange = function(){
		if (xhr.readyState === xhr.DONE){
			if (xhr.status === 200 || xhr.status === 201){
				var res, callback;
				if(self.dbg & AJAX_DEBUG_RESP_CONTENT)
					console.log(xhr.responseText);
				if(self.dbg & AJAX_DEBUG_RESP_HEADER)
					console.log(xhr.getAllResponseHeaders());
				try {
					res = JSON.parse(xhr.responseText);
					callback = "";
				} catch(e){
					try{
						var i = xhr.responseText.indexOf("(");
						var j = xhr.responseText.lastIndexOf(")");
						res = JSON.parse(xhr.responseText.substring(i + 1, j));
						callback = xhr.responseText.substring(0, i);
					}catch(e){
						res = xhr.responseText;
						callback = "";
					}
				}
				try {
					onSuccess(res, callback, xhr.getAllResponseHeaders());
				} catch(e){
					onFailed(JSON.stringify(e));
				}
			} else {
				onFailed(xhr.status);
			}
		}
	};
	var p = this.encodedParams(), m = this.method;
	if (m === "GET")
	{
		var u = this.url;
		if(p.length > 0)
			u += "?" + p;
		xhr.open("GET", u);
		if(this.dbg & AJAX_DEBUG_REQ_URL)
			console.log("[GET]: " + decodeURIComponent(u));
	} else {
		xhr.open(m, this.url);
		if(this.dbg & AJAX_DEBUG_REQ_URL);
			console.log("[POST]: " + this.url);
	}

	if (m === "POST"){
		xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
		xhr.setRequestHeader("Content-Length", p.length);
		xhr.send(p);
	} else if (m === "GET"){
		xhr.send();
	}
}
