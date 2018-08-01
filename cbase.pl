
use strict;
use utf8;
use Encode qw/decode encode/;

my @loglist = glob "baseLog/*.log";
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
		
		foreach my $line(@target) {
			#ファイルはUTF-8
			my $en_line = decode($file_in,$line);
			
			
			if ($en_line =~ /^<li>(.+)$word/) {
			
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
			
				 $en_line =~ s/^<li>(.+)">(.+)">//;
				 #いくつかの文頭に対処
				 $en_line =~ s/^<li>(.+)">//;
				 $en_line =~ s/^<li>(.+)：//;
				 #不要な末尾を取り除く
				 $en_line =~ s/<\/a>//;
				 $en_line =~ s/<\/b>//;
				 $en_line =~ s/<\/li>//;
	 			 # エンコードして出力する
				 print encode($prompt_out,$en_line);
			}
		}
				
	}


}
