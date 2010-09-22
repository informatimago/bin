#!/usr/bin/clisp -ansi -q -Kfull -E iso-8859-1
;;;; -*- mode:lisp; coding:iso-8859-1 -*-
;;;;*****************************************************************************
;;;;FILE:              clar
;;;;LANGUAGE:          common lisp (clisp)
;;;;SYSTEM:            UNIX
;;;;USER-INTERFACE:    CLI
;;;;DESCRIPTION
;;;;    This script joins or splits lisp sources between a single file
;;;;    and several files.
;;;;USAGE
;;;;
;;;;    clar single.lisp  a.lisp ... z.lisp
;;;;            -- creates a single.lisp as a concatenation of a.lisp ... z.lisp
;;;;
;;;;    clar single.lisp
;;;;            -- splits single.lisp into the original a.lisp ... z.lisp files.
;;;;
;;;;AUTHORS
;;;;    <PJB> Pascal J. Bourguignon
;;;;MODIFICATIONS
;;;;    2010-09-22 <PJB> Created.
;;;;BUGS
;;;;LEGAL
;;;;    Copyright Pascal J. Bourguignon 2010 - 2010
;;;;
;;;;    This script is free software; you can redistribute it and/or
;;;;    modify it under the terms of the GNU  General Public
;;;;    License as published by the Free Software Foundation; either
;;;;    version 2 of the License, or (at your option) any later version.
;;;;
;;;;    This script is distributed in the hope that it will be useful,
;;;;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;;;;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;;;;    General Public License for more details.
;;;;
;;;;    You should have received a copy of the GNU General Public
;;;;    License along with this library; see the file COPYING.LIB.
;;;;    If not, write to the Free Software Foundation,
;;;;    59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
;;;;*****************************************************************************

(shadow 'usage)

(defparameter *file-constr* ";;;; -%- CLAR FILE -%- ~S~%")
(defparameter *file-regexp* ";;;; -%- CLAR FILE -%- \\(.*\\)")
(defparameter *end-constr*  ";;;; -%- CLAR END -%-~%")
(defparameter *end-regexp*  ";;;; -%- CLAR END -%-")

(defun join (output inputs)
  (with-open-file (out output
                       :direction :output
                       :if-does-not-exist :create
                       :if-exists :supersede
                       :external-format charset:iso-8859-1)
    (dolist (input inputs)
      (with-open-file (inp input
                           :direction :input
                           :if-does-not-exist :error
                           :external-format charset:iso-8859-1)
        (format out *file-constr* (file-namestring inp))
        (loop
           :for line = (read-line inp nil nil)
           :while line
           :do (write-line line out))))
    (format out *end-constr*)))


(defun split (archive)
  (with-open-file (inp archive
                       :direction :input
                       :if-does-not-exist :error
                       :external-format charset:iso-8859-1)
    (let ((out nil))
      (unwind-protect
           (loop
              :with all :with name
              :for line = (read-line inp nil nil)
              :while line
              :do
              (multiple-value-setq (new-file-p name) (regexp:match *file-regexp* line))
              (unless new-file-p (setf eofp (regexp:match *end-regexp* line)))
              (cond
                (new-file-p
                 (when out (close out))
                 (let ((name (read-from-string (regexp:match-string line name))))
                   (assert (every (lambda (ch) (or (alphanumericp ch)
                                              (position ch "-._")))
                                  name)
                           (name)
                           "The file name must be simple to avoid security risks ~
                              (such as trying to overwrite system files. ~S is rejected"
                           name)
                   (setf out (open name
                                   :direction :output
                                   :if-does-not-exist :create
                                   :if-exists :supersede
                                   :external-format charset:iso-8859-1))))
                (eofp
                 (close out)
                 (setf out nil)
                 (loop-finish))
                (out
                 (write-line line out))
                (t
                 (warn "Prefix line: ~S" line))))
        (when out (close out))))))


(defun pname ()
  (namestring *load-pathname*))

(defun usage ()
  (let ((pname (pname)))
    (format t "~A usage:~2%" pname)
    (format t "~T~A  single.lisp   a.lisp .... z.lisp~%" pname)
    (format t "~T~T# create a single file from several sources.~2")
    (format t "~T~A  single.lisp~%" pname)
    (format t "~T~T# split out several sources from a single file.~2")))

(defun main (files)
  (handler-case
      (cond
        ((null files)
         (usage)
         1)
        ((some (lambda (file) (or (zerop (length file))
                             (char= #\- (aref file 0)))) files)
         (usage)
         2)
        ((null (rest files))
         (split (first files))
         0)
        (t
         (join (first files) (rest files))
         0))
    (error (err)
      (format t "~A: ~A~%" (pname) err)
      3)))

(ext:exit (main ext:*args*))


;;;; THE END ;;;;
