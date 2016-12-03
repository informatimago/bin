
(defun contents-from-stream (stream &key length (min-size 256) max-extend)
  "
STREAM:     May be a binary or character, file or non-file stream.
LENGTH:     NIL, or the number of stream elements to read.
MIN-SIZE:   Minimum pre-allocated buffer size. If LENGTH is given, or STREAM
            has a FILE-LENGTH, then the MIN-SIZE is ignored.
MAX-EXTEND: NIL ==> double the buffer size, or double the buffer size until
            it is greater than MAX-EXTEND, and then increment by MAX-EXTEND.
RETURN:     A vector containing the elements read from the STREAM.
"
  (let* ((busize (or length (ignore-errors (file-length stream)) min-size))
         (eltype (stream-ELEMENT-TYPE stream))
         (initel (if (subtypep eltype (quote integer)) 0 #\Space))
         (buffer (make-ARRAY busize
                             :ELEMENT-TYPE eltype
                             :INITIAL-ELEMENT initel
                             :adjustable t :fill-pointer t))
         (start 0))
    (loop
       (let ((end (read-sequence buffer stream :start start)))
         (when (or (< end busize) (and length (= length end)))
           ;; we got eof, or have read enough
           (setf (fill-pointer buffer) end)
           (return-from contents-from-stream buffer))
         ;; no eof; extend the buffer
         (setf busize
               (if (or (null max-extend) (<= (* 2 busize) max-extend))
                   (* 2 busize)
                   (+ busize max-extend))
               start end))
       (adjust-array buffer busize :initial-element initel :fill-pointer t))))


(defun text-file-contents (path &key (if-does-not-exist :error)
                           (external-format :default))
  "
RETURN: The contents of the file at PATH as a LIST of STRING lines.
        or what is specified by IF-DOES-NOT-EXIST if it does not exist.
"
  (with-open-file (in path :direction :input
                      :if-does-not-exist if-does-not-exist
                      :external-format external-format)
    (if (streamp in)
        (contents-from-stream in :min-size 16384)
        in)))


(defun (setf text-file-contents) (new-contents path
                                  &key (if-does-not-exist :create)
                                  (if-exists :supersede)
                                  (external-format :default))
  "
RETURN: The NEW-CONTENTS, or if-exists or if-does-not-exist in case of error.
DO:     Store the NEW-CONTENTS into the file at PATH.  By default,
        that file is created or superseded; this can be changed with
        the keyword IF-DOES-NOT-EXIST or IF-EXISTS.
"
  (with-open-file (out path :direction :output
                       :if-does-not-exist if-does-not-exist
                       :if-exists if-exists
                       :external-format external-format)
    (if (streamp out)
        (write-sequence new-contents out)
        out)))


(defvar *absent* (cons (quote *absent*) nil))
(defmacro define-plist-field (name field &optional (offset (quote identity)))
 "
OFFSET: must be a symbol naming an accessor to find the plist in the record.
"
  `(progn
     (defun ,name (record)
       (let* ((value (getf (,offset record) (quote ,field) *absent*)))
         (if (eq value *absent*)
             (values nil nil)
             (values value t))))
     (defun (setf ,name) (new-value record)
       (setf (getf (,offset record) (quote ,field)) new-value))))

(define-plist-field frame-number        :number  cdr)
(define-plist-field frame-x             :x       cdr)
(define-plist-field frame-y             :y       cdr)
(define-plist-field frame-width         :width   cdr)
(define-plist-field frame-height        :height  cdr)
(define-plist-field frame-screen-width  :screenw cdr)
(define-plist-field frame-screen-height :screenh cdr)


(defun order-by-id (f) (frame-number f))
(defun order-by-x  (f) (frame-x      f))

(defun balance-frames (frames &optional (order-function (function order-by-x)))
  (let* ((frames  (sort frames
                        (function <)
                        :key order-function))
         (screen-width  (frame-screen-width  (first frames)))
         (screen-height (frame-screen-height (first frames)))
         (numframes     (length frames)))
    (loop
      :with width = (truncate screen-width numframes)
      :for x :from 0 :by width
      :for frame :in frames
      :do (setf (frame-x frame) x
                (frame-y frame) 0
                (frame-width frame) width
                (frame-height frame) screen-height))
    frames))



(defun margin-frames (frames right bottom)
  "
First frame should be sized with right and bottom margins.
"
  (flet ((main   (frames) (first  frames))
         (bottom (frames) (second frames))
         (right  (frames) (third  frames)))
    (let ((screen-width  (frame-screen-width  (main frames)))
          (screen-height (frame-screen-height (main frames))))
      (setf (frame-x      (main frames)) 0
            (frame-y      (main frames)) 0
            (frame-width  (main frames)) (- screen-width right)
            (frame-height (main frames)) (- screen-height bottom)
            (frame-x      (bottom frames)) 0
            (frame-y      (bottom frames)) (- screen-height bottom)
            (frame-width  (bottom frames)) (- screen-width right)
            (frame-height (bottom frames)) screen-height
            (frame-x      (right frames)) (- screen-width right)
            (frame-y      (right frames)) 0
            (frame-width  (right frames)) screen-width
            (frame-height (right frames)) screen-height)
      frames)))


(defvar *path* "~/.ratpoison/last-balanced")
(let* ((*print-pretty* nil)
       (input  (read-from-string
                (format nil "(~A)"
                        (substitute #\space #\,
                                    (text-file-contents
                                     *path*))))))
  (cond
    ((eq :order (caar input))
     (let ((order (let ((order (second (pop input))))
                    (if (member order (quote (order-by-x order-by-id)))
                        order
                        (quote order-by-x)))))
       (setf (text-file-contents *path*)
             (format nil "~(~{~S~^,~}~)"
                     (balance-frames input order)))))
    ((eq :margin (caar input))
     (pop input)
     (if (= 3 (length input))
         (setf (text-file-contents *path*)
               (format nil "~(~{~S~^,~}~)"
                       (margin-frames input 128 128)))
         (format *error-output* "Unexpected 4 frames for a margin operation in command file ~A" *path*)))
    (t
     (format *error-output* "Unexpected command file ~A" *path*))))






(defun renumber (old new &rest winums)
  (handler-case
      (let* ((old     (parse-integer old))
             (new     (parse-integer new))
             (winums  (mapcar (function parse-integer) winums))
             (focused (first winums)))
        (assert (member old winnums) () "No window number ~A" old)
        (ext:shell (format nil "ratpoison -c 'select ~A' -c 'number ~A' -c 'select ~A'"
                           old new (if (= old focused) new focused))))
    (error (err) (format *error-output* "~A" err))))

(renumber ext:*args*)
