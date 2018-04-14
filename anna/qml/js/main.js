.pragma library

Qt.include("networkengine.js")
Qt.include("utility.js")
Qt.include("openapi.js");
Qt.include("verenadatabase.js");

var schemas;
var vdb = new VerenaDatabase("Verena", "Verena Datebase", 5 * 1024 * 1024);

function init(s){
	schemas = s;
	vdb.createTable('KeywordHistory', '(keyword TEXT NOT NULL UNIQUE)');
	vdb.createTable('VideoCollection', '(vid TEXT NOT NULL UNIQUE, name TEXT, thumbnail TEXT,  collect_time TEXT, rank INTEGER)');
	vdb.createTable('ShowCollection', '(vid TEXT NOT NULL UNIQUE, name TEXT, thumbnail TEXT, collect_time TEXT, rank INTEGER)');
	vdb.createTable('PlaylistCollection', '(vid TEXT NOT NULL UNIQUE, name TEXT, thumbnail TEXT, collect_time TEXT, rank INTEGER)');
	vdb.createTable('UserCollection', '(vid TEXT NOT NULL UNIQUE, name TEXT, thumbnail TEXT, collect_time TEXT, rank INTEGER )');
}

function callNormalAPI(api, s, f){
	var request = new NetworkRequest("GET", OpenAPI[api]);
	request.sendRequest(s,f);
}

function callAPI(method, api, args, success, fail){
	var request = new NetworkRequest(method, OpenAPI[api]);
	var opt = ({});
	opt.client_id = Developer.client_id;
	for(var i in args){
		opt[i] = args[i];
	}
	request.addParameters(opt);
	request.sendRequest(success, fail);
}

function makeVideoCategoryMap(obj){
	var tmp = [];
	if(Array.isArray(obj.categories)){
		obj.categories.forEach(function(element){
			var genre = [];
			genre.push({value: "全部"});
			if(Array.isArray(element.genres)){
				element.genres.forEach(function(ge){
					genre.push({value: ge.label});
				});
			}
			var titem = {
				name: element.label,
				value: genre
			};
			tmp.push(titem);
		});
	}
	schemas.videoCategoryMap = tmp;
}

function makeShowCategoryMap(obj){
	var tmp = [];
	if(Array.isArray(obj.categories)){
		obj.categories.forEach(function(element){
			var genre = [];
			genre.push({value: "全部"});
			if(Array.isArray(element.genre)){
				element.genre.forEach(function(ge){
					genre.push({value: ge.label});
				});
			}
			var titem = {
				name: element.label,
				value: genre
			};
			tmp.push(titem);
		});
	}
	schemas.showCategoryMap = tmp;
}

function makePlaylistCategoryList(obj){
	if(Array.isArray(obj.category)){
		obj.category.forEach(function(element){
			schemas.playlistCategoryList.append({name:element.label});
		});
	}
}

function makeHomeCategoryVideoMap(object, model){
	var list = object.videos;
	var array = [];
	if(Array.isArray(list)){
		list.forEach(function(element){
			var item = {
				title: element.title,
				id: element.id,
				thumbnail: element.thumbnail
			};
			array.push(item);
		});
		model.append({videos: array});
	}
}

function makeVideoResultList(obj, model){
	if(Array.isArray(obj.videos)){
		obj.videos.forEach(function(element){
			var item = {
				title: element.title,
				id: element.id,
				thumbnail: element.thumbnail,
				published: element.published,
				view_count: element.view_count || -1
			};
			model.append(item);
		});
	}
}

function makeTopKeywordList(obj, model){
	if(Array.isArray(obj.keywords)){
		obj.keywords.forEach(function(element){
			model.append({keyword: element.keyword});
		});
	}
}

function makeShowResultList(obj, model){
	if(Array.isArray(obj.shows)){
		obj.shows.forEach(function(element){
			var item = {
				name: element.name,
				id: element.id,
				poster: element.poster,
				episode_count: element.episode_count,
				episode_updated: element.episode_updated,
				showcategory: element.showcategory,
				area: element.area,
				published: element.published,
				view_count: element.view_count,
				score: element.score
			};
			model.append(item);
		});
	}
}

function makeShowResultList_2(obj, model){
	if(Array.isArray(obj.shows)){
		obj.shows.forEach(function(element){
			var item = {
				name: element.name,
				id: element.id,
				last_play_video_id: getYoukuVideoIDFromLink(element.last_play_link || ""),
				poster: element.poster,
				episode_count: element.episode_count,
				episode_updated: element.episode_updated
			};
			model.append(item);
		});
	}
}

