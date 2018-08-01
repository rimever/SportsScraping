
use strict;
use utf8;
use Encode qw/decode encode/;

my @loglist = glob "./soccerLog/*.log";
my $log_date;

my $prompt_in = 'UTF-8';
my $prompt_out = 'UTF-8';
my $file_in = 'UTF-8';

# 引数なしの場合
if (@ARGV == 0) {
	print join( "\n", @loglist ), "\n";
}else{
# 引数ありの場合
	foreach my $file(@loglist) {
		my $isPrintDate = 0;
	
		open(my $fh, '<', $file) or die ("Error: $!\n");
		my @target = <$fh>;
		
		close($fh);
		
		#デコードして取得
		my $word = decode($prompt_in,$ARGV[0]);
		
		#試合が下から上なので一度結果を配列に代入する
		my @out_list;
		
		
		foreach my $line(@target) {
			#ファイルはUTF-8
			my $en_line = decode($file_in,$line);
			
			#下から読み上げる必要がある
			
			if (0
				#|| $en_line =~ /^<td class="home">(.+)$word/ 
				#|| $en_line =~ /^<td class="away">(.+)$word/
				|| $en_line =~ /^<span class="goal">(.*)$word/) {
			
				if ($isPrintDate == 0)
				{
					$isPrintDate = 1;

					my $date = $file;
					$date =~ /^(.+)(\d{4})(\d{2})(\d{2})(\d{2})/;

					if ($log_date != $3.$4) {
						$log_date = $3.$4;
						my $log_month = $3;
						my $log_day = $4;
						$log_month =~ s/^0//;
						$log_day =~ s/^0//;
						
						$date = encode($prompt_out,$log_month."月".$log_day."日");
						print $date."\n";
					}
				}
			
				
				 #不要な末尾を取り除く
				 $en_line =~ s/<span class="goal">//;
				 $en_line =~ s/[(<\/span>)|(<br \/>)|(<\/td>)]//g;
				 
				 # 表示のためにデータを加工する
				 $en_line =~ /(.+)(【.+)([前|後]半.+)(】)/;
				 $en_line = $3.':'.$1."\n";
				 
				 unshift(@out_list,$en_line);
			}
		}
		foreach my $out_line(@out_list) {
			 			 # エンコードして出力する
				 print encode($prompt_out,$out_line);
		}
				
	}


}
