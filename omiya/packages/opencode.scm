(define-module (omiya packages opencode)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (nonguix build-system binary)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages base)
  #:use-module (gnu packages gcc)
  #:use-module ((guix licenses) #:prefix license:))

(define-public omiya-opencode-pty
  (package
    (name "omiya-opencode-pty")
    (version "0.5.2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://registry.npmjs.org/@opencode/pty-linux-x64-gnu/-/"
             "pty-linux-x64-gnu-" version ".tgz"))
       (sha256
        (base32
         "15ckp7g4yhjrjlp564dk6ar3xjzp9z8qhxsqqxhbbm4mmk8ji8fq"))))
    (build-system binary-build-system)
    (supported-systems '("x86_64-linux"))
    (inputs
     `(("glibc" ,glibc)))
    (arguments
     (list
      ;; The upstream binary has /lib64/ld-linux-x86-64.so.2 as its interpreter.
      ;; Patch only the interpreter: no RPATH is needed.
      #:patchelf-plan #~'(("bin/opencode-pty"))
      #:install-plan #~'(("bin/opencode-pty" "bin/"))
      #:validate-runpath? #f
      #:strip-binaries? #f))
    (synopsis "OpenCode persistent PTY daemon")
    (description
     "OpenCode's native PTY helper, using the Guix dynamic linker.")
    (home-page "https://github.com/anomalyco/opencode")
    (license license:expat)))

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
      ("gcc:lib" ,gcc "lib")
      ("omiya-opencode-pty" ,omiya-opencode-pty)))
   (arguments
    (list
     ;; Adding an RPATH crashes the bundled runtime.  Patch only the
     ;; ELF interpreter, then exec the binary with Guix libraries.
     #:validate-runpath? #f

     ;; Do not strip the upstream executable.
     #:strip-binaries? #f

     #:install-plan
     #~'(("opencode" "libexec/"))

     #:patchelf-plan
     #~'(("opencode"))
     #:phases
     #~(modify-phases %standard-phases
         (add-after 'install 'install-launcher
           (lambda* (#:key inputs #:allow-other-keys)
             (let* ((out #$output)
                    (bash (assoc-ref inputs "bash-minimal"))
                    (glibc (assoc-ref inputs "glibc"))
                    (gcc-lib (assoc-ref inputs "gcc:lib"))
                    (pty (assoc-ref inputs "omiya-opencode-pty"))
                    (target (string-append out "/libexec/opencode"))
                    (launcher (string-append out "/bin/opencode")))
               (mkdir-p (dirname launcher))
               (call-with-output-file launcher
                 (lambda (port)
                   (format port
                           (string-append
                            "#!~a/bin/sh~%"
                            "export LD_LIBRARY_PATH=~s~%"
                            "export OPENCODE_PTY_BIN=~s~%"
                            "exec ~s \"$@\"~%")
                           bash
                           (string-append glibc "/lib:" gcc-lib "/lib")
                           (string-append pty "/bin/opencode-pty")
                           target)))
               (chmod launcher #o755)))))))
   (synopsis "Open source AI coding agent")
   (description
    (string-append
     "OpenCode is an open source AI coding agent that helps you write code"
     " in your terminal, IDE, or desktop."))
   (home-page "https://opencode.ai")
   (license license:expat)))
