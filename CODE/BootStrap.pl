#!/opt/perl/bin/perl

use strict;
use warnings;
use FileHandle;
use Getopt::Long;
use IO::File;
use Cwd;

my $filename; # this will be used to capture the ID of the individual
my $result; #all of the fed in variables
my $directory;#the directory of the .BOTH file
my $name; #the suffix added to our new maternal and paternal position files
my $num; #the number of positions to go back by (30 fo RIBO) and (75 for RNA)


$result = GetOptions(
	"filename=s" => \$filename,
	"directory=s" => \$directory,
     	"name=s" => \$name,
	"count=i" => \$num,
 );


my $matpileup = IO::File->new("mat.pileup") or die "$!";
my $patpileup = IO::File->new("pat.pileup") or die "$!";
my @t = split("\_", $filename); # we want to get the sample name, not all of the Ribo or RNA labeling that comes after it
my $the_name = $t[0];
my $file = IO::File->new("$directory/$the_name.BOTH") or die "$!"; # get the .BOTH file

my %hashmat; # keep track of counts from the mat.pileup
my %hashpat; # keep track of counts from the pat.pileup
my %counts; # keep track of the nucleotides in each line of the pileup file

# The next steps will involve parsing the matpileup and patpileup to go through all of the positions in the piluep files and store them. 
#I thought this method would be better than going throuhg the lines in .BOTH file and then grepping all fo the lines. 
#In this case, we area only reading through the pileup files once, but in the other version, we are reading through the files multiple times to grep. 


while (my $line = $matpileup->getline) {
	my @t = split(/\t/, $line); # get the line and split it into its parts
	my ($gene, $start, $N, $count, $letters, $other) = @t[0,1,2,3,4,5]; 
	for my $char (split //, $letters) { 
		$counts{$char}++;# storing the nucleotides
        }
	if (defined $counts{'S'}){
	print "$gene\t$start\t$counts{'S'}\n"; #counting the numebr of "S" which signifies that a particular nucleotides read comes from the very first nucleotides of a transcript
		$hashmat{"$gene\t$start"} = $counts{"S"};}
	else {$hashmat{"$gene\t$start"} = 0;}

	undef %counts;
	
}
 # The same process for the pat.pileup
while (my $line = $patpileup->getline) {
        my @t = split(/\t/, $line);
        my ($gene, $start, $N, $count, $letters, $other) = @t[0,1,2,3,4,5];
        for my $char (split //, $letters) {
        $counts{$char}++;
          }
         if (defined $counts{'S'}){
            $hashpat{"$gene\t$start"} = $counts{"S"};}
          else {$hashpat{"$gene\t$start"} = 0;}
                        undef %counts;
    }


#Now we are going to get each line in the .BOTH file (so all of the positions that have corssed the 20 cutoff), and count back 30 or 75 posiyions and write all of the counts for those positions to their respective maternal and paternal file.
while (my $line = $file->getline){
	
	if ($line =~ m/^BOTH/){ next;}
	my @t = split(/\t/, $line);
	my ($gene, $start, $matribo, $patribo, $matrna, $patrna) = @t[0,1,2,3,4,5];

	my $thestart = int($start) - int($num);
	
	if ($thestart < 0){
		$thestart = 0;	
	}

	my $string = "$gene.$start";
	my $output = IO::File->new("$string.maternal$name", ">") or die "Could not create output file. $!";
	my $output2 = IO::File->new("$string.paternal$name", ">") or die "Could not create output file. $!";


	for (my $i=$thestart; $i < $start+1; $i++){ 
		my $str = "";
		if (defined $hashmat{"$gene\t$i"}){
			$str = $hashmat{"$gene\t$i"};} else {$str = 0; }
			print $output "$gene\t$i\t$str\n";
		if (defined $hashpat{"$gene\t$i"}){
			$str = $hashpat{"$gene\t$i"};} else {$str = 0;}
			print $output2 "$gene\t$i\t$str\n";
		}
	
	}

	

