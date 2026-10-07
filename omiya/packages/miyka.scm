(define-module (omiya packages miyka)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages base))

(define-public omiya-miyka
  (package
    (name "omiya-miyka")
    (version "2.5.0-2.a3764a3")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/ottojung/miyka")
             (commit "a3764a39605c448ece92a8d5b44c1e916dda2604")
             (recursive? #t)))
       (sha256
        (base32
         "1861l7j7n8fy2l394qch6c0gxrnhh55z5z45xcsygm2k17fbh3vf"))
       (file-name (git-file-name "miyka" version))))
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
          (delete 'strip)
          (add-before 'install 'fix-makefile
            (lambda _
              (mkdir-p "root/dependencies/euphrates")
              (call-with-output-file "root/dependencies/euphrates/.git"
                (lambda (p) (display "gitdir: ../.git\n" p)))
              (mkdir-p (string-append #$output "/bin"))
              (mkdir-p (string-append #$output "/share/miyka"))
              (substitute* "root/Makefile"
                (("sh scripts/update-version.sh.*$") "")
                (("\\$\\(BINARY_PATH\\) --version.*$") ""))
              (mkdir-p "root/src/miyka")
              (call-with-output-file "root/src/miyka/miyka-version.scm"
                (lambda (p)
                  (format p ";;;; Copyright (C) 2024  Otto Jung~@
;;;; This program is free software: you can redistribute it and/or modify~@
;;;; it under the terms of the GNU Affero General Public License as published by~@
;;;; the Free Software Foundation, either version 3 of the License, or (at your~@
;;;; option) any later version.~@
;;;; This program is distributed in the hope that it will be useful,~@
;;;; but WITHOUT ANY WARRANTY; without even the implied warranty of~@
;;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the~@
;;;; GNU Affero General Public License for more details.~@
;;;; You should have received a copy of the GNU Affero General Public License~@
;;;; along with this program.  If not, see <https://www.gnu.org/licenses/>.~@
~@
(define miyka:version \"2.5.0\")~%")))))
          (replace 'install
            (lambda* (#:key (make-flags '()) #:allow-other-keys)
              (chdir "root")
              (apply invoke "make" "install" make-flags)))
          (add-after 'install 'compile-miyka
            (lambda _
              (let* ((launcher (string-append #$output "/bin/miyka"))
                     (source-dir
                      (string-append #$output "/share/miyka/src"))
                     (cache-home (string-append (getcwd) "/.miyka-cache"))
                     (cache-root (string-append cache-home "/guile/ccache"))
                     (module-cache
                      (string-append
                       #$output "/lib/miyka/guile-ccache/modules")))
                ;; Use one real Miyka invocation to discover the complete
                ;; transitive set of R7RS libraries required at runtime.
                (setenv "XDG_CACHE_HOME" cache-home)
                (setenv "MIYKA_GUIX_EXECUTABLE" "/nonexistent/guix")
                (substitute* launcher
                  ((" guile --r7rs ")
                   (string-append
                    " " #$(file-append guile-3.0 "/bin/guile")
                    " --fresh-auto-compile --r7rs ")))
                (invoke "sh" launcher "--version")
                (let* ((marker (string-append source-dir "/"))
                       (auto-compiled
                        (find-files cache-root "\\.sld\\.go$"))
                       (source-files
                        (map
                         (lambda (compiled)
                           (let ((position
                                  (string-contains compiled marker)))
                             (unless position
                               (error
                                "unexpected Miyka auto-cache path"
                                compiled))
                             (let* ((relative-go
                                     (substring
                                      compiled
                                      (+ position
                                         (string-length marker))))
                                    (relative
                                     (substring
                                      relative-go
                                      0
                                      (- (string-length relative-go) 7))))
                               (string-append
                                source-dir "/" relative ".sld"))))
                         auto-compiled)))
                  (when (null? source-files)
                    (error "Miyka did not auto-compile any R7RS libraries"))
                  ;; Guile's auto-compiler can emit a providers.go that
                  ;; deadlocks when loaded in a fresh process.  Recompile the
                  ;; discovered libraries explicitly with guild instead.
                  (setenv
                   "XDG_CACHE_HOME"
                   (string-append (getcwd) "/.guild-cache"))
                  (setenv "GUILE_AUTO_COMPILE" "0")
                  (for-each
                   (lambda (source)
                     (let* ((relative-sld
                             (substring
                              source (+ 1 (string-length source-dir))))
                            (relative
                             (substring
                              relative-sld
                              0
                              (- (string-length relative-sld) 4)))
                            (target
                             (string-append
                              module-cache "/" relative ".go")))
                       (mkdir-p (dirname target))
                       (invoke
                        #$(file-append guile-3.0 "/bin/guild")
                        "compile"
                        "--r7rs"
                        "-L" source-dir
                        "-o" target
                        source)))
                   source-files))
                (substitute* launcher
                  ((" --fresh-auto-compile --r7rs ")
                   (string-append
                    " --no-auto-compile -C " module-cache
                    " --r7rs ")))
                (substitute* launcher
                  (((string-append
                     " -s \"" #$output
                     "/share/miyka/src/miyka/miyka.sld\" "))
                   " -c '(import (miyka miyka))' "))
                ;; Resolving Guix from precompiled Miyka can deadlock in
                ;; Guile subprocess setup.  Resolve it in the launcher while
                ;; honoring an explicit MIYKA_GUIX_EXECUTABLE override.
                (substitute* launcher
                  (("MIYKA_TEMPORARY_CONTINUATION=")
                   (string-append
                    "if test -z \"${MIYKA_GUIX_EXECUTABLE+x}\"; then\n"
                    "  MIYKA_GUIX_EXECUTABLE=$(command -v guix 2>/dev/null) || {\n"
                    "    echo 'miyka: guix executable not found in PATH' >&2\n"
                    "    exit 127\n"
                    "  }\n"
                    "  export MIYKA_GUIX_EXECUTABLE\n"
                    "fi\n"
                    "MIYKA_TEMPORARY_CONTINUATION=")))))))))
    (inputs
     (list guile-3.0))
    (native-inputs
     (list which))
    (home-page "https://github.com/ottojung/miyka")
    (synopsis "Manager for isolated workspaces")
    (description
     "Miyka is a manager for isolated workspaces.  It packages workspaces
as standalone packages that are easy to reproduce and move around.")
    (license license:agpl3+)))
