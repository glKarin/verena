<?php

function verena()
{
	function rand_ip()
	{
		return rand(50,250).".".rand(50,250).".".rand(50,250).".".rand(50,250);
	}

	function print_help()
	{
		header("HTTP/1.1 400 Bad Request");
		echo sprintf("Usage: %s/%s?url=%s&b=%s<br/>", $_SERVER["SERVER_NAME"] . ":" . $_SERVER["SERVER_PORT"], $_SERVER["PHP_SELF"], "[youku视频文件地址, 如果b参数不为0, 则需要把URL进行base64编码]", "[如果不为0, 则URL认为是base64编码]");
		exit;
	}

	$url = isset($_REQUEST["url"]) ? trim($_REQUEST["url"]) : "";
	if(empty($url))
	{
		echo "[ERROR]: Missing paramter -> url<br/>";
		print_help();
	}

	$b64 = isset($_REQUEST["b"]) ? intval($_REQUEST["b"]) : 0;
	$range = isset($_REQUEST["range"]) ? $_REQUEST["range"] : "";
	$ret_header = true;

	if($b64)
		$url = base64_decode($url);

	$curl = curl_init();

	$h = array(
		"Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", //                "Accept-Encoding: gzip, deflate, br",
		"Accept-Language: zh-CN,en-US;q=0.7,en;q=0.3",
		"User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.99 Safari/537.36",
		"HTTP_X_FORWARDED_FOR: " . rand_ip()
	);
	curl_setopt($curl, CURLOPT_URL, $url);
	curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);
	curl_setopt($curl, CURLOPT_HEADER, $ret_header);
	curl_setopt($curl, CURLOPT_FOLLOWLOCATION, true); // first url will rediect a real url
	curl_setopt($curl, CURLOPT_AUTOREFERER, true);
	if(strlen($range))
	{
		$h[] = "Range:" . $range;
	}
	curl_setopt($curl, CURLOPT_HTTPHEADER, $h);

	$r = curl_exec($curl);

	if($r === false)
	{
		echo sprintf("[ERROR]: cURL error -> %d [%s]<br/>", curl_errno($curl), curl_error($curl));
		print_help();
	}
	else
	{
		if($ret_header)
		{
			$header_size = curl_getinfo($curl, CURLINFO_HEADER_SIZE);
			$resp_header = substr($r, 0, $header_size);
			$resp_body = substr($r, $header_size);

			$header_arr = explode("\r\n", $resp_header);
			$status = array_shift($header_arr);
			foreach($header_arr as $value)
			{
				if(empty($value)) continue;

				header($value); 
			}
			echo $resp_body;
		}
		else
		{
			header("Content-Type: video/mp4");
			echo $r;
		}

		curl_close($curl);
	}
}

header("HTTP/1.1 200 OK");
header("Access-Control-Allow-Origin:*");
header("Content-type: text/html; charset=utf-8");
verena();

