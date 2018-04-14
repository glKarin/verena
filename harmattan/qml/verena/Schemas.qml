import QtQuick 1.1
import "../js/main.js" as Script

QtObject{
	id:root;
	signal videoCategoryMapInitFinished(bool yes);
	signal showCategoryMapInitFinished(bool yes);
	signal playlistCategoryListInitFinished(bool yes);
	property variant videoCategoryMap:[];
	property variant showCategoryMap:[];
	property variant playlistCategoryList:ListModel{}
	property variant areaList:ListModel{}
	property variant periodList:ListModel{}
    property variant videoTagOrderbyList:["published", "view-count", "comment-count", "reference-count", "favorite-count", "relevance"];
	property variant videoSearchOrderbyList:["published", "view-count", "comment-count", "reference-count", "favorite-count", "relevance"];
	property variant videoCategoryOrderbyList:["published", "view-count", "comment-count", "reference-count", "favorite-time", "favorite-count"];
	property variant videoUserOrderbyList:["published", "view-count", "comment-count", "favorite-count"];
	property variant showSearchOrderbyList:["view-count", "view-today-count", "release-year"];
	property variant showCategoryOrderbyList:["view-count", "comment-count", "reference-count", "favorite-count", "view-today-count", "view-week-count", "release-date", "score", "updated"];
	property variant playlistOrderbyList:["published", "view-count"];

	property bool isInitVideoCategoryMap:false;
	property bool isInitShowCategoryMap:false;
	property bool isInitPlaylistCategoryList:false;

	signal initFinished;

	function init(){
		initVideoCategoryMap();
		initShowCategoryMap();
		initPlaylistCategoryList();
		periodList.clear();
		periodList.append({name: "today", value: "今日"});
		periodList.append({name: "week", value: "本周"});
		periodList.append({name: "month", value: "本月"});
		periodList.append({name: "history", value: "历史"});
		areaList.clear();
		areaList.append({value: "全部"});
		areaList.append({value: "美国"});
		areaList.append({value: "大陆"});
		areaList.append({value: "香港"});
		areaList.append({value: "日本"});
		areaList.append({value: "韩国"});
		areaList.append({value: "台湾"});
		areaList.append({value: "俄罗斯"});
		areaList.append({value: "英国"});
		areaList.append({value: "意大利"});
		areaList.append({value: "朝鲜"});
		areaList.append({value: "法国"});
		areaList.append({value: "泰国"});
		areaList.append({value: "加拿大"});
		areaList.append({value: "新加坡"});
		areaList.append({value: "印度"});
		areaList.append({value: "伊朗"});
		areaList.append({value: "澳大利亚"});
		areaList.append({value: "南斯拉夫"});
		areaList.append({value: "西班牙"});
		areaList.append({value: "新西兰"});
		areaList.append({value: "菲律宾"});
		areaList.append({value: "丹麦"});
		areaList.append({value: "捷克"});
		areaList.append({value: "瑞典"});
		areaList.append({value: "匈牙利"});
		areaList.append({value: "澳门"});
		areaList.append({value: "阿富汗"});
		areaList.append({value: "阿根廷"});
		areaList.append({value: "阿联酋"});
		areaList.append({value: "埃及"});
		areaList.append({value: "爱尔兰"});
		areaList.append({value: "奥地利"});
		areaList.append({value: "巴拉圭"});
		areaList.append({value: "巴勒斯坦"});
		areaList.append({value: "巴西"});
		areaList.append({value: "德国"});
		areaList.append({value: "保加利亚"});
		areaList.append({value: "比利时"});
		areaList.append({value: "冰岛"});
		areaList.append({value: "波黑"});
		areaList.append({value: "波兰"});
		areaList.append({value: "芬兰"});
		areaList.append({value: "哥伦比亚"});
		areaList.append({value: "格鲁吉亚"});
		areaList.append({value: "智利"});
		areaList.append({value: "古巴"});
		areaList.append({value: "荷兰"});
		areaList.append({value: "柬埔寨"});
		areaList.append({value: "克罗地亚"});
		areaList.append({value: "黎巴嫩"});
		areaList.append({value: "利比亚"});
		areaList.append({value: "卢森堡"});
		areaList.append({value: "罗马尼亚"});
		areaList.append({value: "越南"});
		areaList.append({value: "马来西亚"});
		areaList.append({value: "马其顿"});
		areaList.append({value: "蒙古"});
		areaList.append({value: "秘鲁"});
		areaList.append({value: "墨西哥"});
		areaList.append({value: "南非"});
		areaList.append({value: "尼日利亚"});
		areaList.append({value: "挪威"});
		areaList.append({value: "葡萄牙"});
		areaList.append({value: "瑞士"});
		areaList.append({value: "突尼斯"});
		areaList.append({value: "土耳其"});
		areaList.append({value: "乌拉圭"});
		areaList.append({value: "希腊"});
		areaList.append({value: "以色列"});
		areaList.append({value: "印度尼西亚"});
		areaList.append({value: "其他"});
		initFinished();
	}

	function initVideoCategoryMap(){
		isInitVideoCategoryMap = false;
		videoCategoryMap = [];
		function s(obj){
			if(!onFail(obj))
			{
				Script.makeVideoCategoryMap(obj);
				isInitVideoCategoryMap = true;
				root.videoCategoryMapInitFinished(true);
			}
			else
			{
				isInitVideoCategoryMap = false;
				root.videoCategoryMapInitFinished(false);
			}
		}
		function f(err){
			isInitVideoCategoryMap = false;
			root.videoCategoryMapInitFinished(false);
			setMsg(err);
		}
		Script.callNormalAPI("schemas_video_category", s, f);
	}
	function initShowCategoryMap(){
		isInitShowCategoryMap = false;
		showCategoryMap = [];
		function s(obj){
			if(!onFail(obj))
			{
				Script.makeShowCategoryMap(obj);
				isInitShowCategoryMap = true;
				root.showCategoryMapInitFinished(true);
			}
			else
			{
				isInitShowCategoryMap = false;
				root.showCategoryMapInitFinished(false);
			}
		}
		function f(err){
			isInitShowCategoryMap = false;
			root.showCategoryMapInitFinished(false);
			setMsg(err);
		}
		Script.callNormalAPI("schemas_show_category", s, f);
	}
	function initPlaylistCategoryList(){
		isInitPlaylistCategoryList = false;
		playlistCategoryList.clear();
		function s(obj){
			if(!onFail(obj))
			{
				Script.makePlaylistCategoryList(obj);
				isInitPlaylistCategoryList = true;
				root.playlistCategoryListInitFinished(true);
			}
			else
			{
				isInitPlaylistCategoryList = false;
				root.playlistCategoryListInitFinished(false);
			}
		}
		function f(err){
			isInitPlaylistCategoryList = false;
			root.playlistCategoryListInitFinished(false);
			setMsg(err);
		}
		Script.callNormalAPI("schemas_playlist_category", s, f);
	}
}
