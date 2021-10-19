(SETF (READTABLE-CASE *READTABLE*) :PRESERVE)

(DEFPARAMETER -Wall
  '(
    -Waddress   
    -Warray-bounds=1                       ; (only with -O2)  
    -Warray-parameter=2                    ; (C and Objective-C only) 
    -Wbool-compare  
    -Wbool-operation  
    -Wc++11-compat  -Wc++14-compat  
    -Wcatch-value                        ; (C++ and Objective-C++ only)  
    -Wchar-subscripts  
    -Wcomment  
    -Wduplicate-decl-specifier             ; (C and Objective-C only) 
    -Wenum-compare           ; (in C/ObjC; this is on by default in C++) 
    -Wformat   
    -Wformat-overflow  
    -Wformat-truncation  
    -Wint-in-bool-context  
    -Wimplicit                             ; (C and Objective-C only) 
    -Wimplicit-int                         ; (C and Objective-C only) 
    -Wimplicit-function-declaration        ; (C and Objective-C only) 
    -Winit-self                            ; (only for C++) 
    -Wlogical-not-parentheses 
    -Wmain                ; (only for C/ObjC and unless -ffreestanding)  
    -Wmaybe-uninitialized 
    -Wmemset-elt-size 
    -Wmemset-transposed-args 
    -Wmisleading-indentation               ; (only for C/C++) 
    -Wmissing-attributes 
    -Wmissing-braces                       ; (only for C/ObjC) 
    -Wmultistatement-macros  
    -Wnarrowing                            ; (only for C++)  
    -Wnonnull  
    -Wnonnull-compare  
    -Wopenmp-simd 
    -Wparentheses  
    -Wpessimizing-move                     ; (only for C++)  
    -Wpointer-sign  
    -Wrange-loop-construct                 ; (only for C++)  
    -Wreorder   
    -Wrestrict   
    -Wreturn-type  
    -Wsequence-point  
    -Wsign-compare                         ; (only in C++)  
    -Wsizeof-array-div 
    -Wsizeof-pointer-div 
    -Wsizeof-pointer-memaccess 
    -Wstrict-aliasing  
    -Wstrict-overflow=1  
    -Wswitch  
    -Wtautological-compare  
    -Wtrigraphs  
    -Wuninitialized  
    -Wunknown-pragmas  
    -Wunused-function  
    -Wunused-label     
    -Wunused-value     
    -Wunused-variable  
    -Wvla-parameter                        ; (C and Objective-C only) 
    -Wvolatile-register-var  
    -Wzero-length-bounds
    ))


(DEFPARAMETER -Wextra
  '(
    -Wclobbered  
    -Wcast-function-type  
    -Wdeprecated-copy                   ; (C++ only) 
    -Wempty-body  
    -Wenum-conversion                   ; (C only) 
    -Wignored-qualifiers 
    -Wimplicit-fallthrough=3 
    -Wmissing-field-initializers  
    -Wmissing-parameter-type            ; (C only)  
    -Wold-style-declaration             ; (C only)  
    -Woverride-init  
    -Wsign-compare                      ; (C only) 
    -Wstring-compare 
    -Wredundant-move                    ; (only for C++)  
    -Wtype-limits  
    -Wuninitialized  
    -Wshift-negative-value         ; (in C++03 and in C99 and newer)  
    -Wunused-parameter             ; (only with -Wunused or -Wall) 
    -Wunused-but-set-parameter     ; (only with -Wunused or -Wall)
    ))



