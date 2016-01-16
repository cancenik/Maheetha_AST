#!/opt/perl/bin/perl

use strict;
use warnings;
use FileHandle;
use Getopt::Long;
use IO::File;
use Cwd;


my $filename; # this will be used to capture the ID of the individual
my $vcf_file; # this will be the variant call file from which we read the heterozygous reads
my $file; # this is the absoulte path for the pileup file 
my $help;
my $result;

$result = GetOptions(
       "filename=s" => \$filename, 
       "vcf_file=s" => \$vcf_file,
       "pileup_file=s" => \$file,
       "help" => \$help,
       );

my $vcf = IO::File->new("$vcf_file") or die "Could not open VCF file for some reason"; # we open the vcf file


#The next few steps will extract whether the file is maternal or paternal pileup file. In the end, the $parent variable is what's used to determine whether the file is maternal or paternal reads.

my @pileup = split(/\//, $file); 
my $scalar = scalar(@pileup);
my $pileup_file = $pileup[$scalar-1];
my @matorpat = split(/\./, $pileup_file);
my $parent = $matorpat[0];
print "$parent";

#This will be the output of the read counts for the heterozygous sites.
my $outfile = "$parent.output";

my $output = IO::File->new("$outfile", ">") or die "Could not create output file. $!";

#Creating Headers for the maternal and paternal output files

if ($parent eq "mat"){
	print $output "Sample_MATERNAL_$filename\tGene\tStart_Position\tTotal_$filename\tA_$filename\tC_$filename\tG_$filename\tT_$filename\tAllele_$filename\tRef_or_Alt_$filename\tHom/Het_$filename\tConsistency_$filename\n";

}

if ($parent eq "pat"){

	print $output "Sample_PATERNAL_$filename\tGene\tStart_Position\tTotal_$filename\tA_$filename\tC_$filename\tG_$filename\tT_$filename\tAllele_$filename\tRef_or_Alt_$filename\tHom/Het_$filename\tConsistency_$filename\n";

}


#The number is indicative of which column in the VCF file matches the sample ID, so that we can extract whether the maternal/paternal read is reference or alternative.
my $number = -1;


#We will read the vcf file line by line, and try to find that same gene and position in the pileup files. If no such position and gene are found in the pileup file, the gene and start position are written to the output file, with zeros next to it. However, if it is found, then the reads are counted in the pileup file, and added to the output file. Along with read counts, we also check of consistency, making sure that sites that have more than one type of allele as a read are marked as inconsistent. 
#
#Reading the vcf file line by line
while (my $line = $vcf->getline) {

#This is keeping track of all the bases and their counts foe each line.
my $bases = "";
my $A = 0;
my $C = 0;
my $T = 0;
my $G = 0;

if ($number < 0){
#If the line starts with CHROM, we want to extract the column that contains the ref/alt marking for the particular sample we are dissecting.
 	if ($line =~ m/^#CHROM/){
	       print "Reading VCF file Line by Line \n";
               my @t = split(/\t/, $line);
               my @r = split(/\_/,$filename); #get the sample name which is why we pass in the file name.

		#We now get the column which represents the sample for which we are doing this analysis for. The column names only contain 'GM' and the first five digits of the sample. So of the bam name that was passed in we first extracted the SAMPLE name (i.e GMXXXXX), and then we try to compare it.
               for (my $i=0; $i < scalar(@t); $i++){
               if (substr($r[0],2,5) eq substr($t[$i], 2, 5)){
               $number = $i; #update the number
	       next;
              		}
		}
	}
}


	#Then if the line doesn't start with CHROM and starts with a # skip it.
	if ($line =~ m/^#/){next;}

	#All positions are homozygous unless the vcf file says otherwise.
	my $hom = "HOM";
	
	#We use this array to split the line
	my @array = split(/\t/, $line);
	
	#Assign names to the variables. NOtice how number has reappeared to get the zygosity	
	my ($gene, $start, $ref, $alt, $zygosity) = @array[0,1,3,4,$number];
	
	
	
	#We try to match the gene and start position in the vcf file
	my $match = `egrep "^$gene\t$start\t" $file`;	
	if ($match eq "") {next;} # if the match is empty SKIP. 

	#if the zygoisity is heterozygous, then we make the HOM/HET
	if ($zygosity eq "0|1" || $zygosity eq "1|0"){$hom = "HET";} else { next; } # we don't really care if it's not heterozygous

		#split the zygosity 		
		my @zygos = split(/\|/, $zygosity);
		
		my $RorA = 0; #This is reference or allele?
		my $allele = $ref; #default allele = ref, will be changed to $alt, when needed.
		
		#Assigning the alleles properly, and reference or alternative status.
		if ($parent eq "mat"){
			if ($zygos[1] eq "1"){$allele = $alt;  $RorA = $zygos[1];}
			else { $allele = $ref; $RorA = 0;}
			}
		if ($parent eq "pat"){
			if ($zygos[0] eq "1"){$allele = $alt; $RorA = $zygos[0];}
			else {$allele = $ref; $RorA = 0;}
			}
		
		
		#Parse the match. Get its gene, position, number of bases, etc.
			my @t = split(/\t/, $match);
               		$gene = $t[0];
               		my ($pos, $num, $bases) = @t[1,3,4];

			
                	chomp($pos);
                        chomp($num);
                        chomp($bases);
                        
			#submethod count bases
			($bases, $A, $T, $C, $G) = count($bases, $A, $T, $C, $G);
			
			#default is consistent, and we make it "Inconsistent" if more than 5% of the Bases are of a different from the major allele. 
			my $consistency = "Consistent";

			#counting total of only the major allele.
			my $total = 0;
			if ($allele eq 'A'){$total += $A;}
			elsif ($allele eq 'T') {$total += $T;}
			elsif ($allele eq 'G') {$total += $G;}
			elsif ($allele eq 'C') {$total += $C;}
			
			#grand total is counting all of the bases (if there are more than one)
			my $grand_total = $A + $T + $C + $G;
			
			#If the $total is not equal to grand_total, then that means that there are other base pairs that exist other than the major haplotype
			if ($total != $grand_total){
				if ($total/$grand_total >= 0.95){
					$consistency = "Consistent";}
				else {
				# else we just disregard the positions
					$total = 0;
					$A = 0;
					$T = 0;
					$G = 0;
					$C = 0;
				}
			}	
			
			
			#in the end we only really want heterozygous positions
			print $output "$filename\t$gene\t$start\t$total\t$A\t$C\t$G\t$T\t$allele\t$RorA\t$hom\t$consistency\n";
			
		

	}



#Submethod takes in the "bases" that in the fourth column of the pileup file and separates them into A,T,C, and Gs.                                
sub count {
my ($bases, $A, $T, $C, $G) = @_;
        my %counts;
        
		#Split the bases, and count the nucleotides
		for my $char (split //, $bases) {
                $char = uc($char);
                $counts{$char}++;
                }
        if (defined $counts{'A'})
                {$A = $counts{'A'};}
        if (defined $counts{'T'}){
                $T = $counts{'T'};}
        if (defined $counts{'G'})
                {$G = $counts{'G'};}
        if (defined $counts{'C'}){
                $C = $counts{'C'};}

@_ = ($bases, $A, $T, $C, $G);
}



##
###The purpose of this script is to read in a bam file and make
###a maternal versus a paternal pileup (reads)
##
###the help will be made later, but for now, the input is a bam file


#p the vcf file, and open up the first line that's an actual thing
#once you have that position
#grep it and store it into a file. 
#if it's not empty, parse it, and if it's empty, then say 0. 
#and if it's mat, then output is titled maternal, and if it's pat, output is titled paternal.
#
#
#
#
#
#
#
#
