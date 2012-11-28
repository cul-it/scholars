#!/usr/bin/perl

use FindBin qw($Bin);
use lib $Bin;
use FileHandle;
use CGI;
use POSIX qw( strftime );
$g_T0 = time();


# Script to handle allow upload of a tar file, then untar it and place it in
# the vivo file upload CCE directory.
# Ex. of use:
# curl -F tarf=@www.tar -u jrm424:blahblah bailey.mannlib.cornell.edu:9191/cgi-bin/tarup.cgi

# In order to get this to work on vivoprod01
# the linux ACL need to be set correctly to allow
# both the tomcat user and the apache user to modify
# files in the directories with the CCE images. The ACLs
# on that directory needs to allow rwx to the user
# for tomcat and the user for apache. 

# I used the following commands to acheive this:
# First we want tomcat to be able to access these files no matter who ownes them
# and we want to set it so any new directories also are accessible to tomcat.
#   sudo setfacl -m user:tomcat:rwx /vivo/vivodata/uploads/file_storage/a~n/
#   sudo setfacl -R -d -m user:tomcat:rwx ./vivo/vivodata/uploads/file_storage/a~n/

# Next we need to allow apache user to work with the cce directory.
#   sudo setfacl -R -m user:apache:rwx ./vivo/vivodata/uploads/file_storage/a~n/cce/
#   sudo setfacl -R -d -m user:apache:rwx ./vivo/vivodata/uploads/file_storage/a~n/cce/

#set this to the vivo data directory for this server
$vivodata = "/vivo/vivodata";

$ccedir = "$vivodata/uploads/file_storage_root/a~n/cce";

$upldir = "/tmp/tarup";
$extdir = "$upldir/extract";
$uplfile = "$upldir/image.tar";

`mkdir -p $upldir`;
`mkdir -p $extdir`;

# get the ball rolling...
$fragment = "Content-Type: text/html\n";
$fragment .= "Expires: Tue, 01 Jan 1981 01:00:00 GMT\n\n";
print $fragment;
$g_cgi = new CGI;
$path = $g_cgi->param("tarf");

if($path ne ''){

    if($path !~ /\.tar$/){
        result("'$path' not a tar file. Image Tar Upload Failed.");
        exit 0;
    }
    $handle = $g_cgi->upload("tarf");

    open UPLOADFILE, ">$uplfile";
    binmode UPLOADFILE;

    while ( <$handle> ){
        print UPLOADFILE;
    }
    close UPLOADFILE;
    
    #unpack file and see if it has a cce dir
    `tar -xf $uplfile -C $extdir/`;
    `rm $uplfile`;

     if ( -e "$extdir/cce" ) {
       #backup old dir
       `rm -rf $upldir/oldcce`;
       `cp -rp $ccedir $upldir/oldcce`;
 
       #copy new files into place, mv would wreck ACLs
       `rm -rf $ccedir/*`;
       `cp -r $extdir/cce/* $ccedir/`;
       result("Image Tar Uploaded and cce replaced");
     }else{
       result("Image Tar Uploaded, but no cce directory found in top level of extracted tar.");
     }
} else {
    result("Image Tar Upload Failed.");
}

sub result {
    my($msg) = @_;
    print << "RESPONSE";
<html>
<title>Image Tar Upload</title>
<body>
<p>$msg</p>
</body>
</html>

RESPONSE
}
