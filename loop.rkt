#lang racket
(define header "GET / HTTP/1.1\r\nHost: localhost:8080\r\nUser-Agent: curl/7.54.0\r\nAccept: */*\r\n\r\n")

(define (read-all input)
  (let ([line (read-line input 'any)])
    (printf "~a\n" line)
    (if (regexp-match #rx"(^$)|((^|[^\r])\n)" line)
       (printf "~a\n" line) (read-all input))))
    
(for/list ([line (read-line (open-input-string header))])
  (printf "~a\n" line))