;;;; -*- mode:lisp;coding:utf-8 -*-
;;;;**************************************************************************
;;;;FILE:               script.lisp
;;;;LANGUAGE:           Common-Lisp
;;;;SYSTEM:             Common-Lisp
;;;;USER-INTERFACE:     CLI
;;;;DESCRIPTION
;;;;    
;;;;    This file defines utilities for lisp scripts.
;;;;
;;;;AUTHORS
;;;;    <PJB> Pascal J. Bourguignon <pjb@informatimago.com>
;;;;MODIFICATIONS
;;;;    2009-11-29 <PJB> Extracted from logs scripts.
;;;;    2009-07-27 <PJB> Merged log-to-script in here.
;;;;    2009-07-23 <PJB> Created.
;;;;BUGS
;;;;LEGAL
;;;;    GPL
;;;;    
;;;;    Copyright Pascal J. Bourguignon 2009 - 2012
;;;;    
;;;;    This program is free software; you can redistribute it and/or
;;;;    modify it under the terms of the GNU General Public License
;;;;    as published by the Free Software Foundation; either version
;;;;    2 of the License, or (at your option) any later version.
;;;;    
;;;;    This program is distributed in the hope that it will be
;;;;    useful, but WITHOUT ANY WARRANTY; without even the implied
;;;;    warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
;;;;    PURPOSE.  See the GNU General Public License for more details.
;;;;    
;;;;    You should have received a copy of the GNU General Public
;;;;    License along with this program; if not, write to the Free
;;;;    Software Foundation, Inc., 59 Temple Place, Suite 330,
;;;;    Boston, MA 02111-1307 USA
;;;;**************************************************************************
(in-package "COMMON-LISP-USER")

;; Clean the packages imported into COMMON-LISP-USER:
(mapc (lambda (package) (unuse-package package "COMMON-LISP-USER"))
      (set-difference
       (copy-seq (package-use-list "COMMON-LISP-USER"))
       (delete nil (list ;; A list of all possible "CL" packages:
                    (find-package "COMMON-LISP")
                    (find-package "IMAGE-BASED-COMMON-LISP")))))

;;;---------------------------------------------------------------------------
;;;

(defpackage "COM.INFORMATIMAGO.CLISP.VERSION"
  (:nicknames "VERSION")
  (:use "COMMON-LISP")
  (:export
   "CLISP-VERSION"
   "VERSION="    "VERSION<"    "VERSION<="
   "RT-VERSION=" "RT-VERSION<" "RT-VERSION<="))
(in-package "COM.INFORMATIMAGO.CLISP.VERSION")


