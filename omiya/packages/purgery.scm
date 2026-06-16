(define-module (omiya packages purgery)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix build-system cargo)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages rust))

;; Local vendored source directory, produced by 'cargo vendor guix-vendor'.
;; Not substitutable.  Regenerate from a purgery checkout:
;;   guix shell rust -- cargo vendor guix-vendor
(define %purgery-source-directory
  "/tmp/opencode/purgery-source")

(define-public omiya-purgery
  (package
    (name "omiya-purgery")
    (version "0.1.0")
    (source
     (local-file %purgery-source-directory
                 "purgery-source"
                 #:recursive? #t))
    (supported-systems '("x86_64-linux"))
    (build-system cargo-build-system)
    (arguments
     (list
      #:phases
      #~(modify-phases %standard-phases
          (delete 'check)
          (delete 'package)
          (replace 'install
            (lambda _
              (let ((bin (string-append #$output "/bin")))
                (mkdir-p bin)
                (install-file "target/release/purgery-client" bin)
                (install-file "target/release/purgery-server" bin)))))))
    (native-inputs
     (list rust))
    (home-page "https://github.com/ottojung/purgery")
    (synopsis "File syncer with post-processing transforms")
    (description
     "Purgery imports a filesystem entry from a device into a destination,
optionally transforms it on the server, and only removes the local original
when doing so is explicitly configured and safe.  Supports passthrough rsync
imports and server-side transform pipelines.")
    (license license:agpl3+)))
