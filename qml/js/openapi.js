.pragma library

var OpenAPI = {
	searches_video_by_keyword: "https://openapi.youku.com/v2/searches/video/by_keyword.json",
	//get
	//client_id keyword
	//orderby: published: 发布时间 view-count: 总播放数 favorite-count: 总收藏数 relevance: 相关度
	//streamtypes: 3GPHD-4
	//page count
	//id title link thumbnail

	videos_show: "https://openapi.youku.com/v2/videos/show.json",
	//get
	//client_id video_id

	searches_keyword_top: "https://openapi.youku.com/v2/searches/keyword/top.json",
		//get
		//client_id count period
		//keyword link search_count

	videos_by_category: "https://openapi.youku.com/v2/videos/by_category.json",
		//get
		//client_id
		//category  * 分类 综艺 娱乐 教育 旅游 时尚 母婴 资讯 原创 女性 搞笑 音乐 电影 电视剧 体育 游戏 动漫 广告 生活 汽车 科技 其他
		//orderby view-count() published comment-count favorite-count
		//page count

	shows_by_category: "https://openapi.youku.com/v2/shows/by_category.json",
		//get
		//client_id
		//category 电影,电视剧,动漫,综艺,资讯
		//genre 类型
		//area 地区
		//release_year 上映年
		//orderby view-count updated release-date favorite-count
		//streamtypes
		//page count

	shows_videos: "https://openapi.youku.com/v2/shows/videos.json",
		//get
		//client_id
		//show_id
		//show_videotype 正片 预告片 花絮 MV 资讯 首映式
		//show_videostage 1-10
		//#orderby
		//page count

	shows_show: "https://openapi.youku.com/v2/shows/show.json",
		//get
		//client_id
		//show_id

	searches_show_by_keyword: "https://openapi.youku.com/v2/searches/show/by_keyword.json",
		//get
		//client_id
		//keyword
		//unite=0
		//orderby view-count release-year view-today-count
		//hasvideotype 正片
		//page count

	comments_by_video: "https://openapi.youku.com/v2/comments/by_video.json",
		//get
		//client_id
		//video_id page count

	videos_by_related: "https://openapi.youku.com/v2/videos/by_related.json",
		//get
		//client_id
		//video_id count

	users_show: "https://openapi.youku.com/v2/users/show.json",
		//get
		//client_id
		//user_id user_name

	videos_by_user: "https://openapi.youku.com/v2/videos/by_user.json",
		//get
		//client_id
		//user_id user_name
		//orderby		 排序 published: 发布时间 view-count: 总播放数 comment-count: 总评论数 favorite-count: 总收藏数
		//page count

	playlists_by_category: "https://openapi.youku.com/v2/playlists/by_category.json",
		//client_id
		//category period today week month
		//orderby published view-count
		//page count

	playlists_show: "https://openapi.youku.com/v2/playlists/show.json",
		//client_id
		//playlist_id

	playlists_videos: "https://openapi.youku.com/v2/playlists/videos.json",
		//client_id
		//playlist_id page count

	searches_video_by_tag: "https://openapi.youku.com/v2/searches/video/by_tag.json",
		//get
		//client_id
		//tag ,
		//category period orderby page count

	playlists_by_user: "https://openapi.youku.com/v2/playlists/by_user.json",
		//get
		//client_id
		//user_id user_name
		//orderby published view-count
		//page count

	schemas_show_category: "https://openapi.youku.com/v2/schemas/show/category.json",
	schemas_video_category: "https://openapi.youku.com/v2/schemas/video/category.json",
	schemas_playlist_category: "https://openapi.youku.com/v2/schemas/playlist/category.json"
}

var Developer = {
	client_id: "9b1c79a4db7a9db3",
	client_secret: "1f84c32d144f684006450cbe644c71cb"
}

var OpenAPIURL_v3 = "https://openapi.youku.com/router/rest.json";
var OpenAPI_v3 = {
	comments_by_video_v3: "youku.content.comment.bycategory.get", // vid=&sid=F&pg=0&pl=30&top=false
	searches_keyword_top_v3: "youku.search.keyword.rankinglist", // mode=day/week/month&channel=综艺&limit=50(1-300)
	shows_videos_v3: "youku.api.video.byprogram.get", // show_id=&show_videotype=正片&show_videostage=F&order_by=show_videoseq:asc&page=PN(<1200)&pageLength=PS(<1200)
	search_keyword_get_v3: "youku.search.keyword.get", // keyword=(&noextra=0)
}
