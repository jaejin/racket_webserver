#lang racket
(define (serve port-no)
  (define main-cust (make-custodian))
  (parameterize ([current-custodian main-cust])
    (define listener (tcp-listen port-no 5 #t))
    (define (loop)
      (accept-and-handle listener)
      (loop))
    (thread loop))
  (lambda ()
    (custodian-shutdown-all main-cust)))


(define (accept-and-handle listener)
  (define cust (make-custodian))
  (parameterize ([current-custodian cust])
    (define-values (in out) (tcp-accept listener))
    (thread (lambda ()
              (handle in out)
              (close-input-port in)
              (close-output-port out))))
  ; Watcher thread:
  (thread (lambda ()
            (sleep 10)
            (custodian-shutdown-all cust))))


(define (read-all input)
  (let ([line (read-line input 'return-linefeed)])
    (when (eof-object? line) (read-all input))
    (log-info "~a\n" line)
    (if (regexp-match #rx"(^$)|((^|[^\r])\n)" line) (log-info "end") (read-all input))))

(define (handle in out)
  (read-all in)
  (fprintf out "~a\r\n" "HTTP/1.1 200 OK\r\n\r\n<html><body>hello</body></html>"))

(define stop (serve 8080))
