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
    (version "2.5.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/ottojung/miyka")
             (commit "v2.5.0")
             (recursive? #t)))
       (sha256
        (base32
         "035s20j0mw9yfwig2n7k7kg1b7kw7abs7gz1b52bkh1y2xwdj18l"))
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
              (apply invoke "make" "install" make-flags))))))
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
