(define-module (omiya packages tunnel-client)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (nonguix build-system binary)
  #:use-module (gnu packages compression)
  #:use-module ((guix licenses) #:prefix license:))

(define-public omiya-tunnel-client
  (package
    (name "omiya-tunnel-client")
    (version "0.0.11")
    (source
     (origin
       (method url-fetch)
       (uri
        (string-append
         "https://github.com/openai/tunnel-client/releases/download/v"
         version
         "/tunnel-client-v"
         version
         "-linux-amd64.zip"))
       (sha256
        (base32
         "1i5k2wik5wdi2vjf4dnwa0pr2ma368626grqm7yvkpwr2dfgxb99"))))
    (build-system binary-build-system)
    (supported-systems '("x86_64-linux"))
    (native-inputs
     (list unzip))
    (arguments
     (list
      #:install-plan
      #~'(("tunnel-client" "libexec/tunnel-client/")
          ("cloudflared" "libexec/tunnel-client/")
          ("cloudflared-manifest.json" "libexec/tunnel-client/")
          ("LICENSE" "share/licenses/tunnel-client/"))

      #:phases
      #~(modify-phases %standard-phases
          (add-after 'install 'install-launcher
            (lambda _
              (let ((bin (string-append #$output "/bin")))
                (mkdir-p bin)
                (symlink
                 (string-append
                  #$output "/libexec/tunnel-client/tunnel-client")
                 (string-append bin "/tunnel-client"))))))))
    (home-page "https://github.com/openai/tunnel-client")
    (synopsis "Client for OpenAI Secure MCP Tunnel")
    (description
     "Tunnel Client connects private MCP servers to OpenAI-hosted products
through Secure MCP Tunnel.  This package includes the pinned Cloudflare Tunnel
companion used by the supported upstream distribution.")
    (license license:asl2.0)))
