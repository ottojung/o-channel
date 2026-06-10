(define-module (omiya packages antigravity)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (nonguix build-system chromium-binary)
  #:use-module ((nonguix licenses) #:prefix license:)
  #:use-module (gnu packages certs)
  #:use-module (gnu packages fonts)
  #:use-module (gnu packages nss))

;; Local non-substitutable binary directory.
;; This is intentionally not fetched from upstream; the binary is not
;; redistributed through this channel.
(define %antigravity-source-directory
  "/home/user1/src/vendor/Antigravity-x64")

(define-public omiya-antigravity
  (package
    (name "omiya-antigravity")
    (version "2.0.11")
    (source
     (local-file %antigravity-source-directory
                 "antigravity-source"
                 #:recursive? #t))
    (supported-systems '("x86_64-linux"))
    (build-system chromium-binary-build-system)
    (arguments
     (list
      ;; Local binary package: don't expect substitutes.
      #:substitutable? #f

      ;; During initial bring-up, keep this false. Once it works, try #t.
      #:validate-runpath? #f

      ;; These paths are relative to the unpacked source directory, before
      ;; installation. The build system will set the ELF interpreter and RPATH.
      #:wrapper-plan
      #~'(("antigravity"
           (("out" "/share/antigravity")
            ("nss" "/lib/nss")))

          ("chrome_crashpad_handler"
           (("out" "/share/antigravity")))

          ("chrome-sandbox"
           (("out" "/share/antigravity")))

          ("resources/bin/language_server"
           (("out" "/share/antigravity")
            ("nss" "/lib/nss")))

          ("resources/bin/webm_encoder"
           (("out" "/share/antigravity")))

          ;; Bundled Electron/Chromium libraries.
          ("libffmpeg.so"
           (("out" "/share/antigravity")))

          ("libEGL.so"
           (("out" "/share/antigravity")))

          ("libGLESv2.so"
           (("out" "/share/antigravity")))

          ("libvulkan.so.1"
           (("out" "/share/antigravity")))

          ("libvk_swiftshader.so"
           (("out" "/share/antigravity"))))

      ;; Copy the whole unpacked application into the store.
      #:install-plan
      #~'(("." "share/antigravity/"))

      #:phases
      #~(modify-phases %standard-phases
          (add-after 'install 'symlink-binary-file
            (lambda _
              (let ((bin (string-append #$output "/bin")))
                (mkdir-p bin)
                (symlink
                 (string-append #$output "/share/antigravity/antigravity")
                 (string-append bin "/antigravity")))))

          ;; Extra things we used manually / often need for networked Electron apps.
          (add-after 'install-wrapper 'wrap-extra-env
            (lambda* (#:key inputs #:allow-other-keys)
              (let* ((certs (assoc-ref inputs "nss-certs"))
                     (dejavu (assoc-ref inputs "font-dejavu"))
                     (cert-file
                      (string-append certs
                                     "/etc/ssl/certs/ca-certificates.crt"))
                     (exe (string-append #$output "/bin/antigravity")))
                (wrap-program exe
                  `("SSL_CERT_FILE" = (,cert-file))
                  `("GIT_SSL_CAINFO" = (,cert-file))
                  `("CURL_CA_BUNDLE" = (,cert-file))
                  `("XDG_DATA_DIRS" ":" prefix
                    (,(string-append dejavu "/share"))))))))))
    (inputs
     (list nss-certs font-dejavu))
    (home-page "https://antigravity.google/")
    (synopsis "Agentic development environment")
    (description
     "Antigravity is a prebuilt Electron/Chromium-based development
environment.  This local package installs the upstream binary distribution
and patches its ELF interpreters and runtime search paths for Guix.")
    (license
     (license:nonfree "https://antigravity.google/terms/"))))