function makeVideoCommentList(obj, model, opt){
	if(Array.isArray(obj.comments)){
		obj.comments.forEach(function(element){
			var item = {
				content: element.content,
				username: element.user.name
			};
			model.append(item);
		});
	}
}

function makeVideoDetailList(obj, model){
	model.append({name: "用户", value: obj.user.name || ""});
	model.append({name: "发布时间", value: obj.published || ""});
	model.append({name: "分类", value: obj.category || ""});
	model.append({name: "时长", value: castMS2S(obj.duration * 1000) || 0});
	model.append({name: "播放数", value: obj.view_count || 0});
	model.append({name: "收藏数", value: obj.favorite_count || 0});
	model.append({name: "评论数", value: obj.comment_count || 0});
	model.append({name: "顶", value: obj.up_count || 0});
	model.append({name: "踩", value: obj.down_count || 0});
	model.append({name: "描述", value: obj.description || ""});
}

function makeUserDetailList(obj, model){
	model.append({name: "ID", value: obj.id || ""});
	model.append({name: "性别", value: castGender(obj.gender)});
	model.append({name: "注册时间", value: obj.regist_time});
	model.append({name: "粉丝", value: obj.followers_count});
	model.append({name: "关注", value: obj.following_count});
	model.append({name: "上传视频数", value: obj.videos_count});
	model.append({name: "上传专辑数", value: obj.playlists_count});
	model.append({name: "描述", value: obj.description});
}

function makeShowDetailList(obj, model){
	model.append({name: "分类", value: obj.category || ""});
	model.append({name: "类型", value: obj.genre || ""});
	model.append({name: "地区", value: obj.area || ""});
	model.append({name: "发布时间", value: obj.released || ""});
	model.append({name: "播放数", value: obj.view_count || 0});
	model.append({name: "评分", value: obj.score || 0.0});
	model.append({name: "集数", value: obj.episode_count || ""});
	model.append({name: "最后更新", value: obj.episode_updated || ""});
	model.append({name: "收藏数", value: obj.favorite_count || 0});
	model.append({name: "评论数", value: obj.comment_count || 0});
	model.append({name: "顶", value: obj.up_count || 0});
	model.append({name: "踩", value: obj.down_count || 0});
	model.append({name: "描述", value: obj.description || ""});
}

function makePlaylistResultList(obj, model){
	if(Array.isArray(obj.playlists)){
		obj.playlists.forEach(function(element){
			var item = {
				id: element.id,
				name: element.name,
				thumbnail: element.thumbnail,
				username: element.user.name,
				published: element.published,
				video_count: element.video_count
			};
			model.append(item);
		});
	}
}

function makePlaylistDetailList(obj, model){
	model.append({name: "上传用户", value: obj.user.name || ""});
	model.append({name: "发布时间", value: obj.published || ""});
	model.append({name: "视频数", value: obj.video_count || 0});
	model.append({name: "分类", value: obj.category || ""});
	model.append({name: "播放数", value: obj.view_count || 0});
	model.append({name: "描述", value: obj.description || ""});
}

function makePlaylistEpisodeList(obj, model, opt){
	if(Array.isArray(obj.videos)){
		obj.videos.forEach(function(element){
			var item = {
				title: element.title,
				id: getYoukuVideoIDFromLink(element.link || ""),
				thumbnail: element.thumbnail
			};
			model.append(item);
		});
	}
}

function getVideoStreamtypes(videoId, success, fail){
    //var url = "http://v.youku.com/player/getPlaylist/VideoIDS/" + videoId + "/Pf/4/ctype/12/ev/1?__";
    //var url = "http://play.youku.com/play/get.json?vid=" + videoId + "&ct=12";

    var xhr = new XMLHttpRequest();
    var etag_url = "https://log.mmstat.com/eg.js";
    var request = new NetworkRequest("GET", etag_url);
    function cna_s(json, cb, header)
    {
        var arr = header.split("\r\n");
        var utid;
        for(var i in arr)
        {
            var a = arr[i].split(": ");
            if(a[0] === "etag")
            {
                utid = a[1].split('"')[1];
                var url = "https://ups.youku.com/ups/get.json";
                var CCODE = "0501";
                var CLIENT_IP = "0.0.0.0";
                var opt = {
                    vid: videoId,
                    ccode: CCODE,
                    client_ip: CLIENT_IP,
                    utid: utid,
                    client_ts: new Date().getTime()
                };
                var req = new NetworkRequest("GET", url);
                req.addParameters(opt);
                req.sendRequest(success, fail);
                break;
            }
        }
    }
    function cna_f(err){
        setMsg("Can not get utid.");
        console.log(err);
    }
    request.sendRequest(cna_s, cna_f);
    //new YoukuParser().start("XNjM3ODMxNzA4", undefined, undefined);//chang
    //new YoukuParser().start("XMTI2MTk0NDA0NA", undefined, undefined);
}

