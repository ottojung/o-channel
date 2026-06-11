(define-module (omiya packages euphrates)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages base))

(define-public omiya-euphrates
  (package
    (name "omiya-euphrates")
    (version "0.0.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/ottojung/euphrates")
             (commit "8f656093e43b486271462cb0820ce9eb7ad25fb5")))
       (sha256
        (base32
         "0fl1dsmly77p811jjkb8s15w8vxx4mn32cbwc26xshy315pi9gcg"))
       (file-name (git-file-name "euphrates" version))))
    (build-system gnu-build-system)
    (arguments
     (list
      #:make-flags
      #~(list (string-append "PREFIX=" #$output))
      #:phases
      #~(modify-phases %standard-phases
          (delete 'configure)
          (delete 'build)
          (delete 'check)
          (replace 'install
            (lambda* (#:key (make-flags '()) #:allow-other-keys)
              (apply invoke "make" "install" make-flags)))
          (add-after 'unpack 'add-install-target
            (lambda _
              (substitute* "Makefile"
                (("^clean:" all)
                 (string-append
                  "install:\n"
                  "\tmkdir -p $(PREFIX)/share/guile/site/3.0\n"
                  "\tcp -r src/euphrates $(PREFIX)/share/guile/site/3.0/\n\n"
                  all))))))))
    (inputs
     (list guile-3.0))
    (native-inputs
     (list which))
    (home-page "https://github.com/ottojung/euphrates")
    (synopsis "Standard library for Scheme")
    (description
     "Euphrates is a standard library/computing environment for Scheme.
It provides various common functionalities including CLI parsing, an
object system, parser generators, monads, JSON parsing, petri networks,
and much more.")
    (license license:gpl3+)))
