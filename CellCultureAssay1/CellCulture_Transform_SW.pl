#!/usr/local/bin/perl
use strict;
use warnings;
use Data::Dumper;
#
# seanvw@gmail.com
# modified script to allow development and testing outside of server

# 
my $run_local ;

#$run_local = 1;
$run_local = 0;


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
    	my $header=<$dataFile>;
    	chomp($header);
    	$header =~ s/\r*//g;
    	print $transformFile $header, "\t", "MonthDay", "\n";

    	while (my $line=<$dataFile>){
       		#$monthDay = substr($line, 21, 2);
       		chomp($line);
       		$line =~ s/\r*//g;
       		my @f =  split(/\t/, $line);
       		my $date_time = $f[2];
       		# e.g. 2019-05-17 00:00
       		$monthDay = substr($date_time,8,2);
       		
       		print $transformFile $line, "\t", $monthDay, "\n";
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
	%files = ('runDataFile.tsv','runDataFile_out.tsv');
	print Dumper(\%files) . "\n\n";
	print_info_files(%files);
	process_files(%files);
	
} else {
	
	# Running on server
	my %files = get_files_for_processing('${runInfo}');
	process_files(%files);


}
print "Done. See Yah!\n\n"