(DEFPARAMETER *all-options*
  '(-Wabi -Wchar-subscripts -Wno-coverage-mismatch -Wno-cpp
    -Wdouble-promotion -Wduplicate-decl-specifier -Wformat -Wformat=n
    -Wformat=1 -Wformat -Wformat=2 -Wno-format-contains-nul
    -Wno-format-extra-args -Wformat-overflow -Wformat-overflow=level
    -Wformat-overflow -Wformat-overflow=1 -Wformat-overflow=2
    -Wno-format-zero-length -Wformat-nonliteral -Wformat-security
    -Wformat-signedness -Wformat-truncation -Wformat-truncation=level
    -Wformat-truncation -Wformat-truncation=1 -Wformat-truncation=2
    -Wformat-y2k -Wnonnull -Wnonnull -Wnonnull-compare -Wnonnull-compare
    -Wnull-dereference -Winit-self -Wno-implicit-int
    -Wno-implicit-function-declaration -Wimplicit -Wimplicit-fallthrough
    -Wimplicit-fallthrough -Wimplicit-fallthrough=n
    -Wimplicit-fallthrough=0 -Wimplicit-fallthrough=1
    -Wimplicit-fallthrough=2 -Wimplicit-fallthrough=3 -fallthrough
    -Wimplicit-fallthrough=4 -fallthrough -Wimplicit-fallthrough=5
    -Wno-if-not-aligned -Wignored-qualifiers -Wno-ignored-attributes
    -Wmain -Wmisleading-indentation -Wmissing-attributes
    -Wmissing-attributes -Wmissing-braces -Wmissing-include-dirs
    -Wno-missing-profile -Wno-mismatched-dealloc -Wmultistatement-macros
    -Wparentheses -Wsequence-point -Wno-return-local-addr -Wreturn-type
    -Wno-shift-count-negative -Wno-shift-count-overflow
    -Wshift-negative-value -Wno-shift-overflow -Wshift-overflow=n
    -Wshift-overflow=1 -Wshift-overflow=2 -Wswitch -Wswitch-default
    -Wswitch-enum -Wno-switch-bool -Wno-switch-outside-range
    -Wno-switch-unreachable -Wswitch-unreachable -Wsync-nand
    -Wunused-but-set-parameter -Wunused-but-set-variable
    -Wunused-function -Wunused-label -Wunused-local-typedefs
    -Wunused-parameter -Wno-unused-result -Wunused-variable
    -Wunused-const-variable -Wunused-const-variable=n
    -Wunused-const-variable=1 -Wunused-const-variable=2 -Wunused-value
    -Wunused -Wuninitialized -Wno-invalid-memory-model
    -Winvalid-memory-model -Wmaybe-uninitialized -Wunknown-pragmas
    -Wno-pragmas -Wno-prio-ctor-dtor -Wstrict-aliasing
    -Wstrict-aliasing=n -Wstrict-overflow -Wstrict-overflow=n
    -Wstrict-overflow=1 -Wstrict-overflow=2 -Wstrict-overflow=3
    -Wstrict-overflow=4 -Wstrict-overflow=5 -Wstring-compare
    -Wstring-compare -Wno-stringop-overflow -Wstringop-overflow
    -Wstringop-overflow=type -Wstringop-overflow -Wstringop-overflow=1
    -Wstringop-overflow=2 -Wstringop-overflow=3 -Wstringop-overflow=4
    -Wno-stringop-overread -Wno-stringop-truncation -Wsuggest-attribute
    -Wsuggest-attribute=pure -Wsuggest-attribute=const
    -Wsuggest-attribute=noreturn -Wmissing-noreturn
    -Wsuggest-attribute=malloc -Wsuggest-attribute=format
    -Wmissing-format-attribute -Wsuggest-attribute=cold -Walloc-zero
    -Walloc-size-larger-than=byte-size -Wno-alloc-size-larger-than
    -Walloca -Walloca-larger-than=byte-size
    -Walloca-larger-than=‘PTRDIFF_MAX’ -Wno-alloca-larger-than
    -Warith-conversion -Warray-bounds -Warray-bounds=n -Warray-bounds=1
    -Warray-bounds=2 -Warray-parameter -Warray-parameter=n
    -Warray-parameter=2 -Wattribute-alias=n -Wno-attribute-alias
    -Wattribute-alias=1 -Wattribute-alias=2 -Wattribute-alias
    -Wbool-compare -Wbool-operation -Wduplicated-branches
    -Wduplicated-cond -Wframe-address -Wno-discarded-qualifiers
    -Wno-discarded-array-qualifiers -Wno-incompatible-pointer-types
    -Wno-int-conversion -Wzero-length-bounds -Wno-div-by-zero
    -Wsystem-headers -Wtautological-compare -Wtrampolines -Wfloat-equal
    -Wtraditional -Wtraditional-conversion -Wdeclaration-after-statement
    -Wshadow -Wno-shadow-ivar -Wshadow=global -Wshadow=local
    -Wshadow=compatible-local -Wlarger-than=byte-size -Wno-larger-than
    -Wframe-larger-than=byte-size -Wno-frame-larger-than
    -Wno-free-nonheap-object -Wfree-nonheap-object
    -Wstack-usage=byte-size -Wstack-usage=‘PTRDIFF_MAX’ -Wno-stack-usage
    -Wunsafe-loop-optimizations -Wno-pedantic-ms-format -Wpointer-arith
    -Wno-pointer-compare -Wtsan -Wtype-limits -Wabsolute-value -Wcomment
    -Wcomments -Wtrigraphs -Wundef -Wexpansion-to-defined
    -Wunused-macros -Wno-endif-labels -Wbad-function-cast
    -Wc90-c99-compat -Wc99-c11-compat -Wc11-c2x-compat -Wc++-compat
    -Wc++11-compat -Wc++14-compat -Wc++17-compat -Wc++20-compat
    -Wno-c++11-extensions -Wno-c++14-extensions -Wno-c++17-extensions
    -Wno-c++20-extensions -Wno-c++23-extensions -Wcast-qual -Wcast-align
    -Wcast-align=strict -Wcast-function-type -Wwrite-strings -Wclobbered
    -Wconversion -Wdangling-else -Wdate-time -Wempty-body
    -Wno-endif-labels -Wenum-compare -Wenum-conversion
    -Wjump-misses-init -Wjump-misses-init -Wsign-compare
    -Wsign-conversion -Wfloat-conversion -Wno-scalar-storage-order
    -Wsizeof-array-div -Wsizeof-pointer-div -Wsizeof-pointer-memaccess
    -Wno-sizeof-array-argument -Wmemset-elt-size
    -Wmemset-transposed-args -Waddress -Wno-address-of-packed-member
    -Wlogical-op -Wlogical-not-parentheses -Waggregate-return
    -Wno-aggressive-loop-optimizations -Wno-attributes
    -Wno-builtin-declaration-mismatch -Wno-builtin-macro-redefined
    -Wstrict-prototypes -Wold-style-declaration -Wold-style-definition
    -Wmissing-parameter-type -Wmissing-prototypes -Wmissing-declarations
    -Wmissing-field-initializers -Wno-multichar -Wnormalized
    -Wno-attribute-warning -Wno-deprecated -Wno-deprecated-declarations
    -Wno-overflow -Wno-odr -Wopenacc-parallelism -Wopenmp-simd
    -Woverride-init -Wno-override-init-side-effects -Wpacked
    -Wnopacked-bitfield-compat -Wpacked-not-aligned -Wpadded
    -Wredundant-decls -Wrestrict -Wnested-externs -Winline
    -Wint-in-bool-context -Wno-int-to-pointer-cast
    -Wno-pointer-to-int-cast -Winvalid-pch -Wlong-long -Wvariadic-macros
    -Wno-varargs -Wvector-operation-performance -Wvla
    -Wvla-larger-than=byte-size -Wvla-larger-than=‘PTRDIFF_MAX’
    -Wno-vla-larger-than -Wvla-parameter -Wvla-parameter
    -Wvolatile-register-var -Wdisabled-optimization -Wpointer-sign
    -Wstack-protector -Woverlength-strings -Wunsuffixed-float-constants
    -Wno-lto-type-mismatch -Wno-designated-init ))

