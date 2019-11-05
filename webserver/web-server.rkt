#lang racket
(provide/contract
 [do-not-return (-> void)])

(define (do-not-return)
  (printf "run do-not-return\n")
  (semaphore-wait (make-semaphore 0)))

