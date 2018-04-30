#!/usr/bin/perl

use Spreadsheet::Read qw(ReadData); #Spreadsheet::ParseXLSX is needed
use Path::Tiny;

sub download_protein_scoring {
	my ($name, $pbd) = @_;
	my $uas = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/66.0.3359.139 Safari/537.36";
	my $url = "http://predictioncenter.org/casp12/results.cgi?dm_class=all&model=1&pc=&access_type=1&multi_sort=&groups_id=&target=" . $name . "-D1&targets_list=&result_id=&tr_type=all&order=&groups_list=&results=all&view=txt";
	my $protein_data = `curl -s -A "$uas" "$url"`;
	$protein_data =~ s/\n\s*/\n/g;
	$protein_data =~ s/\n$//g;
	path("SCORES/scores" . $pbd . ".csv")->spew($protein_data);
	print "File created in SCORES/scores" . $pbd . ".csv\n\n";
}

sub read_proteins {
	my ($file) = @_;
	my @rows = Spreadsheet::Read::rows($file->[1]);
	foreach my $i (1 .. scalar @rows) {
		print "Downloading Protein Data:\t";
		print my $name = $rows[$i][0];
		print "\t";
		print my $pbd = uc($rows[$i][1]);
		print "\n";
		download_protein_scoring($name, $pbd);
	}
}

BEGIN {
	my $file = ReadData('output.xlsx');
	read_proteins($file);
}