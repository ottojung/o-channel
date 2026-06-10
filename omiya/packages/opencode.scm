(define-module (omiya packages opencode)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (nonguix build-system binary)
  #:use-module (gnu packages base)
  #:use-module (gnu packages gcc)
  #:use-module ((guix licenses) #:prefix license:))

(define-public omiya-opencode
  (package
   (name "omiya-opencode")
   (version "1.17.3")
   (source
    (origin
     (method url-fetch)
     (uri
      (string-append
       "https://github.com/anomalyco/opencode/releases/download/v"
       version
       "/opencode-linux-x64.tar.gz"))
     (sha256
      (base32
       "0z8a05rbvyrairzpll9l4acza5x3l0hpsffk3k56mx8z5j527gfl"))))
   (build-system binary-build-system)
   (inputs
    `(("glibc" ,glibc)
      ("gcc" ,gcc "lib")))
   (arguments
    (list
     #:install-plan
     #~'(("opencode" "bin/"))

     #:patchelf-plan
     #~'(("opencode" ("glibc" "gcc")))))
   (synopsis "Open source AI coding agent")
   (description
    "OpenCode is an open source AI coding agent that helps you write code in your terminal, IDE, or desktop.")
   (home-page "https://opencode.ai")
   (license license:expat)))
