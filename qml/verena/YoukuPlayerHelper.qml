import QtQuick 1.1
import "../js/main.js" as Script

QtObject{
	id: qobj;

	property string vid: "";
	property variant streamtypes: [];
	property variant playQueue: [];
	property string playType: "";
	property int playPart: 0;
	property string vtitle: "";
	/*
	property int playedSeconds: 0;
	property int totalDuration: 0;
	*/

	// get video url
	function getVideoUrl(vt, vp)
	{
		var type = vt === undefined ? playType : (Array.isArray(vt) ? vt[0] : vt)
		var part = vp === undefined ? playPart : (Array.isArray(vp) ? vp[0] : vp)
		for(var i = 0; i < streamtypes.length; i++)
		{
			if(streamtypes[i].name === type)
			{
				var url = streamtypes[i].value[playQueue.length ? playQueue[part] : part].url;
				return url;
			}
		}
		return false;
	}

	// set play type
	function setPlayQueue(ti, pi){
		if(streamtypes.length === 0) return;

		playType = streamtypes[ti].name;
		var tmp = [];
		streamtypes[ti].value.forEach(function(e){
			tmp.push(e.value);
		});
		playQueue = tmp;
		playPart = pi;
	}

	function setPlayQueueByName(type, part)
	{
		playType = type;
		playPart = 0;
		var tmp = [];
		for(var i = 0; i < streamtypes.length; i++){
			if(streamtypes[i].name === type){
				for(var j = 0; j < streamtypes[i].value.length; j++){
					tmp.push(streamtypes[i].value[j].value);
					if(streamtypes[i].value[j].value === part){
						playPart = j;
					}
				}
				break;
			}
		}
		playQueue = tmp;
	}

	// load player helper
	function loadHelper(t, p)
	{
		var index = 0, index2 = 0;
		var type_changed = false;

		for(var i in streamtypes){
			if(streamtypes[i].name === t){
				index = i;
				break;
			}
		}
		for(var j in streamtypes[index].value){
			if(streamtypes[index].value[j].value === p){
				index2 = j;
				break;
			}
		}
		if(playType !== streamtypes[index].name){
			playType = streamtypes[index].name;
			setPlayQueue(index, index2);
			type_changed = true;
		}else{
			playPart = index2;
		}
		var r = {
			index: index,
			index2: index2,
			type_changed: type_changed
		};
		return r;
	}

	// get streamtype array
	function getStreamtypesArray(obj, typemodel)
	{
		typemodel.clear();
		////symbian
		if(obj.data){
			vtitle = obj.data.video.title || "";
		}
		streamtypes = Script.makeStreamtypes(obj, true);
		streamtypes.forEach(function(element){
			typemodel.append({value: element.name});
		});
	}

	function getStreamtypesModel(obj, typemodel)
	{
		typemodel.clear();
		streamtypes = [];
		////symbian
		if(obj.data){
			vtitle = obj.data.video.title || "";
		}
		streamtypes = Script.makeStreamtypes(obj, true);
		Script.makeStreamtypesModel(obj, typemodel);
	}

	// play stop
	function stop()
	{
		playType = "";
		playPart = 0;
		playQueue = [];
	}

	// a part end
	function endOfMedia()
	{
		if(playPart < playQueue.length - 1){
			playPart ++;
			return 1;
		}else{
			return 0;
		}
	}

	// prev/next
	function playAPart(w)
	{
		if(w === constants.play_next){
			if(playPart < playQueue.length - 1){
				playPart ++;
				return 1;
			}else{
				return 2;
			}
		}else if(w === constants.play_prev){
			if(playPart > 0){
				playPart --;
				return -1;
			}else{
				return -2;
			}
		}
		return 0;
	}

	// get current index on streamtypes
	function changeType()
	{
		var index = 0, index2 = 0;
		for(var i in streamtypes){
			if(streamtypes[i].name === playType){
				index = i;
				break;
			}
		}
		for(var j in streamtypes[index].value){
			if(streamtypes[index].value[j].value === playPart){
				index2 = j;
				break;
			}
		}
		var r = {
			index: index,
			index2: index2
		};
		return r;
	}

	// get play part queue model
	function getPartModel(index, partmodel)
	{
		if(streamtypes.length === 0) return;

		partmodel.clear();
		streamtypes[index].value.forEach(function(element){
			partmodel.append({
				value: element.url.length ? element.value : "" + element.value + "*",
			});
		});
	}

	// set state to end
	function stopToEnd()
	{
		if(playQueue.length === 0) return;

		playPart = playQueue[playQueue.length - 1];
	}

	function reset()
	{
		stop();
		streamtypes = [];
		vtitle = "";
	}

	function getMilliseconds(type, p)
	{
		if(streamtypes.length === 0) return 0;

		var t = typeof(type) === "string" ? getTypeIndex(type) : type;
		var s = 0;
		var parts = streamtypes[t].value;
		var i;
		var part = p === undefined ? parts.length - 1 : p;
		for(i = 0; i < part + 1; i++)
		{
			s += parts[i].duration;
		}
		return Math.min(s, streamtypes[t].duration);
	}

	function getPartByMilliseconds(t, ms)
	{
		if(streamtypes.length === 0) return null;

		var type = typeof(t) === "string" ? getTypeIndex(t) : t;
		var d = streamtypes[type];
		if(ms > d.duration)
		{
			return null;
		}
		var cms = 0;
		var lms = 0;
		var i;
		for(i = 0; i < d.value.length; i++)
		{
			cms += d.value[i].duration;
			if(ms <= cms)
			{
				return({part: i, millisecond: ms - lms});
			}
			lms = cms;
		}
		return null;
	}

	function getTypeIndex(t)
	{
		var type = t === undefined ? playType : t;
		for(var i = 0; i < streamtypes.length; i++)
		{
			if(streamtypes[i].name === type)
			{
				return i;
			}
		}
	}

	function seekForAll(per)
	{
		if(streamtypes.length === 0) return null;

		var type = getTypeIndex();
		var ms = streamtypes[type].duration * per;
		//console.log(playType, type, ms);
		return getPartByMilliseconds(type, ms);
	}

}
