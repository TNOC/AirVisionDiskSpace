#!/usr/bin/perl

use File::stat;
use Time::localtime;

sub fileDate {
    my $file = shift;
    my $st = stat($file) or print "Couldn't stat $file: $!";
    my $mtime = $st->mtime; #modification time in seconds
    return $mtime;
}

sub isJPEG {
    my $file = shift;

    if ( $file =~ m/.*\.jpg$/) {
        return true;
    }

    return false;
}

sub delimater {
    return "/";
}

sub indent {
    my $depth = shift;
    
    $str = "";
    
    while ( $depth > 0 ) {
        $str .= "\t";
        $depth--;
    }
    
    return $str;
}

sub removeFromDir {

	my $keepFor = shift; #days
	my $directory = shift; #the directory to search (recursivly)
	my $depth = shift;
	
	my $fileCount = 0;
	my $filesRemoved = 0;
	my $totalRemoved = 0;
	
    #print indent($depth) ."Working in ".$directory." \n";
	
	my $removeOlderThan = time - ($keepFor * 86400);
	
	opendir( my $DIR, $directory); #.is the current dir

	while (my $file = readdir($DIR)) {
	    next if ($file =~ m/^\./);
	    
	    $fileCount = $fileCount + 1; #increase the file count
	    
	    my $longFile = $directory . $file;
	    
		if ( -d$longFile ) {#is a directory, search it
			
			#print indent($depth) . $longFile ." is a directory\n";
			
			(my $subFileCount, my $subFilesRemoved, my $subTotalRemoved) = removeFromDir($keepFor, $longFile .delimater(), $depth + 1);
			
			$totalRemoved = $totalRemoved + $subTotalRemoved;
			
			#print indent($depth) ."The Directory: ".$longFile .delimater()." had ".$subFileCount." files and ".$subFilesRemoved." were removed\n\n";
			
		} elsif (-f$longFile) {#regular file
			#print indent($depth) .$longFile ." is a file";
			
			if (isJPEG($longFile) && ( fileDate($longFile) < $removeOlderThan ) ) {
			    #print " and is a jpeg and is ready to be removed"; 

			    unlink($longFile);

			    $filesRemoved = $filesRemoved + 1;
			}

			#print "\n";
		} elsif (!-r$longFile) {
		    print indent($depth) .$longFile ." cannot be read\n";
		}
	}

	closedir $DIR;
	#print indent($depth) ."Exiting ".$directory."\n\n";
	return ($fileCount, $filesRemoved, $totalRemoved + $filesRemoved);
}


$useDir = 'C:\ProgramData\airVisionNVR\bin.32\nvr\www\events\\';
print "Starting Script\n\n";
(my $subFileCount, my $subFilesRemoved, my $totalRemoved) = removeFromDir(10, $useDir, 0);
print "The Directory: ".$useDir." had ".$subFileCount." files and ".$subFilesRemoved." were removed\n\n";
print "A total of ".$totalRemoved." files were removed\n\n";
print "Ending Script\n\n";
