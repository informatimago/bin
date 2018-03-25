#!/bin/bash
#******************************************************************************
#FILE:               distribution
#LANGUAGE:           bash
#SYSTEM:             POSIX
#USER-INTERFACE:     POSIX
#DESCRIPTION
#    Identify the system, distribution and release where we run.
#    Prints a line with three corresponding keywords.
#    Status: 0 upon success.
#USAGE
#    distribution
#BUGS
#    We should add the processor to the output.
#AUTHORS
#    <PJB> Pascal J. Bourguignon <pjb@informatimago.com>
#MODIFICATIONS
#    2013-08-10 <PJB> Added support for /etc/os-release (ubuntu).
#    2011-11-05 <PJB> Added support for MacOSX.
#    2001-04-29 <PJB> Creation.
#BUGS
#LEGAL
#	Copyright Pascal J. Bourguignon 2001 - 2013
#
#   This script is free software; you can redistribute it and/or
#   modify it under the terms of the GNU  General Public
#   License as published by the Free Software Foundation; either
#   version 2 of the License, or (at your option) any later version.
#
#   This script is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#   General Public License for more details.
#
#   You should have received a copy of the GNU General Public
#   License along with this library; see the file COPYING.LIB.
#   If not, write to the Free Software Foundation,
#   59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
#******************************************************************************

