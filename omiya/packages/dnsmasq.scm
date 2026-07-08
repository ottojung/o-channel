(define-module (omiya packages dnsmasq)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages pkg-config))

(define-public omiya-dnsmasq
  (package
    (name "omiya-dnsmasq")
    (version "2.92")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
              (url "http://thekelleys.org.uk/git/dnsmasq.git")
              (commit (string-append "v" version))))
       (file-name (git-file-name "omiya-dnsmasq" version))
       (sha256
        (base32 "055gn5kigz0m9y09vig97s1g257hnlkhw4wv9d9wdficnsxcbwwm"))))
    (build-system gnu-build-system)
    (arguments
     (list
      #:tests? #f
      #:make-flags
      #~(list (string-append "PREFIX=" #$output)
              (string-append "CC=" #$(cc-for-target))
              (string-append "PKG_CONFIG=" #$(pkg-config-for-target))
              "COPTS=\"-DHAVE_DBUS\"")
      #:phases
      #~(modify-phases %standard-phases
          (delete 'configure)
          (add-after 'unpack 'set-version-file
            (lambda _
              (call-with-output-file "VERSION"
                (lambda (port)
                  (display #$version port)))))
          (add-after 'install 'install-dbus
            (lambda _
              (install-file "dbus/dnsmasq.conf"
                            (string-append #$output "/etc/dbus-1/system.d")))))))
    (native-inputs
     (list pkg-config))
    (inputs
     (list dbus))
    (home-page "https://thekelleys.org.uk/dnsmasq/doc.html")
    (synopsis "Small caching DNS proxy and DHCP/TFTP server")
    (description
     "Dnsmasq is a light-weight DNS forwarder and DHCP server.  It is designed
to provide DNS and, optionally, DHCP to a small network.  It can serve the
names of local machines which are not in the global DNS.  The DHCP server
integrates with the DNS server and allows machines with DHCP-allocated
addresses to appear in the DNS with names configured either on each host or in
a central configuration file.  Dnsmasq supports static and dynamic DHCP leases
and BOOTP/TFTP for network booting of diskless machines.")
    (license (list license:gpl2 license:gpl3))))
