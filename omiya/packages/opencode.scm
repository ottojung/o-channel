(define-module (omiya packages opencode)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system trivial)
  #:use-module (guix gexp)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages base)
  #:use-module ((guix licenses) #:prefix license:))

(define-public omiya-opencode
  (package
    (name "omiya-opencode")
    (version "1.17.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://github.com/anomalyco/opencode/releases/download/v"
                           version "/opencode-linux-x64.tar.gz"))
       (sha256
        (base32 "0z8a05rbvyrairzpll9l4acza5x3l0hpsffk3k56mx8z5j527gfl"))))
    (build-system trivial-build-system)
    (native-inputs (list tar gzip coreutils))
    (arguments
     (list
      #:builder
      #~(begin
          (let* ((source (assoc-ref %build-inputs "source"))
                 (tar    (string-append (assoc-ref %build-inputs "tar")
                                        "/bin/tar"))
                 (mkdir  (string-append (assoc-ref %build-inputs "coreutils")
                                        "/bin/mkdir"))
                 (out    #$output)
                 (bin    (string-append out "/bin")))
            (setenv "PATH"
                    (string-append (assoc-ref %build-inputs "gzip") "/bin"))
            (system* mkdir "-p" bin)
            (let ((result (system* tar "xzf" source "-C" bin)))
              (unless (zero? result)
                (error "tar extraction failed")))
            (chmod (string-append bin "/opencode") #o555)))))
    (synopsis "Open source AI coding agent")
    (description
     "OpenCode is an open source AI coding agent that helps you write code in
your terminal, IDE, or desktop.")
    (home-page "https://opencode.ai")
    (license license:expat)))
