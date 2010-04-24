           ;; "SPLIT-STRING"
           ;; "STRING-MATCH" "MATCH-STRING" "MATCH-BEGINNING" "MATCH-END"
           ;; "REGEXP-MATCh-ANY" "REGEXP-COMPILE" "REGEXP-QUOTE-EXTENDED"


(defun split-string (string regexp)
  #-(or use-ppcre (and clisp use-regexp))
  (error "Please implement ~S (perhaps push :use-ppcre on *feature*)." 'split-string)
  #+(and clisp use-regexp) (regexp:regexp-split regexp string)
  #+use-ppcre (cl-ppcre:split regexp string))


(defvar *string-match-results* '())

(defun string-match (regexp string)
  #-(or use-ppcre (and clisp use-regexp))
  (error "Please implement ~S (perhaps push :use-ppcre on *feature*)." 'split-match)
  #+(and clisp use-regexp)
  (setf *string-match-results*
        (let ((results  (if (stringp regexp)
                            (multiple-value-list
                             (regexp:match regexp string :extended t :ignore-case nil :newline t :nosub nil))
                            (regexp:regexp-exec (cdr regexp) string :return-type 'list))))
          (if (equal '(nil) results)
              nil
              results)))
  #+use-ppcre
  (setf *string-match-results*
        (let ((results (multiple-value-list
                        (if (stringp regexp)
                            (cl-ppcre:scan regexp       string)
                            (cl-ppcre:scan (cdr regexp) string)))))
          (if (equal '(nil) results)
              nil
              (destructuring-bind (as ae ss es) results
                  (list as ae
                        (concatenate 'vector (vector as) ss)
                        (concatenate 'vector (vector ae) es)))))))

(defun match-string (index string)
  #-(or use-ppcre (and clisp use-regexp))
  (error "Please implement ~S (perhaps push :use-ppcre on *feature*)." 'match-string)
  #+(and clisp use-regexp)
  (let ((m (elt *string-match-results* index)))
    (when m (regexp:match-string string m)))
  #+use-ppcre
  (let ((start (ignore-errors (aref (elt *string-match-results* 2) index)))
        (end   (ignore-errors (aref (elt *string-match-results* 3) index))))
    (when (and start end)
      (subseq string start end))))

(defun match-beginning (index)
  #-(or use-ppcre (and clisp use-regexp))
  (error "Please implement ~S (perhaps push :use-ppcre on *feature*)." 'match-beginning)
  #+(and clisp use-regexp)
  (let ((m (elt *string-match-results* index)))
    (when m (regexp:match-start m)))
  #+use-ppcre
  (ignore-errors (aref (elt *string-match-results* 2) index)))

(defun match-end (index)
  #-(or use-ppcre (and clisp use-regexp))
  (error "Please implement ~S (perhaps push :use-ppcre on *feature*)." 'match-end)
  #+(and clisp use-regexp)
  (let ((m (elt *string-match-results* index)))
    (when m (regexp:match-end m)))
  #+use-ppcre
  (ignore-errors (aref (elt *string-match-results* 3) index)))

(defun regexp-match-any (groupsp)
  #- (or use-ppcre (and clisp use-regexp))
  (error "Please implement ~S (perhaps push :use-ppcre on *feature*)." 'regexp-match-any)
  #+(and clisp use-regexp) (if groupsp "(.*)" ".*")
  #+use-ppcre              (if groupsp "(.*)" ".*"))

(defun regexp-compile (regexp)
  #- (or use-ppcre (and clisp use-regexp))
  (error "Please implement ~S (perhaps push :use-ppcre on *feature*)." 'regexp-compile)
  #+(and clisp use-regexp) (regexp:regexp-compile regexp
                                                  :extended t
                                                  :ignore-case nil
                                                  :newline t
                                                  :nosub nil)
  #+use-ppcre (cl-ppcre:create-scanner regexp
                                       :case-insensitive-mode nil
                                       :multi-line-mode nil
                                       :extended-mode nil
                                       :destructive nil))

(defun regexp-quote-extended (string)
  ;; #+clisp regexp:regexp-quote doesn't quote extended regexps...
  ;;        (regexp:regexp-quote "(abc .*" t) --> "(abc \\.\\*"  instead of "\\(abc \\.\\*"
  #-use-ppcre
  (let* ((special-characters "^.[$()|*+?{\\")
         (increase (count-if (lambda (ch) (find ch special-characters)) string)))
     (if (zerop increase)
         string
         (let ((result (make-array (+ (length string) increase)
                                    :element-type 'character)))
           (loop
              :with i = -1
              :for ch :across string
              :do (if (find ch special-characters)
                      (setf (aref result (incf i)) #\\
                            (aref result (incf i)) ch)
                      (setf (aref result (incf i)) ch)))
           result)))
  #+use-ppcre
  (cl-ppcre:quote-meta-chars string))


