(cl:defpackage :quickdist-app
  (:use :cl)
  (:export #:run))
(cl:in-package :quickdist-app)


(declaim (special *dist-name*
                  *dist-base-url*
                  *project-dir*
                  *dist-dir*
                  *ql-home*))


(defun init-quicklisp ()
  (quicklisp-quickstart:install :path *ql-home*)
  (push (namestring *project-dir*)
        (symbol-value (uiop:find-symbol* :*local-project-directories* :ql)))
  (uiop:symbol-call :ql :register-local-projects))


(defun quickload (systems)
  (uiop:symbol-call :ql :quickload systems :prompt nil))


(defun run-quickdist ()
  (ensure-directories-exist *dist-dir*)
  (let ((quickdist:*system-loader* #'quickload))
    (quickdist:quickdist :name *dist-name*
                         :base-url *dist-base-url*
                         :projects-dir *project-dir*
                         :dists-dir *dist-dir*)))

(defun run ()
  (destructuring-bind (dist-name dist-base-url project-dir dist-dir &optional ql-home)
      (uiop:command-line-arguments)
    (let ((*dist-name* dist-name)
          (*dist-base-url* dist-base-url)
          (*project-dir* (uiop:ensure-directory-pathname project-dir))
          (*dist-dir* (uiop:ensure-directory-pathname dist-dir))
          (*ql-home*
            (uiop:ensure-directory-pathname
             (or ql-home
                 (loop thereis
                       (uiop:with-temporary-file (:pathname tmp-file)
                         (let ((tmp-dir (merge-pathnames (format nil "~A.ql/" (pathname-name tmp-file))
                                                         (uiop:pathname-directory-pathname tmp-file))))
                           (unless (uiop:directory-exists-p tmp-dir)
                             tmp-dir))))))))
      (ensure-directories-exist *ql-home*)
      (unwind-protect
           (progn
             (init-quicklisp)
             (run-quickdist))
        (uiop:delete-directory-tree *ql-home* :validate (constantly t))))))