(defun clisp-version (&optional (version-string (lisp-implementation-version)))
  (loop
     :with r = '()
     :with start = 0
     :do (multiple-value-bind (n p)
             (parse-integer version-string :start start :junk-allowed t)
           (push n r)
           (if (or (<= (length version-string) p)
                   (char= #\space (aref version-string p)))
               (return-from clisp-version (nreverse r))
               (setf start (1+ p))))))

(defun version= (a b)
  (equal (if (stringp a) (clisp-version a) a)
         (if (stringp b) (clisp-version b) b)))

(defun version< (a b)
  (setf a (if (stringp a) (clisp-version a) a)
        b (if (stringp b) (clisp-version b) b))
  (cond
    ((null a)            (not (null b)))
    ((null b)            nil)
    ((< (car a) (car b)) t)
    ((= (car a) (car b)) (version< (cdr a) (cdr b)))
    (t                   nil)))

(defun version<= (a b)
  (setf a (if (stringp a) (clisp-version a) a)
        b (if (stringp b) (clisp-version b) b))
  (or (version= a b) (version< a b)))

(defun rt-version=  (a b) (if (version=  a b) '(and) '(or)))
(defun rt-version<  (a b) (if (version<  a b) '(and) '(or)))
(defun rt-version<= (a b) (if (version<= a b) '(and) '(or)))


;;;---------------------------------------------------------------------------
;;;
;;;

(in-package "COMMON-LISP-USER")

(defpackage "COM.INFORMATIMAGO.COMMON-LISP.SCRIPT"
  (:nicknames "SCRIPT")
  (:use "COMMON-LISP")
  (:export "PNAME" "*PROGRAM-NAME*" "*VERBOSE*" "*DEBUG*"

           "WITHOUT-OUTPUT" "WITH-PAGER"
           "REDIRECTING-STDOUT-TO-STDERR" 
           "RELAUCH-WITH-KFULL-LINKSET-IF-NEEDED"
           
           "DEFINE-OPTION" "CALL-OPTION-FUNCTION"
           "PARSE-OPTIONS" "MAIN"
           "SET-DOCUMENTATION-TEXT"
           "*BASH-COMPLETION-HOOK*"

           ;; Utilities:
           "FIND-DIRECTORIES"
           "CONCAT" "MAPCONCAT"

           "GETPID" "SHELL-QUOTE-ARGUMENT" "SHELL" "EXECUTE" "RUN-PROGRAM"
           "UNAME" "COPY-FILE"  "MAKE-SYMBOLIC-LINK" "MAKE-DIRECTORY"
           
           ;; Exit codes:
           "EX--BASE" "EX--MAX" "EX-CANTCREAT" "EX-CONFIG"
           "EX-DATAERR" "EX-IOERR" "EX-NOHOST" "EX-NOINPUT"
           "EX-NOPERM" "EX-NOUSER" "EX-OK" "EX-OSERR" "EX-OSFILE"
           "EX-PROTOCOL" "EX-SOFTWARE" "EX-TEMPFAIL" "EX-UNAVAILABLE"
           "EX-USAGE"))
(in-package "COM.INFORMATIMAGO.COMMON-LISP.SCRIPT")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;

(defvar *program-name* "<unnamed>"
  "Name of the program.
If available we use the actual program name (from *LOAD-PATHNAME*),
otherwise we fallback to *DEFAULT-PROGRAM-NAME*.")

(defvar *verbose* nil
  "Adds some trace output.")

(defvar *debug* nil
  "Errors break into the debugger.")

#-(or use-ppcre use-regexp) (push #-(and) :use-ppcre
                                  #+(and) :use-regexp
                                  *features*)

;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;

(defun relauch-with-kfull-linkset-if-needed (thunk)
  ;; If the version of clisp requires -Kfull to have linux, then let's call it with -Kfull…
  (multiple-value-bind (res err) (ignore-errors (funcall thunk))
    (when err
      (let* ((argv  (ext:argv))
             (largv (length argv))
             (args  ext:*args*)
             (largs (length args))
             (name  (elt argv (- largv largs 1))))
        (if (find "-Kfull" argv :test (function string=))
            (error err)
            (ext:exit
             (or (ext:run-program "/usr/bin/clisp"
                                  :arguments (append '("-ansi" "-q" "-E" "utf-8" "-Kfull")
                                                     (cons name args))
                                  :wait t
                                  #+linux :may-exec  #+linux t
                                  #+win32 :indirectp #+win32 nil)
                 0)))))))

(relauch-with-kfull-linkset-if-needed (lambda () (require "linux")))



(defmacro redirecting-stdout-to-stderr (&body body)
  (let ((verror  (gensym))
        (voutput (gensym)))
   `(let* ((,verror  nil)
           (,voutput (with-output-to-string (stream)
                       (let ((*standard-output* stream)
                             (*error-output*    stream)
                             (*trace-output*    stream))
                         (handler-case (progn ,@body)
                           (error (err) (setf ,verror err)))))))
      (when ,verror
        (terpri *error-output*)
        (princ ,voutput *error-output*)
        (terpri *error-output*)
        (princ ,verror *error-output*)
        (terpri *error-output*)
        (terpri *error-output*)
        #-testing-script (ext:exit ex-software)))))

(defun getpid ()
  (or (ignore-errors (find-symbol "getpid"     "LINUX"))
      (ignore-errors (find-symbol "PROCESS-ID" "OS"))
      (ignore-errors (find-symbol "PROCESS-ID" "SYSTEM"))))


(defun report-the-error (err string-stream)
  (let ((log-path (format nil "/tmp/~A.~D.errors"
                          (pathname-name (pname))
                          (let ((getpid (getpid)))
                            (if getpid
                                (funcall getpid)
                                "nopid")))))
    (with-open-file (log-stream log-path
                                :direction :output
                                :if-exists :supersede
                                :if-does-not-exist :create)
      (format log-stream "~A GOT AN ERROR: ~A~%~80,,,'-<~>~%~A~%"
              (pname) err
              (get-output-stream-string string-stream)))
    (format *error-output* "~A: ~A~%  See ~A~%" (pname) err log-path)
    (finish-output *error-output*)
    (ext:exit ex-software)))


(defmacro without-output (&body body)
  `(prog1 (values)
     (with-output-to-string (net)
       (handler-case
           (let ((*standard-output* net)
                 (*error-output*    net)
                 (*trace-output*    net))
             ,@body)
         (error (err) (report-the-error err net))))))




(defmacro with-pager ((&key lines) &body body)
  "
Executes the BODY, redirecting *STANDARD-OUTPUT* to a pager.

If no option is given, use the system pager obtained from the
environment variable PAGER.  If none is defined, then no pager is
used.

The following is NOT IMPLEMENTED YET:

If an option is given, then it defines a local pager.

LINES     Number of line to output in a single chunk.
          After this number of line has been written,
          some user input is required to further display lines.
"
  (when lines
    (error "~S: Sorry :LINES is not implemented yet." 'with-pager))
  ;; (print (list (version:clisp-version)
  ;;              (version:rt-version<= "2.48" (version:clisp-version))))
  #+#.(version:rt-version<= "2.44" (version:clisp-version))
  `(progn ,@body)
  #-#.(version:rt-version<= "2.44" (version:clisp-version))
  (let ((pager (ext:getenv "PAGER")))
    (if pager
        (let ((pager-stream (gensym)))
          `(let ((,pager-stream (ext:make-pipe-output-stream
                                 ,pager
                                 :external-format charset:utf-8
                                 :buffered nil)
                   ;; (ext:run-program ,pager
                   ;;                  :input :stream
                   ;;                  :output :terminal
                   ;;                  :wait nil)
                   ))
             (unwind-protect
                  (let ((*standard-output* ,pager-stream))
                    ,@body)
               (close ,pager-stream))))
        `(progn ,@body))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;


(defun shell-quote-argument (argument)
  "
DO:      Quote an argument for passing as argument to an inferior shell.
RETURN:  A string containing the quoted argument.
"
  (do ((i 0 (1+ i))
       (ch)
       (result '()))
      ((<= (length argument) i) (coerce (nreverse result) 'string))
    (setq ch (char argument i))
    (unless (or (char= (character "-") ch)
                (char= (character ".") ch)
                (char= (character "/") ch)
                (and (char<= (character "A") ch) (char<= ch (character "Z")))
                (and (char<= (character "a") ch) (char<= ch (character "z")))
                (and (char<= (character "0") ch) (char<= ch (character "9"))))
      (push (character "\\") result))
    (push ch result)))


(defun shell   (command)
  "
SEE ALSO:    EXECUTE.
"
  (ext:shell command))


(defun execute (&rest command)
  "
RETURN:     The status returned by the command.
SEE ALSO:   SHELL
"
  (ext:run-program (car command)
    :arguments (cdr command)
    :input :terminal :output :terminal))


(defun copy-file (file newname &optional ok-if-already-exists keep-time)
  "
IMPLEMENTATION: The optional argument is not implemented.

Copy FILE to NEWNAME.  Both args must be strings.
If NEWNAME names a directory, copy FILE there.
Signals a `file-already-exists' error if file NEWNAME already exists,
unless a third argument OK-IF-ALREADY-EXISTS is supplied and non-nil.
A number as third arg means request confirmation if NEWNAME already exists.
This is what happens in interactive use with M-x.
Fourth arg KEEP-TIME non-nil means give the new file the same
last-modified time as the old one.  (This works on only some systems.)
A prefix arg makes KEEP-TIME non-nil.
"
  (declare (ignore ok-if-already-exists keep-time))
  (execute "cp" (shell-quote-argument file)  (shell-quote-argument newname)))


(defun make-symbolic-link (filename linkname &optional ok-if-already-exists)
  "
IMPLEMENTATION: The optional argument is not implemented.

Make a symbolic link to FILENAME, named LINKNAME.  Both args strings.
Signals a `file-already-exists' error if a file LINKNAME already exists
unless optional third argument OK-IF-ALREADY-EXISTS is non-nil.
A number as third arg means request confirmation if LINKNAME already exists.
"
  (declare (ignore ok-if-already-exists))
  (/= 0 (linux:|symlink| filename linkname)))


(defun make-directory (*path* &optional (parents nil))
  "
Create the directory *PATH* and any optionally nonexistent parents dirs.
The second (optional) argument PARENTS says whether
to create parents directories if they don't exist.
"
  (if parents
      (ensure-directories-exist (concatenate 'string *path* "/.") :verbose nil)
      (linux:|mkdir| *path*  511 #| #o777 |# ))
  (ext:probe-directory (if (char= (char *path* (1- (length *path*)))
                                  (character "/"))
                           *path* (concatenate 'string *path* "/"))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; From /usr/include/sysexits.h (Linux)
;;;

(defconstant ex-ok            0   "successful termination")


(defconstant ex--base         64  "base value for error messages")


(defconstant ex-usage         64  "command line usage error
    The command was used incorrectly, e.g., with
    the wrong number of arguments, a bad flag, a bad
    syntax in a parameter, or whatever.") ;;EX-USAGE

(defconstant ex-dataerr       65  "data format error
    The input data was incorrect in some way.
    This should only be used for user's data & not
    system files.") ;;EX-DATAERR

(defconstant ex-noinput       66  "cannot open input
    An input file (not a system file) did not
    exist or was not readable.  This could also include
    errors like \"No message\" to a mailer (if it cared
    to catch it).") ;;EX-NOINPUT

(defconstant ex-nouser        67  "addressee unknown
    The user specified did not exist.  This might
    be used for mail addresses or remote logins.
    ") ;;EX-NOUSER

(defconstant ex-nohost        68  "host name unknown
    The host specified did not exist.  This is used
    in mail addresses or network requests.") ;;EX-NOHOST

(defconstant ex-unavailable   69  "service unavailable
    A service is unavailable.  This can occur
    if a support program or file does not exist.  This
    can also be used as a catchall message when something
    you wanted to do doesn't work, but you don't know
    why.") ;;EX-UNAVAILABLE

(defconstant ex-software      70  "internal software error
    An internal software error has been detected.
    This should be limited to non-operating system related
    errors as possible.") ;;EX-SOFTWARE

(defconstant ex-oserr         71  "system error (e.g., can't fork)
    An operating system error has been detected.
    This is intended to be used for such things as \"cannot
    fork\", \"cannot create pipe\", or the like.  It includes
    things like getuid returning a user that does not
    exist in the passwd file.") ;;EX-OSERR

(defconstant ex-osfile        72  "critical OS file missing
    Some system file (e.g., /etc/passwd, /etc/utmp,
    etc.) does not exist, cannot be opened, or has some
    sort of error (e.g., syntax error).") ;;EX-OSFILE

(defconstant ex-cantcreat     73  "can't create (user) output file
    A (user specified) output file cannot be created.") ;;EX-CANTCREAT

(defconstant ex-ioerr         74  "input/output error
     An error occurred while doing I/O on some file.") ;;EX-IOERR

(defconstant ex-tempfail      75  "temp failure; user is invited to retry
    temporary failure, indicating something that
    is not really an error.  In sendmail, this means
    that a mailer (e.g.) could not create a connection,
    and the request should be reattempted later.") ;;EX-TEMPFAIL

(defconstant ex-protocol      76  "remote error in protocol
    the remote system returned something that
    was \"not possible\" during a protocol exchange.") ;;EX-PROTOCOL

(defconstant ex-noperm        77  "permission denied
    You did not have sufficient permission to
    perform the operation.  This is not intended for
    file system problems, which should use NOINPUT or
    CANTCREAT, but rather for higher level permissions.") ;;EX-NOPERM

(defconstant ex-config        78  "configuration error")


(defconstant ex--max          78  "maximum listed value")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; OPTIONS PROCESSING
;;;


(defun pname ()
  "This function can be used to set *program-name* in
the main script  (setf script:*program-name* (script:pname))
"
  (file-namestring (or *load-pathname* *program-name*)))


(defparameter *options*
  (make-hash-table :test (function equal))
  "The dictionary of options.")


(defstruct option
  keys arguments documentation function)


(defun split-string (string &optional (separators " "))
  "
NOTE:   current implementation only accepts as separators
        a string containing literal characters.
"
  (unless (simple-string-p string)     (setq string     (copy-seq string)))
  (unless (simple-string-p separators) (setq separators (copy-seq separators)))
  (let ((chunks  '())
        (position 0)
        (nextpos  0)
        (strlen   (length string)) )
    (declare (type simple-string string separators))
    (loop while (< position strlen)
       do
       (loop while (and (< nextpos strlen)
                        (not (position (char string nextpos) separators)))
          do (setq nextpos (1+ nextpos))
          )
       (push (subseq string position nextpos) chunks)
       (setq position (1+ nextpos))
       (setq nextpos  position)
       )
    (nreverse chunks)))


(defun q&d-parse-parameters (parameters)
  "Parses (mandatory &optional optionals... &rest rest &key key...)"
  (loop
     :with mandatories = '()
     :with optionals   = '()
     :with rest        = nil
     :with keys        = '()
     :with state       = :mandatory
     :with params      = parameters
     :for param = (first params)
     :while params
     :do (ecase state
           ((:mandatory)
            (case param
              ((&optional) (setf state :optional))
              ((&rest)     (setf state :rest))
              ((&key)      (setf state :key))
              (otherwise (push param mandatories)))
            (pop params))
           ((:optional)
            (case param
              ((&optional) (error "&OPTIONAL given more than once in ~S" parameters))
              ((&rest)     (setf state :rest))
              ((&key)      (setf state :key))
              (otherwise (push param optionals)))
            (pop params))
           ((:rest)
            (case param
              ((&optional) (error "&OPTIONAL given after &REST in ~S" parameters))
              ((&rest)     (error "&REST given twice in ~S" parameters))
              ((&key)      (setf state :key))
              (otherwise   (setf state :after-rest
                                 rest param)))
            (pop params))
           ((:after-rest)
            (case param
              ((&optional) (error "&OPTIONAL given after &REST in ~S" parameters))
              ((&rest)     (error "&REST given after &REST in ~S" parameters))
              ((&key)      (setf state :key))
              (otherwise   (error "Several &REST parameters given in ~S" parameters)))
            (pop params))
           ((:key)
            (case param
              ((&optional) (error "&OPTIONAL given after &KEY in ~S" parameters))
              ((&rest)     (error "&REST given after &KEY in ~S" parameters))
              ((&key)      (setf state :key))
              (otherwise   (push param keys)))
            (pop params)))
     :finally (return (values (nreverse mandatories)
                              (nreverse optionals)
                              rest
                              (nreverse keys)))))


(defun keywordize (string-designator)
  (intern (string string-designator) (load-time-value (find-package "KEYWORD"))))


(defun q&d-arguments (mandatories optionals rest keys)
  "
BUG: when the optionals or keys have a present indicator,
     we just ignore it and build a list that will pass
     the default value anyways...
" 
  (assert (every (function symbolp) mandatories))
  (append mandatories
          (mapcar (lambda (opt)
                    (etypecase opt
                      (cons   (first opt))
                      (symbol opt)))
                  optionals)
          (when rest (list rest))
          (mapcan (lambda (key)
                    (etypecase key
                      (cons  (etypecase (first key)
                               (symbol (list (keywordize (first key)) (first key)))
                               (cons   (list (second (first key)) (first (first key))))))
                      (symbol (list (keywordize key) key))))
                  keys)))


(defun wrap-option-function (keys option-arguments docstring option-function)
  (let ((vargs (gensym)))
    (multiple-value-bind (mandatories optionals rest keys-args) (q&d-parse-parameters option-arguments)
      (setf *print-circle* nil)
      (make-option
       :keys keys
       :arguments option-arguments
       :function (compile (make-symbol (format nil "~:@(~A-WRAPPER~)" (first keys)))
                          `(lambda (option-key ,vargs)
                             (let ((nargs (length ,vargs)))
                               (if (<= ,(length mandatories) nargs)
                                   ,(cond
                                     (rest
                                      `(destructuring-bind ,option-arguments ,vargs
                                         (funcall ',option-function ,@(q&d-arguments mandatories
                                                                                     optionals
                                                                                     rest
                                                                                     keys-args))
                                         nil))
                                     (keys-args
                                      (error "An option cannot have &key parameters without a &rest parameter. ~@
                                              Invalid option parameters: ~S" option-arguments))
                                     (t
                                      (let ((vremaining (gensym)))
                                        `(destructuring-bind (,@option-arguments &rest ,vremaining) ,vargs
                                           (funcall ',option-function ,@(q&d-arguments mandatories
                                                                                       optionals
                                                                                       rest
                                                                                       keys-args))
                                           ,vremaining))))
                                   (let ((missing-count (- ,(length mandatories) nargs))
                                         (missing-args  (subseq ',mandatories nargs)))
                                     (error "option ~A is missing ~:[an ~*~;~A ~]argument~:*~p: ~{~A ~}"
                                            option-key
                                            (< 1 missing-count) missing-count
                                            missing-args))))))
       :documentation (split-string docstring (string #\newline))))))


(defun call-option-function (option-key arguments &optional undefined-argument)
  (let* ((option (gethash option-key *options*)))
    (cond
      (option             (funcall (option-function option) option-key arguments))
      (undefined-argument (funcall undefined-argument option-key arguments))
      (t                  (error "Unknown option ~A ; try: ~A help" option-key (pname))))))


(defmacro define-option (names parameters &body body)
  "
DO:         Define a new option for the scirpt.
NAMES:      A list designator of option names (strings
            such as \"-a\" \"--always\").
PARAMETERS: A list of option parameters.  The names of
            these parameters must be descriptive as they
            are used to build the usage help text.
BODY:       The code implementing this option.
RETURN:     The lisp-name of the option (this is a symbol
            named for the first option name).
"
  (let* ((main-name   (if (listp names)
                          (first names)
                          names))
         (other-names (if (listp names)
                          (rest names)
                          '()))
         (lisp-name   (intern (string-upcase main-name)))
         (docstring   (if (and (stringp (first body)) (rest body))
                          (first body)
                          nil))
         (body        (if (and (stringp (first body)) (rest body))
                          (rest body)
                          body)))
    `(progn
       (setf (gethash ',main-name *options*)
             (wrap-option-function ',(cons main-name other-names)
                                   ',parameters
                                   ',docstring
                                   (lambda ,(remove '&rest parameters)
                                     ,docstring
                                     (block ,lisp-name
                                       ,@body))))
       ,@(mapcar (lambda (other-name)
                   `(setf (gethash ',other-name *options*) (gethash ',main-name *options*)))
                 other-names)
       ',lisp-name)))


(defvar *documentation-text* "")

(defun set-documentation-text (text)
  (setf *documentation-text* text))

(defun option-list ()
  (let ((options '()))
    (maphash (lambda (key option)
               (declare (ignore key))
               (pushnew option options))
             *options*)
    options))

(define-option ("help" "-h" "--help") ()
  "Give this help."
  (with-pager ()
      (let ((options (option-list)))
        (format t "~2%~A options:~2%" (pname))
        (dolist (option (sort options (function string<)
                              :key (lambda (option) (first (option-keys option)))))
          (format t "    ~{~A~^ | ~}  ~:@(~{~A ~}~)~%~@[~{~%        ~A~}~]~2%"
                  (option-keys option)
                  (option-arguments option)
                  (option-documentation option)))
        (format t "~A~%" *documentation-text*))))



;; TODO: See if we couldn't simplify it, perhaps with complete -C.

(defun list-all-option-keys ()
  (let ((keys '()))
    (dolist (option (option-list))
      (dolist (key (option-keys option))
        (push key keys)))
    keys))

(defun completion-option-prefix (prefix)
  (dolist (key (remove-if-not (lambda (key)
                                (and (<= (length prefix) (length key))
                                     (string= prefix key :end2 (length prefix))))
                              (list-all-option-keys)))
    (format t "~A~%" key))
  (finish-output))

(defun completion-all-options ()
  (dolist (key (list-all-option-keys))
    (format t "~A~%" key))
  (finish-output))

(defvar *bash-completion-hook* nil
  "A function (lambda (index words) ...)
that will print the completion and return true, or do nothing and return nil.")

(define-option ("--bash-completions") (index &rest words)
  "Implement the auto-completion of arguments.
This option is designed to be invoked from the function generated by
the '--bash-completion-function' option.  There should be no need to
use directly.
"
  (let ((index (parse-integer index :junk-allowed t)))
    (unless (and *bash-completion-hook*
                 (funcall *bash-completion-hook* index words))
      (if index
          (completion-option-prefix (elt words index))
          (completion-all-options))))
  (ext:exit 0))


(define-option ("--bash-completion-function") ()
  "Write two bash commands (separated by a semi-colon) to create a
bash function used to do auto-completion of command arguments.
Use it with:

       eval $($COMMAND  --bash-completion-function) 

and then typing TAB on the command line after the command name will
autocomplete argument prefixes.
"
  (format t "function completion_~A(){ ~
COMPREPLY=( $(~:*~A --bash-completions \"$COMP_CWORD\" \"${COMP_WORDS[@]}\") ) ; } ;~
complete -F completion_~:*~A ~:*~A~%"
          *program-name*)
  (ext:exit 0))



(defun parse-options (arguments &optional default undefined-argument)
  (flet ((process-arguments ()
           (cond
             (arguments
              (loop
                 :while arguments
                 :do (setf arguments (call-option-function (pop arguments) arguments undefined-argument))))
             (default
              (funcall default)))))
    (if *debug*
        (process-arguments)
        (handler-case (process-arguments)
          (error (err)
            (format *error-output* "~%ERROR: ~A~%" err)
            ;; TODO: select different sysexits codes depending on the error class.
            (return-from parse-options ex-software)))))
  0)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;

(defun not-implemented-here (function-name)
  (error "How to implement ~S in ~S"
         function-name
         (lisp-implementation-type)))


(defun prepare-options (options)
  (mapcar (lambda (option)
            (typecase option
              (keyword (format nil "-~(~A~)" option))
              (symbol  (string-downcase option))
              (string  option)
              (t       (prin1-to-string option))))
          options))



(defun shell  (command &rest arguments)
  #+clisp (ext:shell (format nil command arguments))
  #-clisp (not-implemented-here 'shell))


(defun run-program (program arguments &key (input :terminal) (output :terminal)
                    (if-output-exists :error) (wait t))
  "
RETURN:     The status returned by the command.
SEE ALSO:   SHELL
"
  #+clisp (ext:run-program program
                           :arguments arguments
                           :input input :output output
                           :if-output-exists if-output-exists
                           :wait wait)
  #-clisp (not-implemented-here 'run-program))


(defun uname (&rest options)
  "Without OPTIONS, return a keyword naming the system (:LINUX, :DARWIN, etc).
With options, returns the first line output by uname(1)."
  (with-open-stream (uname (run-program "uname" (prepare-options options)
                                        :input nil
                                        :output :stream
                                        :wait t))
    (values (if options
                (read-line uname)
                (intern (string-upcase (read-line uname))
                        "KEYWORD")))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;  Some emacs style functions.
;;;

(defun find-directories (rootpath)
  "Return a list of recursive subdirectories starting from ROOTPATH
that are accessible by the user."
  (directory (merge-pathnames (make-pathname :directory '(:relative :wild-inferiors)
                                             :name nil :type nil :version nil)
                              rootpath nil)))

(defun concat (&rest items) (apply (function concatenate) 'string items))

(defun mapconcat (function sequence separator)
  (etypecase sequence
    (list
     (if sequence
         (let* ((items (mapcar (lambda (item)
                                 (let ((sitem (funcall function item)))
                                   (if (stringp sitem)
                                       sitem
                                       (princ-to-string sitem))))
                               sequence))
                (ssepa (if (stringp separator)
                           separator
                           (princ-to-string separator)))
                (size (+ (reduce (function +) items :key (function length))
                         (* (length ssepa) (1- (length items)))))
                (result (make-array size :element-type 'character))
                (start  0))
           (replace result  (first items) :start1 start)
           (incf start (length (first items)))
           (dolist (item (rest items))
             (replace result ssepa :start1 start) (incf start (length ssepa))
             (replace result item  :start1 start) (incf start (length item)))
           result)
         ""))
    (vector
     (if (plusp (length sequence))
         (let* ((items (map 'vector (lambda (item)
                                      (let ((sitem (funcall function item)))
                                        (if (stringp sitem)
                                            sitem
                                            (princ-to-string sitem))))
                            sequence))
                (ssepa (if (stringp separator)
                           separator
                           (princ-to-string separator)))
                (size (+ (reduce (function +) items :key (function length))
                         (* (length ssepa) (1- (length items)))))
                (result (make-array size :element-type 'character))
                (start  0))
           (replace result (aref items 0) :start1 start) (incf start (length (aref items 0)))
           (loop
              :for i :from 1 :below (length items)
              :do (replace result ssepa :start1 start) (incf start (length ssepa))
              (replace result (aref items i) :start1 start) (incf start (length (aref items i))))
           result)
         ""))))




;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;;;
;; ;;; The main program, definition of the options
;; ;;;
;; 
;; 
;; (in-package "COMMON-LISP-USER")
;; (load (make-pathname :name "SCRIPT" :type "LISP" :version NIL :case :common
;;                      :defaults *load-pathname*))
;; (use-package "SCRIPT")
;; 
;; ;; (redirecting-stdout-to-stderr (load #p"/etc/gentoo-init.lisp"))
;; (redirecting-stdout-to-stderr
;;  (let ((*load-verbose* nil)
;;        (*compile-verbose* nil))
;;    (load (make-pathname :name ".clisprc" :type "lisp" :case :local
;;                         :defaults (user-homedir-pathname)))
;;    ;; (setf *features* (delete :testing-script *features*))
;;    ))
;; (redirecting-stdout-to-stderr (asdf:oos 'asdf:load-op :split-sequence)
;;                               (asdf:oos 'asdf:load-op :cl-ppcre))
;; 
;; ;; #-testing-script
;; (ext:exit (main ext:*args*))


;;;; THE END ;;;;
