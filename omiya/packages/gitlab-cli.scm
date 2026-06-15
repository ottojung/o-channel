(define-module (omiya packages gitlab-cli)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (nonguix build-system binary)
  #:use-module ((guix licenses) #:prefix license:))

(define-public omiya-gitlab-cli
  (package
    (name "omiya-gitlab-cli")
    (version "1.102.0")
    (source
     (origin
       (method url-fetch)
       (uri
        (string-append
         "https://gitlab.com/gitlab-org/cli/-/releases/v"
         version
         "/downloads/glab_"
         version
         "_linux_amd64.tar.gz"))
       (sha256
        (base32
         "0s08kjzm44lrq5v9q0xj67s0s8g3ynx6fpv9kdp14qhppdwg41if"))))
    (build-system binary-build-system)
    (supported-systems '("x86_64-linux"))
    (arguments
     (list
      #:install-plan
      #~'(("glab" "bin/"))))
    (synopsis "GitLab CLI tool")
    (description
     "GLab is an open source GitLab CLI tool.  It brings GitLab to your
terminal, next to where you are already working with Git and your code,
without switching between windows and browser tabs.")
    (home-page "https://gitlab.com/gitlab-org/cli")
    (license license:expat)))