function makeStreamtypes(obj, sort){
	var tmp = [];
	var stmp = [];
	if(obj.data){
		if(Array.isArray(obj.data.stream)){
			obj.data.stream.forEach(function(element){
					stmp.push(element.stream_type);
			});
			if(sort){
				stmp = sortStreamtypes(stmp);
			}
			stmp.forEach(function(element){
					var arr = [];
					obj.data.stream.forEach(function(e){
						if(e.stream_type === element){
                            for(var i = 0; i < e.segs.length; i++){// 2017.6
                                var item = {
                                    value: i,
                                    cdn_url: e.segs[i].cdn_url
                                };
                                arr.push(item);
                                // 2017.6
							}
						}
					});
					var item = {
						name: element,
						value: arr
					};
					tmp.push(item);
				});
			}
	}
	return tmp;
}

function makeStreamtypesModel(obj, model){
	if(obj.data){
		if(Array.isArray(obj.data.stream)){
			obj.data.stream.forEach(function(element){
				var type = element.stream_type;
				var arr = [];
				if(Array.isArray(element.segs)){
					for(var i = 0; i < element.segs.length; i++){
                        arr.push({title: type, name: i, cdn_url: element.segs[i].cdn_url});
					}
				}
				var item = {
					name: type,
					part: arr
				};
				model.append(item);
			});
		}
	}
}

function makeListModel(type, model){
	model.clear();
	vdb.loadToListModel(type, model);
}

function addCollection(type, item){
	vdb.pushElementToTable(type, item);
}

function removeCollection(type, name, id){
	vdb.deleteTableRows(type, name, "'" + id + "'");
}

function checkIsCollected(type, id){
	return vdb.queryTable(type, 'vid', "'" + id + "'");
}

function makeCollectionList(type){
	return vdb.loadToArray(type);
}

function clearTable(type){
	vdb.clearTable(type);
}

function getTableSize(type){
	return vdb.getTableSize(type);
}
/*
function getAcFunVideo(acId, success, fail){
	var request = new NetworkRequest("GET", "http://api.acfun.tv/apiserver/content/info?contentId=%1&version=2".arg(acId));
	request.sendRequest(success, fail);
}
*/

