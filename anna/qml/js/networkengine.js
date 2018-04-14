.pragma library

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
}

NetworkRequest.prototype.addParameters = function(params){
	for (var i in params) this.parameters[i] = params[i];
}

NetworkRequest.prototype.sendRequest = function(onSuccess, onFailed){
	var xhr = new XMLHttpRequest();
	xhr.onreadystatechange = function(){
		if (xhr.readyState === xhr.DONE){
			if (xhr.status === 200 || xhr.status === 201){
				var res, callback;
                //console.log(xhr.responseText);
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
	}
	var p = this.encodedParams(), m = this.method;
	if (m === "GET" && p.length > 0){
		xhr.open("GET", this.url + "?" + p);
        //console.log(this.url + "?" + p);
	} else {
		xhr.open(m, this.url);
	}

	if (m === "POST"){
		xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        xhr.setRequestHeader("Content-Length", p.length);
		xhr.send(p);
	} else if (m === "GET"){
		xhr.send();
	}
}
