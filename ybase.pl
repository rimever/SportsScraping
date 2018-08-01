#!/usr/bin/perl
use strict;
use utf8;

use LWP::UserAgent;
use HTTP::Request;
use HTTP::Response;


#時間がかかるので開始宣言をする
my $start_time = time;
binmode(STDOUT, ":utf8");
print "ログを取得開始\n";

my ($nowDay,$nowMonth,$nowYear) = (localtime(time))[3..5];

$nowYear += 1900;
$nowMonth += 1;

#ログを入れるディレクトリを作成
if (!-d "baseLog") {
	mkdir "baseLog";
}

my $year = $nowYear;
my $month;
my $day;


for($month = 7; $month <= 7; $month++) {

	# 現在より先の日付ならループを抜ける
	if ($month > $nowMonth) { last; }

	for($day = 1; $day <= 31; $day++ ) {

		# 現在より先の日付ならループを抜ける
		if ($month == $nowMonth && $day > $nowDay) { last; }

		my $countGame;
		for ($countGame = 1; $countGame <= 6; $countGame++) {
					
			our $baseURL = 'http://baseball.yahoo.co.jp/npb/game/';
			
			my $date = sprintf("%4d%02d%02d%02d",$year,$month,$day,$countGame);
			
			my $URL = $baseURL.$date.'/text'; # アクセスする URL
			
			# ファイル名
			my $file = 'baseLog/'.$date.'.log';
			
			if (!(-f $file)) {

				my $proxy = new LWP::UserAgent;
				$proxy->agent('your own created browser name here'); # 任意
				$proxy->timeout(60); # 任意

				my $req = HTTP::Request->new('GET' => $URL);
				my $res = $proxy->request($req);
				my $content = $res->content;

				if($res->is_success) {
					#出力ではなくファイル新規書き込み
				    #print $content;
				    
				    #一度作成したものは二度も作る必要はない
					open my $fh, '>', $file
					  or die qq/Can't open file "$file" : $!/;
					
					#ファイルを編集
					
					
					# メインとなる部分だけを抜き出す
					my $c_start = index($content,"<div id=\"contents-body\"");
					my $c_end = index($content,"<div id=\"contents-footer\">");
					
					my $content_body = substr($content,$c_start,$c_end-$c_start);
					
					# その中でまだ余計な箇所は取り除く
					my $del_start = rindex($content_body,"<div class=\"yjSNLiveCommonsubtitle\">");
					my $del_end = rindex($content_body,"</script>") + length("</script>");
					substr($content_body,$del_start,$del_end - $del_start,"");
					
					
					#div id="wrapper"の中身を必要な部分とすり替える
					
					my $w_start = index($content,"<div id=\"wrapper\">");
					my $w_end = index($content,"<!-- Facebook -->");
					substr($content,$w_start,$w_end-$w_start, "<div id=\"wrapper\">".$content_body."</div>");
					
					
					
					
					  
					#ファイルハンドルと文字列の間にカンマはいらない
					print $fh $content;
					
					close $fh or die qw/Can't close file "$file": $!/;
					
				    print '保存完了: '.$URL."\n";
				    
				} else {
				    print 'HTTP エラーコード: ' . $res->code.' '.$URL."\n";
				}
			}
		}
	}
}
my $pass_time = time - $start_time;

print 'ログ取得終了(実行時間 '.$pass_time.'sec)'; # HTML ヘッダ (CGI として動作できる)

1;