function shell-quote(){
    # Synopsis: shell-quote argument…
    # Output:   a textual representation of each argument with all special characters escaped.
    # Status:   0
    for arg ; do
        local slash=${arg//\\/\\\\}
        local quote=\'${slash//\'/\'\\\'\'}\' # no "${...}" here! It would break the \'
        echo -n "${quote} "
    done
}


function assign(){

    # Shell functions with side effects cannot be used in subshells
    # (or the side effects will only happen there).
    #
    # Therefore, to be able to assign the output of a shell function
    # with side effects, we need to take care of running everything in
    # the current process.
    #
    #     assign var = command arguments…
    #
    # executes the command with the arguments, and collect the output
    # to be assigned to the variable var.

    local var="$1"
    local eq="$2"
    shift 2
    if [ "$eq" != "=" ] ; then echo "assign syntax:  assign variable = command arguments …" ; return 1 ; fi
    local out=/tmp/assign-$$.out
    "$@" > "$out"
    read $var < "$out"
}



vectorCount=${vectorCount:-0}

function vector(){
    # Synopsis: vector elements…
    # Output:   a vectVar (the name of a bash array variable containing the vector elements).
    # Status:   0
    # Example:  assign v = vector 1 2 3 ; vector-ref v 1 --> 2
    # Note:     vector indexing is 0-based.
    local vectVar=vector_${vectorCount}
    vectorCount=$(( ${vectorCount} + 1 ))
    eval "${vectVar}=( $(shell-quote "$@") )"
    echo ${vectVar}
}

function vector-length(){
    # Synopsis: vector-length vectVar
    # Output:   the length of the vector.
    # Status:   0
    local vectVar="$1"
    eval echo \${#${vectVar}[@]}
}


function vector-ref(){
    # Synopsis: vector-ref vectVar index
    # Output:   the value in the slot index of the vector, or empty string if out of bounds.
    # Note:     vector-ref vectVar 0 is returned if index is not an integer (bashism).
    # Status:   0
    local vectVar="$1"
    local index="$2"
    eval echo \${${vectVar}[${index}]}
}


function vector-set(){
    # Synopsis: vector-set vectVar index newValue
    # Does:     sets the slot index of the vector to the newValue.
    # Note:     Sets the slot 0 if index is not an integer (bashism).
    # Output:   nothing
    # Status:   0
    local vectVar="$1"
    local index="$2"
    local value="$3"
    local oldLength=$(vector-length $vectVar)
    while [[ $oldLength < $index ]] ; do
        eval ${vectVar}[${oldLength}]=''
        oldLength=$(( $oldLength + 1 ))
    done
    eval "${vectVar}[${index}]=$(shell-quote "${value}")"
}


function vector-equal(){
    # Synopsis: vector-equal v1 v2
    # Output:   Nothing
    # Status:   0 if the vectors contain equal elements, 1 otherwise
    local v1="$1"
    local v2="$2"
    if object-equal "$v1" "$v2" ; then
        return 0
    elif [ $(vector-length "$v1") -eq $(vector-length "$v2") ] ; then
        local len=$(vector-length "$v2")
        local i
        for ((i=0;$i<$len;i++)) ; do
            if [ "$(vector-ref "$v1" $i)" != "$(vector-ref "$v2" $i)"  ] ; then
                return 1
            fi
        done
        return 0
    else
        return 1
    fi
}


function vector-elements(){
    local vectVar="$1"
    local len=$(vector-length $vectVar)
    for ((i=0; $i<$len ;i++)) ; do
        echo "$(shell-quote "$(vector-ref $vectVar $i)")"
    done
}


function vector-append(){
    # Synopsis: vector-append vectVar…
    # Does:     Concatenate the vectors.
    # Output:   The reference to the concatenated vector.
    # Status:   0
    eval vector $(for v ; do vector-elements $v ; done)
    # echo vector $(for v ; do vector-elements $v ; done) >> /dev/stderr
}


function vector-add-elements(){
    # Synopsis: vector-add-elements vectVar newElements…
    # Does:     Add the newElements at the end of the vector vectVar.
    # Output:   vectVar
    # Status:   0
    local vectVar="$1"
    shift
    if [ -z "$vectVar" ] ; then echo "${FUNCNAME}: Missing vector argument." ; return 1 ; fi
    # echo eval "${vectVar}=( $(vector-elements ${vectVar}) $(shell-quote "$@") )" >> /dev/stderr
    eval "${vectVar}=( $(vector-elements ${vectVar}) $(shell-quote "$@") )"
    echo ${vectVar}
}


function vector-inspect(){
    # Synopsis: vector-inspect vectVar
    # Output:   each slot of the vector formated on per line.
    # Status:   0
    local vectVar="$1"
    local i=0
    local size=$(vector-length $vectVar)
    for ((i=0;i<$size;i++)) ; do
        printf "%s[%s]=%s\n" $vectVar $i "$(shell-quote "$(vector-ref $vectVar $i)")"
    done
}


function vector-print(){
    # Synopsis: vector-print vectVar
    # Output:   A sexp representing the vector.
    # Status:   0
    local vectVar="$1"
    local i=0
    local size=$(vector-length $vectVar)
    local sep=""
    printf "#("
    for ((i=0;i<$size;i++)) ; do
        printf "%s" "$sep"
        sep=" "
        object-prin1 "$(vector-ref $vectVar $i)"
    done
    printf ")\n"
}



dictionaryCount=${dictionaryCount:-0}

function dictionary(){
    # Synopsis: dictionary key value…
    # Output:   a dictVar (the name of a bash array variable containing the dictionary elements).
    # Status:   0
    # Example:  assign d = dictionary one 1 two 2 three 3 ; dictionary-ref d two --> 2
    dictionaryCount=$(( ${dictionaryCount} + 1 ))
    local dictVar=dictionary_${dictionaryCount}
    # echo "${dictVar}=(nil dictionary $(shell-quote "$@") )" >> /dev/stderr
    eval "${dictVar}=(nil dictionary $(shell-quote "$@") )"
    echo ${dictVar}
}


function dictionaryp(){
    # Synopsis: dictionaryp dictVar
    # Output:   nothing
    # Status:   0 if dictVar is a bash array variable containing a dictionary, 1 otherwise.
    local dictVar="$1"
    local key="$2"
    [ "$(vector-ref $dictVar 1)" = dictionary ]
}


function dictionary-get-index(){
    local dictVar="$1"
    local key="$2"
    local len=$(vector-length $dictVar)
    if [ "$(vector-ref $dictVar 1)" = dictionary ] ; then
        local i=2
        # echo o $i -lt $len -a "$(vector-ref $dictVar $i)" != "$key" >> /dev/stderr
        while [ $i -lt $len -a "$(vector-ref $dictVar $i)" != "$key" ] ; do
            i=$(( $i + 2 ))
            # echo i $i -lt $len -a "$(vector-ref $dictVar $i)" != "$key" >> /dev/stderr
        done
        if [ $i -lt $len ] ; then
            echo $i
        else
            echo 0
        fi
    else
        err "$dictVar is not a dictionary."
    fi
}


function dictionary-keys(){
    local dictVar="$1"
    if [ "$(vector-ref $dictVar 1)" = dictionary ] ; then
        local i=2
        local len=$(vector-length $dictVar)
        while [[ $i < $len ]] ; do
            echo  "$(vector-ref $dictVar $i)"
            i=$(( $i + 2 ))
        done
    else
        err "$dictVar is not a dictionary."
    fi
}


function dictionary-has-key(){
    local dictVar="$1"
    local key="$2"
    local i=$(dictionary-get-index $dictVar "$key")
    [[ $i != 0 ]]
}





function dictionary-get(){
    local dictVar="$1"
    local key="$2"
    local i=$(dictionary-get-index $dictVar "$key")
    if [[ $i = 0 ]] ; then
        echo ""
    else
        echo "$(vector-ref $dictVar $(( $i + 1 )))"
    fi
}


function dictionary-set(){
    local dictVar="$1"
    local key="$2"
    local value="$3"
    local i=$(dictionary-get-index $dictVar "$key")
    if [[ $i = 0 ]] ; then
        i=$(vector-length $dictVar)
        vector-set $dictVar $i "$key"
    fi
    vector-set $dictVar $(( $i + 1 )) "$value"
}


function dictionary-count(){
    local dictVar="$1"
    local c=$(vector-length $dictVar)
    echo $(( ($c - 2) / 2 ))
}

########################################################################


darwinVersions=
assign darwinVersions = dictionary
macosxCodenames=
assign macosxCodenames = dictionary

function declareDarwinVersion(){
    # declareDarwinVersion "Version " "Date" "Corresponding releases" "Notes"
    local darwinVersion="$1"
    local codename="$2"
    local date="$3"
    local macVersion="$4"
    local notes="$5"
    case "$macVersion" in
    'OS X'*)
        dictionary-set $darwinVersions  "$darwinVersion" "$macVersion"
        dictionary-set $macosxCodenames "$darwinVersion" "$codename"
        ;;
    *)
        true
        ;;
    esac
}

