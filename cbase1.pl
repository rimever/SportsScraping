
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
			
			
			if ($en_line =~ /$word/) {
						
	 			 # エンコードして出力する
				 print encode($prompt_out,$en_line);
			}
		}
				
	}


}
