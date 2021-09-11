(asdf:defsystem :quickdist-app
  :description "Quickdist application"
  :author "Pavel Korolev"
  :license "MIT"
  :depends-on (#:uiop #:asdf #:quickdist
                      (:feature :sbcl #:sb-posix))
  :components ((:file "quicklisp")
               (:file "app")))