function errorCodeToCN(code)
{
    var cn = "其他错误";
    switch(code)
    {
        // 系统错误
        case 1001:	cn = "服务临时不可用"; break;
        case 1002:	cn = "服务数据出现异常"; break;
        case 1003:	cn = "IP限制访问"; break;
        case 1004:	cn = "客户ID为空"; break;
        case 1005:	cn = "客户ID无效"; break;
        case 1006:	cn = "无权限调用,需要高级别"; break;
        case 1007:	cn = "Access token为空"; break;
        case 1008:	cn = "Access token无效"; break;
        case 1009:	cn = "Access token过期,需刷新"; break;
        case 1010:	cn = "请求必须是POST方式"; break;
        case 1011:	cn = "不支持这种数据格式"; break;
        case 1012:	cn = "缺失必须参数"; break;
        case 1013:	cn = "无效的参数"; break;
        case 1014:	cn = "超出最大匹配限额"; break;
        case 1015:	cn = "无效的参数"; break;
        case 1016:	cn = "客户 SECRET 无效"; break;
        case 1017:	cn = "频率限制访问"; break;
        case 1018:	cn = "验证码无效"; break;
                                // 业务错误
        case 130011201:	cn = "缺失必须的参数"; break;
        case 130011202:	cn = "不支持的授权方式"; break;
        case 130011203:	cn = "授权服务器不支持的请求方式"; break;
        case 130011204:	cn = "不可预知的服务器异常"; break;
        case 130011205:	cn = "未授权此APP使用这种授权方式"; break;
        case 130011206:	cn = "资源所有者拒绝授权"; break;
        case 130011207:	cn = "Code或Refresh Code 无效，过期或者被删除,或者redirect_uri与服务端不匹配"; break;
        case 130011208:	cn = "Client_id与服务器的不匹配，或username/password不匹配"; break;
        case 130011209:	cn = "请求的scope无效"; break;
        case 130030051:	cn = "字数大于300(utf8)"; break;
        case 130030052:	cn = "含有不能提交级别的禁忌词"; break;
        case 130030053:	cn = "视频不存在"; break;
        case 130030054:	cn = "视频不允许评论"; break;
        case 130030055:	cn = "未付费用户不能评论收费视频"; break;
        case 130030102:	cn = "没有数据"; break;
        case 130030400:	cn = "评论内容不是有效的UTF8字符"; break;
        case 130030402:	cn = "视频不存在"; break;
        case 120020002:	cn = "无权限操作"; break;
        case 120020003:	cn = "视频已被推荐,不允许操作"; break;
        case 120020004:	cn = "更新失败"; break;
        case 120020005:	cn = "删除失败"; break;
        case 120020102:	cn = "标题最多能填写50个汉字"; break;
        case 120020103:	cn = "标题不可以只用数字表示，请补充或使用简洁明确的文字"; break;
        case 120020104:	cn = "标题含有网站禁止内容，请您更换其他标题"; break;
        case 120020122:	cn = "您定义的标签个数超过了10个，请删除标签个数"; break;
        case 120020123:	cn = "标签中含有敏感字符"; break;
        case 120020124:	cn = "单个标签最少2个字母"; break;
        case 120020125:	cn = "单个标签最多12个字母"; break;
        case 120020126:	cn = "单个标签最少2个汉字"; break;
        case 120020127:	cn = "单个标签最多6个汉字"; break;
        case 120020141:	cn = "描述信息含有网站禁止内容，请检查并重新提交"; break;
        case 120030001:	cn = "失败"; break;
        case 120030002:	cn = "异常"; break;
        case 120030100:	cn = "连接sphinx失败"; break;
        case 120030101:	cn = "连接sphinx失败"; break;
        case 120030102:	cn = "服务未找到"; break;
        case 120030103:	cn = "与服务对应的索引服务器未配置或配置格式有误"; break;
        case 120030200:	cn = "无效的ID"; break;
        case 120030206:	cn = "使用的范围查寻字段值不是数字"; break;
        case 120030207:	cn = "属性值有误，无法在枚举中找到该值"; break;
        case 120030302:	cn = "不能使用字段通配*号，只有在调试模式下才可用"; break;
        case 120040001:	cn = "专辑不存在"; break;
        case 120040002:	cn = "无权限操作"; break;
        case 120040003:	cn = "操作失败"; break;
        case 120040101:	cn = "标题能填写2-100个字符"; break;
        case 120040102:	cn = "标题含有网站禁止内容，请您更换其他标题"; break;
        case 120040103:	cn = "您定义的标签个数超过了10个，请删除标签个数"; break;
        case 120040104:	cn = "单个标签最少2个字母"; break;
        case 120040105:	cn = "单个标签最多12个字母"; break;
        case 120040106:	cn = "单个标签最少2个汉字"; break;
        case 120040107:	cn = "单个标签最多6个汉字"; break;
        case 120040108:	cn = "标签中含有敏感字符"; break;
        case 120040109:	cn = "描述信息含有网站禁止内容，请检查并重新提交"; break;
        case 120040110:	cn = "专辑视频超出了限制"; break;
        case 120010101:	cn = "标题不能为空"; break;
        case 120010102:	cn = "标题最多能填写50个汉字"; break;
        case 120010103:	cn = "频率限制访问"; break;
        case 120010104:	cn = "标题含有网站禁止内容，请您更换其他标题"; break;
        case 120010111:	cn = "此用户已经上传过该视频"; break;
        case 120010121:	cn = "标签不能为空"; break;
        case 120010122:	cn = "您定义的标签个数超过了10个，请删除标签个数"; break;
        case 120010123:	cn = "标签中含有敏感字符"; break;
        case 120010124:	cn = "单个标签最少2个字母"; break;
        case 120010125:	cn = "单个标签最多12个字母"; break;
        case 120010126:	cn = "单个标签最少2个汉字"; break;
        case 120010127:	cn = "单个标签最多6个汉字"; break;
        case 120010131:	cn = "分类不能为空"; break;
        case 120010132:	cn = "您选择的分类个数超过了1个，请减少分类选择个数"; break;
        case 120010141:	cn = "描述信息含有网站禁止内容，请检查并重新提交"; break;
        case 120010151:	cn = "上传任务无效"; break;
        case 120010152:	cn = "插入视频出错"; break;
        case 120010153:	cn = "更新扩展信息出错"; break;
    }
    return cn;
}

function errorTypeToCN(type)
{
    if(type === "SystemException")
        return "系统错误";
    else
        return "业务错误";
}

function checkError(json)
{
    if(json.error)
    {
        var res = {
            code: json.error.code,
            type: json.error.type,
            description: json.error.description,
            cn_type: errorTypeToCN(json.error.type),
            cn_description: errorCodeToCN(json.error.code)
        };
        return res;
    }
    return null;
}
