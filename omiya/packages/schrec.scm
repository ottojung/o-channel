(define-module (omiya packages schrec)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages base)
  #:use-module (omiya packages euphrates))

(define-public omiya-schrec
  (package
    (name "omiya-schrec")
    (version "3.0.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/ottojung/schrec")
             (commit "e3da63118acb62bcc5c66d636288e63fa9bec556")))
       (sha256
        (base32
         "0aay1fifmwx4jm30bk8yrja6d9jwpd9cxylkrcacs63bz18wkvia"))
       (file-name (git-file-name "schrec" version))))
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
          (add-before 'install 'fix-submodules
            (lambda _
              (mkdir-p "deps/euphrates")
              (call-with-output-file "deps/euphrates/.git"
                (lambda (p) (display "gitdir: ../.git\n" p)))
              (let ((euph (assoc-ref %build-inputs "omiya-euphrates")))
                (delete-file "src/euphrates")
                (symlink (string-append euph "/share/guile/site/3.0/euphrates")
                         "src/euphrates"))
              (substitute* "Makefile"
                (("\\$\\(PWD\\)/src") (string-append (getcwd) "/src")))
              (substitute* "scripts/bin-template.sh"
                (("guile") "guile --r7rs"))))
          (replace 'install
            (lambda* (#:key (make-flags '()) #:allow-other-keys)
              (apply invoke "make" "install" make-flags))))))
    (inputs
     (list guile-3.0 omiya-euphrates))
    (native-inputs
     (list which))
    (home-page "https://github.com/ottojung/schrec")
    (synopsis "Interpreter for the ρs calculus")
    (description
     "SchReC is an interpreter for the ρs (rose) calculus, a
non-deterministic rewriting system.  It supports alpha-renaming,
beta-conversion, and various evaluation modes.")
    (license license:gpl3+)))
