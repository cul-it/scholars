#!/usr/bin/env python
import commands
import string
cmd = "find . -type d -name \".svn\" -prune -o -exec echo {} \\;";
res = commands.getstatusoutput( cmd );
names = res[1].split('\n');
filenameHash ={};

for name in names:
    lowerName= name.lower();
    if( filenameHash.has_key( lowerName ) ) :
        filenameHash[lowerName].append( name );
    else:
        filenameHash[lowerName] = [ name ];

for key in filenameHash.keys():
    nameList = filenameHash[key];
    if( len( nameList ) > 1 ):
        outstr = '';
        for name in nameList:
            outstr = outstr + name + ' ';
            print( outstr + "\n");