function macOSXVersionFromDarwinVersion(){
    local darwinVersion="$1"
    dictionary-get $darwinVersions "$darwinVersion"
}

function macOSXCodenameFromDarwinVersion(){
    local darwinVersion="$1"
    dictionary-get $macosxCodenames "$darwinVersion"
}

declareDarwinVersion "0.1"     ""                "March 16, 1999"      "Mac OS X DP1"                           "0.1 is contrived (for sorting and identification) as this identified itself simply as Mac OS 10.0"
declareDarwinVersion "0.2"     ""                "November 10, 1999"   "Mac OS X DP2"                           ""
declareDarwinVersion "1.0"     ""                "February 2000"       "Mac OS X DP3"                           ""
declareDarwinVersion "1.1"     ""                "April 5, 2000"       "Mac OS X DP4"                           ""
declareDarwinVersion "1.2.1"   "Kodiak"          "November 15, 2000"   "Mac OS X Public Beta"                   "Code named \"Kodiak\""
declareDarwinVersion "1.3.1"   "Cheetah"         "April 13, 2001"      "Mac OS X v10.0"                         "First commercial release of Darwin"
declareDarwinVersion "1.3.1"   "Cheetah"         "June 21, 2001"       "Mac OS X v10.0.4"                       "All releases of \"Cheetah\" (10.0–10.0.4) had the same version of Darwin"
declareDarwinVersion "1.4.1"   "Puma"            "October 2, 2001"     "Mac OS X v10.1"                         "Performance improvements to \"boot time, real-time threads, thread management, cache flushing, and preemption handling,\" support for SMB network file system, Wget replaced with cURL.[12]"
declareDarwinVersion "5.1"     "Puma"            "November 12, 2001"   "Mac OS X v10.1.1"                       "Change in numbering scheme to match Mac OS X build numbering scheme (e.g., Mac OS X v10.1 contains build numbers starting with 5 so Mac OS X v10.1.1 is now based on Darwin 5.1; i.e., 10.1 means 5 so 10.1.1 means 5.1, etc.)"
declareDarwinVersion "5.5"     "Puma"            "June 5, 2002"        "Mac OS X v10.1.5"                       "Last release of \"Puma\""
declareDarwinVersion "6.0.1"   "Jaguar"          "September 23, 2002"  "Mac OS X v10.2 (Darwin 6.               0.2)"    "GCC upgraded from 2 to 3.1, IPv6 and IPSec support, mDNSResponder service discovery daemon (Rendezvous), addition of CUPS, Ruby, and Python, journaling support in HFS+ (Darwin 6.2), application profiles (\"pre-heat files\") for faster program launching.[13]"
declareDarwinVersion "6.8"     "Jaguar"          "October 3, 2003"     "Mac OS X v10.2.8"                       "Last release of \"Jaguar\""
declareDarwinVersion "7.0"     "Panther"         "October 24, 2003"    "Mac OS X v10.3"                         "BSD layer synchronized with FreeBSD 5, automatic file defragmentation, hot-file clustering, and optional case sensitivity in HFS+, bash instead of tcsh as default shell, read-only NTFS support (Darwin 7.9).[14]"
declareDarwinVersion "7.9"     "Panther"         "April 15, 2005"      "Mac OS X v10.3.9"                       "Last release of \"Panther\""
declareDarwinVersion "8.0"     "Tiger"           "April 29, 2005"      "Mac OS X v10.4"                         "Stable kernel programming interface, finer-grained kernel locking, 64-bit BSD layer, launchd service management framework, extended file attributes, access control lists, commands such as cp and mv updated to preserve extended attributes and resource forks.[15]"
declareDarwinVersion "8.0"     "Tiger"           "April 29, 2005"      "Mac OS X for Apple TV (Darwin 8.8.2)"   "Stable kernel programming interface, finer-grained kernel locking, 64-bit BSD layer, launchd service management framework, extended file attributes, access control lists, commands such as cp and mv updated to preserve extended attributes and resource forks.[15]"
declareDarwinVersion "8.11"    "Tiger"           "November 14, 2007"   "Mac OS X v10.4.11"                      "Last release of \"Tiger\""
declareDarwinVersion "9.0"     "Leopard"         "October 26, 2007"    "iPhone OS 1 (Darwin 9.0.0d1)"           "Full POSIX compliance, improved hierarchical process scheduling model, dynamically allocated swap files, dynamic resource limits (for files and processes), process sandboxing, address space layout randomization, DTrace tracing framework, file system events daemon, directory hard links, Apache 1.3 and PHP 4 updated to Apache 2.2 and PHP 5, read-only ZFS support.[16]"
declareDarwinVersion "9.0"     "Leopard"         "October 26, 2007"    "Mac OS X v10.5"                         "Full POSIX compliance, improved hierarchical process scheduling model, dynamically allocated swap files, dynamic resource limits (for files and processes), process sandboxing, address space layout randomization, DTrace tracing framework, file system events daemon, directory hard links, Apache 1.3 and PHP 4 updated to Apache 2.2 and PHP 5, read-only ZFS support.[16]"
declareDarwinVersion "9.8"     "Leopard"         "August 5, 2009"      "Mac OS X v10.5.8"                       "Last release of \"Leopard\""
declareDarwinVersion "10.0"    "Snow Leopard"    "August 28, 2009"     "Mac OS X v10.6"                         "End of official support for PowerPC architecture (although several fat binaries, such as Kernel, still contain PPC images); 64-bit kernel and drivers, libdispatch task parallelization framework, OpenCL heterogeneous computing framework, support for blocks in C, transparent file compression in HFS+.[17]"
declareDarwinVersion "10.0"    "Snow Leopard"    "August 28, 2009"     "iOS 4"                                  "End of official support for PowerPC architecture (although several fat binaries, such as Kernel, still contain PPC images); 64-bit kernel and drivers, libdispatch task parallelization framework, OpenCL heterogeneous computing framework, support for blocks in C, transparent file compression in HFS+.[17]"
declareDarwinVersion "10.8"    "Snow Leopard"    "June 23, 2011"       "Mac OS X v10.6.8"                       "Last release of \"Snow Leopard\""
declareDarwinVersion "11.0.0"  "Lion"            "July 20, 2011"       "Mac OS X v10.7"                         "XNU no longer supports PPC binaries (fat binary only for i386, x86_64). XNU requires an x86_64 processor. Improved sandboxing of applications"
declareDarwinVersion "11.0.0"  "Lion"            "July 20, 2011"       "iOS 5[18]"                              "XNU no longer supports PPC binaries (fat binary only for i386, x86_64). XNU requires an x86_64 processor. Improved sandboxing of applications"
declareDarwinVersion "11.4.0"  "Lion"            "February 1, 2012"    "Mac OS X v10.7.4"                       "\"Lion\""
declareDarwinVersion "11.4.2"  "Lion"            "October 4, 2012"     "Mac OS X v10.7.5"                       "\"Latest version of Lion, supplemental\""
declareDarwinVersion "12.0.0"  "Mountain Lion"   "February 16, 2012"   "OS X v10.8"                             "Code named \"Mountain Lion\"; the word \"Mac\" has been dropped from the name"
declareDarwinVersion "12.3.0"  "Mountain Lion"   "January 6, 2013"     "OS X v10.8.2"                           ""
declareDarwinVersion "12.4.0"  "Mountain Lion"   "June 4, 2013"        "OS X v10.8.4"                           ""
declareDarwinVersion "12.5.0"  "Mountain Lion"   "September 12, 2013"  "OS X v10.8.5"                           ""
declareDarwinVersion "13.0.0"  "iOS 6"           "June 11, 2012"       "iOS 6"                                  "Unknown as to why iOS 6 uses Darwin 13 instead of Darwin 12."
declareDarwinVersion "13.0.0"  "Maverick"        "June 11, 2012"       "OS X v10.9"                             ""
declareDarwinVersion "13.1.0"  "Maverick"        "January 16 2014"     "OS X v10.9.2"                           ""
declareDarwinVersion "14.0.0"  "iOS 7"           "September 18, 2013"  "iOS 7"                                  ""
declareDarwinVersion "14.0.0"  "Yosemite"        "2014"                "OS X v10.10.1"                          ""
declareDarwinVersion "14.5.0"  "Yosemite"        "2015"                "OS X v10.10.5"                          ""
declareDarwinVersion "15.0.0"  "El Capitan"      "September 15, 2015"  "OS X v10.11.0"                          ""
declareDarwinVersion "15.6.0"  "El Capitan"      "July 18, 2016"       "OS X v10.11.6"                          ""
# We filter on "OS X" so keep "OS X", not "macOS":
declareDarwinVersion "16.0.0"  "Sierra"          "September 13, 2016"  "OS X v10.12.0"                          "build 16A323"
declareDarwinVersion "16.1.0"  "Sierra"          "October 24, 2016"    "OS X v10.12.1"                          "build 16B2555 16B2657"
declareDarwinVersion "16.3.0"  "Sierra"          "December 13, 2016"   "OS X v10.12.2"                          "build 16C67 16C68"
declareDarwinVersion "16.4.0"  "Sierra"          "December 20, 2016"   "OS X v10.12.3 Beta 2"                   "build 16D17a"

