(define-module (omiya packages opencode)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (nonguix build-system binary)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages base)
  #:use-module (gnu packages gcc)
  #:use-module ((guix licenses) #:prefix license:))

(define-public omiya-opencode
  (package
   (name "omiya-opencode")
    (version "2.3.0")
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
         "0fsddv69z0b7d7ykhb2cwxy53g52xy4q7n4kfv2bmsnf599823zw"))))
   (build-system binary-build-system)
   (supported-systems '("x86_64-linux"))
   (inputs
    `(("bash-minimal" ,bash-minimal)
      ("glibc" ,glibc)
      ("gcc" ,gcc "lib")))
   (arguments
    (list
     ;; The bundled runtime crashes if an RPATH is added to its ELF.
     ;; Keep the executable unmodified.
     #:validate-runpath? #f

     ;; Do not strip the upstream executable.
     #:strip-binaries? #f

     #:install-plan
     #~'(("opencode" "libexec/"))

     #:patchelf-plan
     #~'()
     #:phases
     #~(modify-phases %standard-phases
         (add-after 'install 'install-launcher
           (lambda* (#:key inputs #:allow-other-keys)
             (let* ((out #$output)
                    (bash (assoc-ref inputs "bash-minimal"))
                    (glibc (assoc-ref inputs "glibc"))
                    (gcc-lib (assoc-ref inputs "gcc"))
                    (target (string-append out "/libexec/opencode"))
                    (launcher (string-append out "/bin/opencode")))
               (mkdir-p (dirname launcher))
               (call-with-output-file launcher
                 (lambda (port)
                   (format port
                           (string-append
                            "#!~a/bin/sh~%"
                            "exec ~a/lib/ld-linux-x86-64.so.2"
                            " --library-path ~s ~s \"$@\"~%")
                           bash glibc
                           (string-append glibc "/lib:" gcc-lib "/lib")
                           target)))
               (chmod launcher #o755)))))))
   (synopsis "Open source AI coding agent")
   (description
    "OpenCode is an open source AI coding agent that helps you write code in your terminal, IDE, or desktop.")
   (home-page "https://opencode.ai")
   (license license:expat)))
