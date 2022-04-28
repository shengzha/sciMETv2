#!/usr/bin/perl

$die = "

sciMET_perCellAlignRate.pl [read 1 or 2 fastq file(s), post-trim - can be comma separated] [aligned bam file, pre-rmdup] [list fo cellIDs to include] [output file]

Calculate per-cell alignment rates.

";

if (!defined $ARGV[3]) {die $die};

open IN, "$ARGV[2]";
while ($l = <IN>) {
	chomp $l;
	$l =~ s/\s.+$//;
	$CELLS_ct{$l} = 0;
} close IN;

@FQS = split(/,/, $ARGV[0]);
foreach $fq (@FQS) {
	open IN, "zcat $fq |";
	while ($tag = <IN>) {
		chomp $tag; $tag =~ s/^@//; $tag =~ s/:.+$//;
		if (defined $CELLS_ct{$tag}) {
			$CELLS_ct{$tag}++;
		}
		$null = <IN>; $null = <IN>; $null = <IN>;
	} close IN;
}

open IN, "samtools view $ARGV[1] |";
while ($l = <IN>) {
	chomp $l;
	@P = split(/\t/, $l);
	$barc = $P[0]; $barc =~ s/:.+//;
	if (defined $CELLS_ct{$barc}) {
		$CELLS_aln{$barc}++;
	}
} close IN;

open OUT, ">$ARGV[3]";
foreach $cellID (keys %CELLS_aln) {
	if ($CELLS_ct{$cellID}>0) {
		$pct = sprintf("%.2f", ($CELLS_aln{$cellID}/$CELLS_ct{$cellID})*100);
		print OUT "$cellID\t$CELLS_ct{$cellID}\t$CELLS_aln{$cellID}\t$pct\n";
	}
} close OUT;