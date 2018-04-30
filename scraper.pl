#!/usr/bin/perl

use HTML::TableExtract;
use Excel::Writer::XLSX;

my @pbds;
my $work_book;
my $xl_file;
my $xl_row_count;

BEGIN {
	$work_book = Excel::Writer::XLSX->new("output.xlsx");
	$xl_file = $work_book->add_worksheet();
	$xl_row_count = 1;
	# adds headers to the XL file
	$xl_file->write(0, 0, "Protein Name");
	$xl_file->write(0, 1, "Protein PBD");
	$xl_file->write(0, 2, "Species");
	$xl_file->write(0, 3, "Classification");
	$xl_file->write(0, 4, "Total Residue Count");
	$xl_file->write(0, 5, "Total Atom Amount");
	$xl_file->write(0, 6, "Total Structure Weight");
	$xl_file->write(0, 7, "Global Symmetry");
	$xl_file->write(0, 8, "Unique Protein Chains");
	$xl_file->write(0, 9, "FASTA Chain(s)");
	#$work_book->close;
}

sub write_data_to_excel {
	my ($name, $pbd, $classification, $species, $residue_count, $atom_count, $structure_weight, $global_symmetry, $unique_protein_chains, $fasta) = @_;
	my $col_count = 0;
	foreach my $write_item (@_) {
		$xl_file->write($xl_row_count, $col_count, $write_item);
		$col_count++;
	}
	$xl_row_count++;
}

sub get_depth_on_protein {
	my ($name, $pbd) = @_;
	my $url = "https://www.rcsb.org/structure/";
	my $uas = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/66.0.3359.139 Safari/537.36";
	my $webpage_data = `curl -s -A "$uas" "$url$pbd" -L`;
	print "Name: " . $name . "\n";
	print "PBD: " . $pbd . "\n";
	my ($classification) = ($webpage_data =~ /<li id="header_classification"><\w+>\w+\W&nbsp<\w \w+="\w+" href="[\w|\/|\.|\?|=|&|;| ]+">([\w| ]+)/);
	print "Classification: " . $classification . "\n";
	my ($species) = ($webpage_data =~ /<li id="header_organism"><\w+>\w+\(s\)\:&nbsp<\/\w+><a \w+="\w+" \w+="[\w|\/|\.|\?|=|&|;| ]+">([\w| ]+)/);
	print "Species: " . $species . "\n";
	my ($residue_count) = ($webpage_data =~ /id="contentResidueCount">Residue Count: ([\w]+)/);
	print "Total Reside Count: " . $residue_count . "\n";
	my ($atom_count) = ($webpage_data =~ /id="contentAtomSiteCount">Atom Count: ([\w]+)/);
	print "Total Atom Count: " . $atom_count . "\n";
	my ($structure_weight) = ($webpage_data =~ /id="contentStructureWeight">Total Structure Weight: ([\w]+)/);
	print "Total Structure Weight: " . $structure_weight . "\n";
	my ($global_symmetry) = ($webpage_data =~ /<strong>Global Symmetry<\/strong>: ([\w| |-]+)&/);
	print "Global Symmetry: " . $global_symmetry . "\n";
	my ($unique_protein_chains) = ($webpage_data =~ /id="contentProteinChainCount">Unique protein chains: ([\w]+)/);
	print "Unique Protein Chains: " . $unique_protein_chains . "\n";
	# there are multiple FASTFA chains. get all of em.
	my $url;
	my @fasta_datas;
	for my $i (1 .. $unique_protein_chains) {
		$url = "https://www.rcsb.org/pdb/download/downloadFile.do?fileFormat=fastachain&compression=NO&structureId=" . $pbd . "&chainId=" . chr(64 + $i);
		my $fasta_data = `curl -s -A "$uas" "$url"`;
		$fasta_data =~ s/^(.*\n)//;
		$fasta_data =~ s/\n//g;
		push(@fasta_datas, $fasta_data);
	}
	my $fasta = join(",", @fasta_datas);
	print "FASTA Chains:\n" . $fasta;
	print "\n";

	if ($pbd ~~ @pbds) {
		# it exists, don't write.
	}
	else {
		push(@pbds, $pbd);
		write_data_to_excel($name, $pbd, $classification, $species, $residue_count, $atom_count, $structure_weight, $global_symmetry, $unique_protein_chains, $fasta);
	}
}

sub proteins_with_pbd {
	my $url = "http://predictioncenter.org/casp12/targetlist.cgi";
	my $webpage_data = `curl -s "$url"`;
	my $data_table = HTML::TableExtract->new( attribs => { border => 0, align => "left", cellpadding => "3", cellspacing => 0, class => "table" } );
	$data_table->parse($webpage_data);
	$data_table = $data_table->first_table_found;
	my $c = 0;
	foreach my $row ($data_table->rows) {
		my $tar_id = @{$row}[1];
		if ($tar_id =~ /[a-zA-Z0-9]/) {
			($tar_id) = ($tar_id =~ /([\w]+)/);
			my $last_col = @{$row}[9];
			my ($pbd_code) = ($last_col =~ /PDB code (\w+)/);
			if ($pbd_code =~ /[a-zA-Z0-9]/) {
				get_depth_on_protein($tar_id, $pbd_code);
				$c++;
			}
		}
	}
	print "Total Count Collected: " . $c."\n\n";
}

BEGIN {
	# site we are using to get proteins with a PBD number
	proteins_with_pbd();
}