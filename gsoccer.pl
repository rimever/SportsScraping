#!/usr/bin/perl
use strict;
use utf8;
use Encode qw/decode encode/;

use LWP::UserAgent;
use HTTP::Request;
use HTTP::Response;


my $promptOut = 'SJIS';
my $fileOut = 'UTF-8';

#ディレクトリを作成する
if (!-d "./soccerLog") {
	mkdir "./soccerLog";
}


#時間がかかるので開始宣言をする
my $start_time = time;
print encode($promptOut,"ログを取得開始\n");

my ($nowDay,$nowMonth,$nowYear) = (localtime(time))[3..5];

$nowYear += 1900;
$nowMonth += 1;

my $year = $nowYear;
my $month;
my $day;


for($month = 3; $month <= $nowMonth; $month++) {

	# 現在より先の日付ならループを抜ける
	if ($month > $nowMonth) { last; }

	for($day = 1; $day <= 31; $day++ ) {

		# 現在より先の日付ならループを抜ける
		if ($month == $nowMonth && $day > $nowDay) { last; }

		my $countGame;
		for ($countGame = 1; $countGame <= 9; $countGame++) {
					
			our $baseURL = 'http://www.nikkansports.com/soccer/jleague/j1/score/2013/';
			
			my $date = sprintf("%4d%02d%02d%02d",$year,$month,$day,$countGame);
			
			my $URL = $baseURL.$date.'.html'; # アクセスする URL
			
			# 既にファイルが存在（取得済みであれば行わなくて良い）
			my $file = 'soccerLog/'.$date.'.log';
			
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
					my $c_start = index($content,'<div id="topNewsArea"');
					my $c_end = index($content,'<div style="clear:both">',$c_start);
					
					my $content_body = substr($content,$c_start,$c_end-$c_start);
					
					# その中でまだ余計な箇所は取り除く
					#my $del_start = rindex($content_body,"<div class=\"yjSNLiveCommonsubtitle\">");
					#my $del_end = rindex($content_body,"</script>") + length("</script>");
					#substr($content_body,$del_start,$del_end - $del_start,"");
					
					
					#div id="wrapper"の中身を必要な部分とすり替える
					
					my $w_start = index($content,'<div id="wrapper">');
					my $w_end = index($content,"<iframe name=\"popIniframe");
					substr($content,$w_start,$w_end-$w_start
					, '<div id="wrapper"><div id ="contents"><div id="mainWrap"><div id ="main">'.$content_body."</div></div></div></div>");
					
					
					
					
					  
					#ファイルハンドルと文字列の間にカンマはいらない
					print $fh $content;
					
					close $fh or die qw/Can't close file "$file": $!/;
					
				    print encode($promptOut,'保存完了: '.$URL."\n");
				    				    
				} else {
				    print encode($promptOut,'HTTP エラーコード: ' . $res->code.' '.$URL."\n");
				    
				    #サッカーは日数が少なく、試合数が多いので404が出たらループは抜ける
				    last;
				}
			}
		}
	}
}
my $pass_time = time - $start_time;

print encode($promptOut,'ログ取得終了(実行時間 '.$pass_time.'sec)'); 
# HTML ヘッダ (CGI として動作できる)

1;