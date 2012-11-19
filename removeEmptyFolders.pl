#!/usr/bin/perl

sub delimater {
    return "/";
}

sub debugp {
	my $val = shift;
	my $depth = shift;

	while ($depth > 0) {
		print "\t";
		$depth--;
	}

	print "Debug: " . $val;
}

sub removeDirWithoutJPG {
	my $directory = shift;
	my $depth = shift;

	my $fileCount = 0;


	debugp("Directory: ". $directory ."; Depth ". $depth ."\n", $depth);

	opendir( my $DIR, $directory); #.is the current dir

	my @markForDeletion = ();


	while (my $file = readdir($DIR)) {
		#print "In loop, ". $file ."\n";
		next if ($file =~ m/^(\.)+$/);#skip if special directory
	    
		my $longFile = $directory . $file;

		debugp("'".$longFile . "'\n", $depth);

	    	
		if (-d$longFile) {#is a directory
			debugp("Found a directory\n", $depth);
			my $filesLeft = removeDirWithoutJPG($longFile . delimater(), $depth + 1);
			if ($filesLeft == 0) {
				debugp("Can remove directory ". $longFile ."\n", $depth);
				rmdir($longFile);
				#remove foler
			} else {#cannot delete folder
				debugp "Cannot remove directory ". $longFile .", ". $filesLeft ." files are left\n", $depth;
				$fileCount++;
			}
		} elsif (-f$longFile) {
			if ($file =~ m/^\.([0-9])+$/) {
				debugp("Mark file ". $longFile ." for deletion \n", $depth);
				push(@markForDeletion, $longFile);
			} else {
				debugp("File: ". $longFile ." does not match pattern\n", $depth);
				$fileCount++;
			}
		} else {
			debugp("Do not know what ". $longFile ." is\n", $depth);
		}

	}

	debugp( "Marked for deletion: ". @markForDeletion ."\n", $depth);

	closedir $DIR;

	if ($fileCount > 0) {#some files are not able to be deleted
		debugp "More than just the .# file in ".$directory." (".$fileCount.")\n", $depth;
		return $fileCount;
	} else {
		#delete individual files
		while ($fileToDelete = pop(@markForDeletion)) {
			debugp("Delete ". $fileToDelete ."\n", $depth);
			unlink($fileToDelete);
		}
		#delete dir, return 0
		return 0;
	}

	
	
}


my $useDir = 'C:\ProgramData\airVisionNVR\bin.32\nvr\www\events\\';

open (LOGFILE, '>>run.txt');

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
printf LOGFILE "Starting script at: %4d-%02d-%02d %02d:%02d:%02d",
$year+1900,$mon+1,$mday,$hour,$min,$sec;

print LOGFILE " in ". $useDir ."\n";
removeDirWithoutJPG($useDir, 0);


($sec,$min,$hour,$mday,$mon,$year,$wday,
$yday,$isdst)=localtime(time);
printf LOGFILE "Ending Script at: %4d-%02d-%02d %02d:%02d:%02d\n",
$year+1900,$mon+1,$mday,$hour,$min,$sec;

close (LOGFILE);
