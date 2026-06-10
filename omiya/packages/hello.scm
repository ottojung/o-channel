(define-module (omiya packages hello)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module ((guix licenses) #:prefix license:))

(define-public omiya-hello
  (package
    (name "omiya-hello")
    (version "2.10")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://gnu/hello/hello-" version ".tar.gz"))
       (sha256
        (base32
         "0ssi1wpaf7plaswqqjwigppsg5fyh99vdlb9kzl7c9lng89ndq1i"))))
    (build-system gnu-build-system)
    (synopsis "Personal test package for the o-channel Guix channel")
    (description
     "This package exists to verify that the o-channel personal Guix channel is visible to Guix.")
    (home-page "https://www.gnu.org/software/hello/")
    (license license:gpl3+)))
