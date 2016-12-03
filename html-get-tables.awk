#!/bin/awk --


function chop(string) {
    i=0;
    j=length(string)-1;
    change=1;
    while(change!=0){
        change=0;
        if(substr(string,1+i,1)==" "){
            i++;
            change=1;
        }
        if(substr(string,1+j,1)==" "){
            j--;
            change=1;
        }
        if(j<i){
            change=0;
        }
    }
    return(substr(string,1+i,j-i+1));
}


BEGIN {
    IGNORECASE=1;
    out_FS="|";
    level=0;
    all_level=1; # !=0 => dumps also sub-tables.
    table_num=0;
    do_write=0;

}


##DEBUG##{
##DEBUG##    printf("read: %2d %2d %1d  %s\n",table_num,level,do_write,$0);
##DEBUG##}


/<table/{
##DEBUG##    printf("    -> /<table/\n");
    level++;
    if((all_level!=0)||(level==1)){
        table_num++;
        do_write=1;
        printf("\n## TABLE: %d\n",table_num);
    }else{
        do_write=0;
    }
    next;
}

/<\/table/{
##DEBUG##    printf("    -> /</table/\n");
    level--;
    if(level==0){
        do_write=0;
    }
    next;
}


/<tr/{
##DEBUG##    printf("    -> /<tr/\n");
    next;
}

/<\/tr/{
##DEBUG##    printf("    -> /</tr>/\n");
    if(do_write!=0){
        printf "\n",$0;
    }
    next;
}

/<td/{
##DEBUG##    printf("    -> /<td/\n");
    next;
}

/<\/td/{
##DEBUG##    printf("    -> /</td>/\n");
    if(do_write!=0){
        printf("%s",out_FS);
    }
    next;
}

/<br>/{
##DEBUG##    printf("    -> /<br>/\n");
    if(do_write!=0){
        printf " ";
    }
    next;
}

/<!--.*-->/{
    next;
}

/<[\/]*[a-z]/{
    next;
}


{
    if(do_write!=0){
        printf "%s",chop($0);
    }
    next;
}



