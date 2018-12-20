
sanitize_ld=(
        -fsanitize=leak
)

sanitize_cc=(
    -fsanitize=address
    -fsanitize=null
    -fsanitize=bounds
    -fsanitize=vla-bound
    -fsanitize=object-size

    -fsanitize=unreachable
    -fsanitize=return # C++ only

    # -fsanitize=shift
    # -fsanitize=shift-exponent
    # -fsanitize=shift-base
    # -fsanitize=integer-divide-by-zero
    # -fsanitize=signed-integer-overflow

    -fsanitize=float-divide-by-zero
    -fsanitize=float-cast-overflow
    -fsanitize=nonnull-attribute
    -fsanitize=returns-nonnull-attribute
    -fsanitize=bool
    -fsanitize=enum
    -fsanitize=vptr # C++ only


    -fsanitize-address-use-after-scope
    -fsanitize-undefined-trap-on-error
    -fstack-protector-all
    -fstack-check
)


function trim_spaces(){
    local string="$1"
    # ${a## } or ${a%% } doesn't work! (in bash 4.3).
    string="$(echo "$string" | sed -e 's/^ *//' -e 's/ *$//')"
    echo -n "${string}"
}

function trim_colons(){
    local string="$1"
    string="$(echo "$string" | sed -e 's/^:*//' -e 's/:*$//')"
    echo -n "${string}"
}

function with_gcc_8(){
    gcc_prefix="/usr/local/gcc"
    export PATH=$(trim_colons "${gcc_prefix}/bin:${PATH}")
    export CFLAGS=$(trim_spaces "-I${gcc_prefix}/include ${CFLAGS:-}")
    export CXXFLAGS=$(trim_spaces "-I${gcc_prefix}/include ${CXXFLAGS:-}")
    export LDFLAGS=$(trim_spaces "-L${gcc_prefix}/lib ${LDFLAGS:-}")
    export LD_LIBRARY_PATH="${gcc_prefix}/lib:/usr/local/lib:/usr/local/lib64:/usr/lib:/lib"
    export PKG_CONFIG_PATH="${gcc_prefix}/lib/pkgconfig:/usr/local/lib/pkgconfig:/usr/lib/pkgconfig:/usr/share/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig"
    libs="-L${gcc_prefix}/lib -L/usr/local/lib -L/usr/local/lib64 -L/lib -L/usr/lib"

    gcc -dumpversion
    case "$(gcc -dumpversion)" in
    [789]*)
        export CFLAGS=$(trim_spaces "${CFLAGS:-} ${sanitize_cc[*]} -g -g3 -ggdb -O0")
        export LDFLAGS=$(trim_spaces "${LDFLAGS:-} ${libs} ${sanitize_ld[*]}")
        ;;
    *)
        export CFLAGS=$(trim_spaces "${CFLAGS:-} -g -g3 -ggdb -O0")
        export LDFLAGS=$(trim_spaces "${LDFLAGS:-} ${libs}")
        ;;
    esac
}

with_gcc_8

