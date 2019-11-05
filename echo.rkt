#lang racket
(define listener (tcp-listen 8080))
(define (echo-server)
  (define-values [I O] (tcp-accept listener))
  (thread (λ()
            (copy-port I (current-output-port))
            (display "hello" I)
             (close-output-port O))))

(define stop (echo-server))