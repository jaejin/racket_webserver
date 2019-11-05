#lang racket

(require racket/cmdline
         racket/unit)



(define port (make-parameter #f))

(define configuration@
  (parse-command-line ;; https://docs.racket-lang.org/reference/Command-Line_Parsing.html?q=parse-command-line#%28def._%28%28lib._racket%2Fcmdline..rkt%29._parse-command-line%29%29
   "plt-web-server"
   (current-command-line-arguments)
   `((once-each
      [("-f" "--configuration-table")
       ,(lambda (flag file-name)
          (cond
            [(not (file-exists? file-name))
             (error 'web-server "configuration file ~s not found" file-name)]
            [(not (memq 'read (file-or-directory-permissions file-name)))
             (error 'web-server "configuration file ~s is not readable" file-name)]
            [else (cons 'config (string->path file-name))]))
       ("Use an alternate configuration table" "file-name")]
      [("-p" "--port")
       ,(lambda (flag the-port)
          (let ([p (string->number the-port)])
            (if (and (integer? p) (<= 1 p 65535))
              (port p)
              (error 'web-server "expecting a valid port number, got \"~a\"" the-port))))
       ("Use an alternate network port." "port")]
      [("-a" "--ip-address")
       ,(lambda (flag ip-address)
          ; note the double backslash I initially left out.  That's a good reason to use Olin's regexps.
          (let ([addr (regexp-split #px"\\." ip-address)])
            (if (and (= 4 (length addr))
                     (andmap (lambda (s)
                               (let ([n (string->number s)])
                                 (and (integer? n) (<= 0 n 255))))
                             addr))
                (cons 'ip-address ip-address)
                (error 'web-server "ip-address expects a numeric ip-address (i.e. 127.0.0.1); given ~s" ip-address))))
       ("Restrict access to come from ip-address" "ip-address")]))
   (lambda (flags)
     (configuration-table->web-config@
      (extract-flag 'config flags default-configuration-table-path)
      #:port (port)
      #:listen-ip (extract-flag 'ip-address flags #f)))
   '()))

(define (serve)
  (printf "run serve\n"))

(provide serve)