(VALUES (LENGTH *all-options*)
        (LENGTH (SET-DIFFERENCE *all-options* -Wall))
        (LENGTH (SET-DIFFERENCE *all-options* -Wextra))
        (LENGTH (SET-DIFFERENCE (SET-DIFFERENCE *all-options* -Wextra) -Wall))
        (SET-DIFFERENCE (SET-DIFFERENCE *all-options* -Wextra) -Wall))
292
233
274
217

(defparameter *added
  '(-Wformat-nonliteral
    -Wformat-security
    -Wformat-signedness
    -Wformat-truncation
    -Wnull-dereference
    -Wmissing-include-dirs
    -Wshift-overflow=2
    -Wswitch-default
    -Wswitch-enum
    -Wswitch-unreachable
    -Wunused-but-set-variable
    -Wunused-local-typedefs
    -Wunused-const-variable
    -Wunused
    -Wstringop-overflow=4
    -Walloc-zero
    -Walloca
    -Warith-conversion
    -Warray-bounds=2
    -Warray-parameter=2
    -Wduplicated-branches
    -Wduplicated-cond
    -Wframe-address
    -Wtrampolines
    -Wshadow
    -Wfree-nonheap-object
    -Wunsafe-loop-optimizations
    -Wconversion
    -Wpointer-arith
    -Wundef
    -Wexpansion-to-defined
    -Wunused-macros
    -Wbad-function-cast
    -Wdangling-else
    -Wdate-time
    -Wjump-misses-init
    -Wlogical-op
    -Waggregate-return
    -Wstrict-prototypes
    -Wmissing-prototypes
    -Wmissing-declarations
    -Wredundant-decls
    -Wnested-externs
    -Winline
    -fstack-protector
    -Wstack-protector
    -Woverlength-strings
    ))


