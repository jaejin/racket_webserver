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

(define (handle in out)
  (display "<html><body>hello</body></html>" out)
  (let* ([header (read-header (list) in)]
         [request-line (first header)]
         [others (parse-header (make-hash) (rest header))]
         [content-length (string->number (string-trim (first
                                                       (hash-ref others "content-length" '("0")))))])
   (when (> content-length 0)
     (display (read-bytes content-length  in)))))


(define (read-header header current-input)
  (let* ([line (read-line current-input 'any)]
        [length (string-length line)]
        [result (append header (list line))])
    (if (> length 0)
        (read-header result current-input)
        result)))


(define (parse-header header header-data )
  (let* ([data (first header-data)]
         [rest-data (rest header-data)]
         [length (string-length data)])
    (if (> length 0)
      (let* ([splited-data (string-split data ":")])
        (hash-set! header (string-downcase (first splited-data)) (rest splited-data))
        (parse-header header rest-data))
      header)))
  

(define stop (serve 8080))