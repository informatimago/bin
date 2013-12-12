#!/bin/sed -f
s/\&/\&amp;/g
s/^ /\&nbsp;/
:again
s/\&nbsp; /\&nbsp;\&nbsp;/
t again
s/[<]/\&lt;/g
s/[>]/\&gt;/g
s/[#]/\&#35;/g
s/\\/\&#92;/g
s/\//\&#47;/g