# http://en.wikipedia.org/wiki/Darwin_%28operating_system%29#Release_history


function get_keys () {
    local file="$1"
    (
        IFS='='
        while read variable value ; do
            echo "$variable"
        done < "$file"
    )
}

function get_value () {
    local file="$1"
    local key="$2"
    # safely read a file that contains VARIABLE="value" lines.
    local unescaped
    (
        IFS='='
        while read variable value ; do
            if [ "$variable" = "$key" ] ; then
                case "$value" in
                \"*\")
                    unescaped="${value//\\\"}"
                    echo "${unescaped//\"}"
                    ;;
                *)
                    echo "$value"
                    ;;
                esac
                break
            fi
        done < "$file"
    )
}


function distribution () {
    local root="$1" ; shift
    # DOES:   Identify the system, distribution and release where we run.
    #         Prints a line with three corresponding keywords.
    # STATUS: 0 upon success.


    # Sys-V systems have uname. It may also exist as an add-on on other systems.
    local systeme=
    local distrib="unknown"
    local release="unknown"
    local codename=""
    local macosxVersion=''
    systeme=$(uname -o 2>/dev/null) || systeme=$(uname 2>/dev/null) || systeme="unknown"


    case "$systeme" in

    GNU/Linux|Linux)
        if [ -e "$root"/etc/os-release ] ; then
            distrib=$(get_value "$root"/etc/os-release ID)
            release=$(get_value "$root"/etc/os-release VERSION_ID)
            # Checked with Ubuntu 13.04
            # Checked with Debian 7.2

        elif [ -e "$root"/etc/mandrake-release ] ; then
            distrib=mandrake
            release=$(awk '{print $4}' < "$root"/etc/mandrake-release)
            # Checked with Linux Mandrake 6.1

        elif [ -e "$root"/etc/redhat-release ] ; then
            distrib=redhat
            release=$(awk '{print $4}' < "$root"/etc/redhat-release)
            # Checked with Linux RedHat 6.1, 6.2, 7.0
            # Checked with Linux Immunix 6.2.
            # There seems to be no way to differenciate
            # a RedHat 6.2 from an Immunix 6.2.

        elif [ -e "$root"/etc/conectiva-release ] ; then
            distrib=conectiva
            release=$(awk '{print $3}' < "$root"/etc/conectiva-release)
            # Checked with Linux Conectiva 6.5

        elif [ -e "$root"/etc/SuSE-release ] ; then
            distrib=SuSE
            release=$(grep VERSION "$root"/etc/SuSE-release|sed -e 's/.*= *//')
            # Checked with Linux SuSE 7.0, 7.1

        elif [ -e "$root"/etc/debian_version ] ; then
            distrib=debian
            release="$(cat "$root"/etc/debian_version)"
            # Checked with Linux DebIan 5.0.4
        elif [ -e "$root"/etc/gentoo-release ] ; then
            distrib=gentoo
            release=$(awk '{print $NF}' < "$root"/etc/gentoo-release)
            # Checked with Linux gentoo 1.12.9, 1.12.13

        else
            distrib=unknown
            release=unknown
        fi

        case "$distrib" in
        debian)
            release="$(cat "$root"/etc/debian_version)"
            case "$release" in
            10.[0-9]*) codename=buster ;;
            9.[0-9]*) codename=stretch ;;
            8.[0-9]*) codename=jessie ;;
            7.[0-9]*) codename=wheezy ;;
            6.[0-9]*) codename=squeeze ;;
            5.[0-9]*) codename=lenny ;;
            4.[0-9]*) codename=etch ;;
            3.1) codename=sarge ;;
            3.0) codename=woody ;;
            2.2) codename=potato ;;
            2.1) codename=slink ;;
            2.0) codename=hamm ;;
            1.3) codename=bo ;;
            1.2) codename=rex ;;
            *) codename="" ;;
            esac
            ;;
        *)
            true
            ;;
        esac

        ;;

    NEXTSTEP)
        # A special case, where a uname has been installed on NeXTSTEP.
        distrib=NeXT
        release=$(uname -r) || release="unknown"
        ;;

    Darwin)
        release=$(hostinfo | awk '/Darwin Kernel Version/{printf "%s",substr($4,1,index($4,":")-1);}')
        if [ -r "$root"/System/Library/Frameworks/AppKit.framework/AppKit ] ; then
            distrib=apple
            macosxVersion=$(macOSXVersionFromDarwinVersion $release)
            codename=$(macOSXCodenameFromDarwinVersion $release)
        fi
        # [pascal@localhost:/Users/pascal]$ hostinfo
        # Mach kernel version:
        #          Darwin Kernel Version 1.3.7:
        # Sat Jun  9 11:12:48 PDT 2001; root:xnu/xnu-124.13.obj~1/RELEASE_PPC
        #
        #
        # Kernel configured for up to 2 processors.
        # 1 processor is physically available.
        # Processor type: ppc7400 (PowerPC 7400)
        # Processor active: 0
        # Primary memory available: 1024.00 megabytes.
        # Default processor set: 54 tasks, 125 threads, 1 processors
        # Load average: 0.70, Mach factor: 0.74
        ;;
    unknown)

        # Mach systems:
        h=$(hostinfo) || h="unknown"

        case "$h" in
        Mach*)
            # Well, this works on NeXTSTEP Mach:
            distrib=$(echo "$h" | awk '{print $4}')
            release=$(echo "$h" | awk '{print $6}')
            ;;
        *)
            ;;
        esac
        ;;

    *)
        release=$(uname  -r)
        ;;
    esac


    echo "$systeme" "$distrib" "$release" "${codename// /_}" "${macosxVersion// /_}"
} #distribution

pname="$(basename "$0")"
root=
for arg ; do
    case "$arg" in
    -h|--help) printf "%s usage:\n\n    %s [/root/directory] | read system distribution release rest\n\n" "$pname" "$pname" ; exit 0 ;;
    *)
        if [ "$root" = "" ] ; then
            root="$arg"
        else
            "$0" -h ; exit 1
        fi
        ;;
    esac
done
if [ "$root" != "" ] ; then
    if [ ! -d "$root" ] ; then
        printf "%s error: %s is not a directory.\n" "$pname" "$root"
    fi
fi
distribution "$root"

#### THE END ####
