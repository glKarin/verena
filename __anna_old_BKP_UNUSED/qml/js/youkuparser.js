var YoukuParser = function(){
    var sid;
    var token;
    var mk_a3 = 'b4et';
    var mk_a4 = 'boa4';
    var userCache_a1 = '4';
    var userCache_a2 = '1';
    var window = new Object();

    function getJSONP(url, callback) {
        var cbname = "cb" + (new Date()).getTime();
        url += ("&callback=" + cbname);

        window[cbname] = function(response) {
            callback(response);
        }

        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState == XMLHttpRequest.DONE) {
                //console.log(xhr.status);
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

    //general
    function L(a) {
        if (!a) return "";
        var a = a.toString(),
            c, b, f, e, g, h;
        f = a.length;
        b = 0;
        for (c = ""; b < f;) {
            e = a.charCodeAt(b++) & 255;
            if (b == f) {
                c += "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".charAt(e >> 2);
                c += "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".charAt((e & 3) << 4);
                c += "==";
                break
            }
            g = a.charCodeAt(b++);
            if (b == f) {
                c += "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".charAt(e >> 2);
                c += "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".charAt((e & 3) << 4 | (g & 240) >> 4);
                c += "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".charAt((g &
                            15) << 2);
                c += "=";
                break
            }
            h = a.charCodeAt(b++);
            c += "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".charAt(e >> 2);
            c += "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".charAt((e & 3) << 4 | (g & 240) >> 4);
            c += "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".charAt((g & 15) << 2 | (h & 192) >> 6);
            c += "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".charAt(h & 63)
        }
        return c
    }

    function Ha(b) {
        if (!b) {
            return "";
        }
        var b = b.toString(), d, c, g, l, f, h = [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 62, -1, -1, -1, 63, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -1, -1, -1, -1, -1, -1, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -1, -1, -1, -1, -1, -1, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -1, -1, -1, -1, -1];
        l = b.length;
        g = 0;
        for (f = ""; g < l; ) {
            do {
                d = h[b.charCodeAt(g++) & 255];
            } while (g < l && -1 == d);
            if (-1 == d) {
                break;
            }
            do {
                c = h[b.charCodeAt(g++) & 255];
            } while (g < l && -1 == c);
            if (-1 == c) {
                break;
            }
            f += String.fromCharCode(d << 2 | (c & 48) >> 4);
            do {
                d = b.charCodeAt(g++) & 255;
                if (61 == d) {
                    return f;
                }
                d = h[d];
            } while (g < l && -1 == d);
            if (-1 == d) {
                break;
            }
            f += String.fromCharCode((c & 15) << 4 | (d & 60) >> 2);
            do {
                c = b.charCodeAt(g++) & 255;
                if (61 == c) {
                    return f;
                }
                c = h[c];
            } while (g < l && -1 == c);
            if (-1 == c) {
                break;
            }
            f += String.fromCharCode((d & 3) << 6 | c);
        }
        return f;
    }

    function N(b, d) {
        for (var c = [], g = 0, l, f = "", h = 0; 256 > h; h++) {
            c[h] = h;
        }
        for (h = 0; 256 > h; h++) {
            g = (g + c[h] + b.charCodeAt(h % b.length)) % 256, l = c[h], c[h] = c[g], c[g] = l;
        }
        for (var m = g = h = 0; m < d.length; m++) {
            h = (h + 1) % 256, g = (g + c[h]) % 256, l = c[h], c[h] = c[g], c[g] = l, f += String.fromCharCode(d.charCodeAt(m) ^ c[(c[h] + c[g]) % 256]);
        }
        return f;
    }

    function O(b, d) {
        for (var c = [], g = 0; g < b.length; g++) {
            for (var l = 0, l = "a" <= b[g] && "z" >= b[g] ? b[g].charCodeAt(0) - 97 : b[g] - 0 + 26, f = 0; 36 > f; f++) {
                if (d[f] == l) {
                    l = f;
                    break;
                }
            }
            c[g] = 25 < l ? l - 26 : String.fromCharCode(l + 97);
        }
        return c.join("");
    }

    // get video data (la)
    function getFileId (b, c) {
        if (null == b || "" == b) {
            return "";
        }
        var e = b.slice(0, 8), g = c.toString(16);
        1 == g.length && (g = "0" + g);
        var g = g.toUpperCase(), l = b.slice(10, b.length);
        return e + g + l;
    }

    function isValidType (b) {
        return "3gphd" == b || "flv" == b || "flvhd" == b || "mp4hd" == b || "mp4hd2" == b || "mp4hd3" == b ? !0 : !1;
    }

    function convertType (b) {
        var c = b;
        switch (b) {
            case "m3u8":
                c = "mp4";
                break;
            case "3gphd":
                c = "3gphd";
                break;
            case "flv":
                c = "flv";
                break;
            case "flvhd":
                c = "flv";
                break;
            case "mp4hd":
                c = "mp4";
                break;
            case "mp4hd2":
                c = "hd2";
                break;
            case "mp4hd3":
                c = "hd3";
        }
        return c;
    }

    /*
     * b -> JSON.data
     * d -> JSON.data.stream (b.stream)
     * c -> video type
     * part -> video part
     */
    var la = function (b, d, c, part) {
        this._sid = sid;
        this._fileType = c;
        this._token = token;
        this._part = part;
        this._ip = b.security.ip;
        this._videoSegsDic = {};
        new ma;
        var c = [], g = [];
        g.streams = {};
        g.logos = {};
        g.typeArr = {};
        g.totalTime = {};
        for (var l = 0; l < d.length; l++) {
            for (var h = d[l].audio_lang, j = !1, m = 0; m < c.length; m++) {
                if (c[m] == h) {
                    j = !0;
                    break;
                }
            }
            j || c.push(h);
        }
        for (l = 0; l < c.length; l++) {
            for (var B = c[l], h = {}, j = {}, i = [], m = 0; m < d.length; m++) {
                var n = d[m];
                if (B == n.audio_lang && isValidType(n.stream_type) && n.stream_type == this._fileType) {
                    var q = convertType(n.stream_type), p = 0;
                    "none" != n.logo && (p = 1);
                    j[q] = p;
                    var o = !1, r;
                    for (r in i) {
                        q == i[r] && (o = !0);
                    }
                    o || i.push(q);
                    p = n.segs;
                    if (null != p) {
                        var t = [];
                        o && (t = h[q]);
                        var u = p[this._part];
                        if (null == u) {
                            break;
                        }
                        var s = {};
                        s.no = this._part;
                        s.size = u.size;
                        s.seconds = Number(u.total_milliseconds_video) / 1000;
                        s.milliseconds_video = Number(n.milliseconds_video) / 1000;
                        s.key = u.key;
                        s.fileId = getFileId(u.fileid/*n.stream_fileid 2016*/, this._part);
                        s.src = this.getVideoSrc(m, this._part, b, n.stream_type, s.fileId);
                        s.type = q;
                        t.push(s);
                        //console.log(t[0].src);
                        h[q] = t;
                    }
            m = langCodeToCN(B).key;
            g.logos[m] = j;
            g.streams[m] = h;
            g.typeArr[m] = i;
                    break;
                }
            }
        }
        this._videoSegsDic = g;
        this._videoSegsDic.lang = langCodeToCN(c[0]).key;
    }, ma = function (b) {
        this._randomSeed = b;
        this.cg_hun();
    };
    ma.prototype = {cg_hun:function () {
        this._cgStr = "";
        for (var b = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ/\\:._-1234567890", d = b.length, c = 0; c < d; c++) {
            var g = parseInt(this.ran() * b.length);
            this._cgStr += b.charAt(g);
            b = b.split(b.charAt(g)).join("");
        }
    }, cg_fun:function (b) {
        for (var b = b.split("*"), d = "", c = 0; c < b.length - 1; c++) {
            d += this._cgStr.charAt(b[c]);
        }
        return d;
    }, ran:function () {
        this._randomSeed = (211 * this._randomSeed + 30031) % 65536;
        return this._randomSeed / 65536;
    }};

    la.prototype = {
        getVideoSrc:function (b, d, e, g, l, h, j) {
            var m = e.stream[b];
            if (!e.video.encodeid || !g) {
                return "";
            }
            var b = {flv:0, flvhd:0, mp4:1, hd2:2, "3gphd":1, "3gp":0, "mp4hd2": 2, "mp4hd3": 2}[g], g = {flv:"flv", mp4:"mp4", hd2:"flv", mp4hd:"mp4", mp4hd2:"flv", "3gphd":"mp4", "3gp":"flv", flvhd:"flv", "mp4hd3": "flv"}[g], i = d.toString(16);
            1 == i.length && (i = "0" + i);
            var n = m.segs[d].total_milliseconds_video / 1000, d = m.segs[d].key;
            if ("" == d || -1 == d) {
                d = m.key2 + m.key1;
            }
            m = "";
            e.show && (m = e.show.pay ? "&ypremium=1" : "&ymovie=1");
            e = "/player/getFlvPath/sid/" + this._sid + "_" + i + "/st/" + g + "/fileid/" + l + "?K=" + d + "&hd=" + b + "&myp=0&ts=" + n + "&ypp=0" + m;
            l = encodeURIComponent(L(N(O(mk_a4 + "poz" + userCache_a2, [19, 1, 4, 7, 30, 14, 28, 8, 24, 17, 6, 35, 34, 16, 9, 10, 13, 22, 32, 29, 31, 21, 18, 3, 2, 23, 25, 27, 11, 20, 5, 15, 12, 0, 33, 26]).toString(), this._sid + "_" + l + "_" + this._token)));
            e = e + ("&ep=" + l) + "&ctype=12&ev=1" + ("&token=" + this._token);
            e += "&oip=" + this._ip;
            return "http://k.youku.com" + (e + ((h ? "/password/" + h : "") + (j ? j : "")));
        }};

    function langCodeToCN(a) {
        var b = "";
        switch (a) {
            case "default":
                b = {
                    key: "guoyu",
                    value: "国语"
                };
                break;
            case "guoyu":
                b = {
                    key: "guoyu",
                    value: "国语"
                };
                break;
            case "yue":
                b = {
                    key: "yue",
                    value: "粤语"
                };
                break;
            case "chuan":
                b = {
                    key: "chuan",
                    value: "川话"
                };
                break;
            case "tai":
                b = {
                    key: "tai",
                    value: "台湾"
                };
                break;
            case "min":
                b = {
                    key: "min",
                    value: "闽南"
                };
                break;
            case "en":
                b = {
                    key: "en",
                    value: "英语"
                };
                break;
            case "ja":
                b = {
                    key: "ja",
                    value: "日语"
                };
                break;
            case "kr":
                b = {
                    key: "kr",
                    value: "韩语"
                };
                break;
            case "in":
                b = {
                    key: "in",
                    value: "印度"
                };
                break;
            case "ru":
                b = {
                    key: "ru",
                    value: "俄语"
                };
                break;
            case "fr":
                b = {
                    key: "fr",
                    value: "法语"
                };
                break;
            case "de":
                b = {
                    key: "de",
                    value: "德语"
                };
                break;
            case "it":
                b = {
                    key: "it",
                    value: "意语"
                };
                break;
            case "es":
                b = {
                    key: "es",
                    value: "西语"
                };
                break;
            case "po":
                b = {
                    key: "po",
                    value: "葡语"
                };
                break;
            case "th":
                b = {
                    key: "th",
                    value: "泰语"
                }
        }
        return b
    }

    // a = t._videoSegsDic.streams map key -> lang
    function findLang(a) {
        var b = "";
        for(var l in a)
        {
            switch (l) {
                case "default":
                    b = "guoyu"
                    break;
                case "guoyu":
                    b = "guoyu";
                    break;
                case "yue":
                    b = "yue";
                    break;
                case "chuan":
                    b = "chuan";
                    break;
                case "tai":
                    b = "tai";
                    break;
                case "min":
                    b = "min";
                    break;
                case "en":
                    b = "en";
                    break;
                case "ja":
                    b = "ja";
                    break;
                case "kr":
                    b = "kr";
                    break;
                case "in":
                    b = "in";
                    break;
                case "ru":
                    b = "ru";
                    break;
                case "fr":
                    b = "fr";
                    break;
                case "de":
                    b = "de";
                    break;
                case "it":
                    b = "it";
                    break;
                case "es":
                    b = "es";
                    break;
                case "po":
                    b = "po";
                    break;
                case "th":
                    b = "th";
                    break;
            }
            if(b !== "")
                break;
        }
        return b
    }

    function fetch(videoId, type, part) {
        getJSONP('http://play.youku.com/play/get.json?vid=' + videoId + '&ct=12',
                function(res){
                    var a = res['data'];
                    var c = N(O(mk_a3 + "o0b" + userCache_a1, [19, 1, 4, 7, 30, 14, 28, 8, 24, 17, 6, 35, 34, 16, 9, 10, 13, 22, 32, 29, 31, 21, 18, 3, 2, 23, 25, 27, 11, 20, 5, 15, 12, 0, 33, 26]).toString(), Ha(a.security.encrypt_string));
                    c     = c.split("_");
                    sid   = c[0];
                    token = c[1];
                    var t = new la(a, a.stream, type, part);
                         //['标清', t._videoSegsDic.streams['guoyu']['3gphd'][0].src]
                    //console.log(type + "__" + part);
                    //console.log(findLang(t._videoSegsDic.streams));
                    getJSONP(t._videoSegsDic.streams[findLang(t._videoSegsDic.streams)][convertType(type)][0].src, function(res){
                        var link = res[0]["server"];
                        if (link) {
                            //console.log(type);
                            console.log("url -> " + link);
                            play(link);
                        } else {
                            showStatusText("Not found!");
                        }
                    });
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
            YoukuParser.prototype.success(videoUrl);
        }

        function showStatusText(text) {
            YoukuParser.prototype.error(text);
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

    YoukuParser.prototype = new VideoParser();
    YoukuParser.prototype.constructor = YoukuParser;
    YoukuParser.prototype.name = "优酷";
