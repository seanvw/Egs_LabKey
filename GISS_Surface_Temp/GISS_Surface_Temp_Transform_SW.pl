#!/usr/local/bin/perl
use strict;
use warnings;
use Data::Dumper;
#
# seanvw@gmail.com
# modified script to allow development and testing outside of server


my $run_local = 1;
#my $run_local = 0;


#### start subs ###

sub get_files_for_processing {
	# just send the path and name of the runProperties.tsv file a single variable
	my $file = pop;
	open my $runPropsServer, $file or die "Can't open '$file'\n";
	
	my $transformFileName;
	my $dataFileName;
	
	my %transformFiles;

	while (my $line=<$runPropsServer>){
		#print $line;
   		chomp($line);
   		my @row = split(/\t/, $line);

   		if ($row[0] eq 'runDataFile'){
    		$dataFileName = $row[1];
			# transformed data location is stored in column 4
      		$transformFiles{$dataFileName} = $row[3];
   		}
	}
	close $runPropsServer;
	return(%transformFiles)
}


sub print_info_files {

	my %files = @_;
	while (my ($key, $value) = each(%files)) {
		print "Prepared for reading $key and writing $value\n";
	}

}

sub process_files {

	my %files = @_;
	my $monthDay = 0;

	while (my ($key, $value) = each(%files)) {

    	open my $dataFile, $key or die "Can't open '$key': $!";
    	open my $transformFile, '>', $value or die "Can't open '$value': $!";
    	
  		# header line
    	my $header2=<$dataFile>;
    	my $expected_header2 = join("\t",qw/Year Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec J-D D-N DJF MAM JJA SON/) . "\n";
    	unless ($header2 eq $expected_header2 ){
    		die "Header row 2:\n$header2\n does not match:\n" . $expected_header2 . "\n";
    	}
    	
    	my @header_new = qw/Year Month Date Anomoly_Celcius/;
    	my $header_new = join("\t",@header_new) . "\n";
    	print $transformFile  $header_new;
    	while (my $line=<$dataFile>){
			chomp($line);
			my @d = split /\t/, $line;
			my $year = $d[0];
			my $d;
			foreach my $j (1..12){
				my $month = $j;
				$month = "0" . $month if length($month) == 1;
				my $date = "$year-$month-01";
				my $anomoly = $d[$j];
				$d = join("\t",($year,$j,$date,$anomoly));
				if ($anomoly){
					print $transformFile "$d\n";	
				}

			}
    	}

    	close $dataFile;
   	 	close $transformFile;
	}


}

#### end subs ###


if ($run_local == 1){

	print "Running locally\n";
	my $file = 'runProperties_example_from_server.tsv';
	my %files = get_files_for_processing($file);
	# remember that the hash may contain multiple key-value pairs
	print "This is what we fetched:\n\n";
	print Dumper(\%files) . "\n\n";
	# we can see the values parsed from the test file but we running locally
	# so we change the key value 
	print "This is what we fake for local running:\n\n";
	
	# test file 1
	my $test_file_1 = '2024-05-29_14-27_tabledata_v4_GLB.Ts+dSST.tsv';
	my $test_file_2 = '2024-05-29_14-28_tabledata_v4_GLB.Ts+dSST.tsv';
	
	
	%files = (
		$test_file_1  =>  'NORM_' . $test_file_1,
		$test_file_2  =>  'NORM_' . $test_file_2
	);
	print Dumper(\%files) . "\n\n";
	print_info_files(%files);
	process_files(%files);
	
} else {
	
	# Running on server
	my %files = get_files_for_processing('${runInfo}');
	process_files(%files);


}
print "Done. See Yah!\n\n"
