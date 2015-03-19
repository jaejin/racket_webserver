#lang racket
(require (rename-in "http_driver.rkt" 
                   (start http-start)))

(define (start)
  (thread 
   (lambda ()
      (http-start 80)
      (display "start"))))


(start)