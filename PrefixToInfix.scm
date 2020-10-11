;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname PrefixToInfix) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
(require "Accumulate_Filter.scm")

(define (deriv exp var)
  (cond ((constant? exp) 0)
        ((same-variable? exp var) 1)
        ((sum? exp) (make-sum (deriv (addend exp) var)
                              (deriv (augend exp) var)))
        ((product? exp)
         (make-sum
          (make-product (multiplier exp)
                        (deriv (multiplicand exp) var))
          (make-product (deriv (multiplier exp) var)
                        (multiplicand exp))))
        (else
         (error "unknown expression type" exp))))

(define (sum? expr) 
  (eq? '+ (last-op expr))) 
  
(define (product? expr) 
  (eq? '* (last-op expr)))

(define (last-op expr) 
  (accumulate (lambda (a b) 
                (if (operator? b) 
                    (min-precedence a b) 
                    a)) 
              'maxop 
              expr))


(define *precedence-dictionary*   ;; maps operator symbols to their precedences
  '( (maxop 10000) 
     (minop -10000) 
     (+ 0) 
     (* 1) )) 
  
(define (operator? x) 
  (define (loop op-map) 
    (cond ((null? op-map) #f) 
          ((eq? x (caar op-map)) #t) 
          (else (loop (cdr op-map))))) 
  (loop *precedence-dictionary*)) 
  
(define (min-precedence a b) 
  (if (< (precedence a) (precedence b))
      a 
      b)) 
  
(define (precedence op)           ;; loops over precedence-dictionary to return precedence value of operator being queried
  (define (loop op-map) 
    (cond ((null? op-map) 
           10000) ;; if not an operator, return max operator value so that min-precedence returns other operator
          ((eq? op (caar op-map)) 
           (cdar op-map)) 
          (else 
           (loop (cdr op-map))))) 
  (loop *precedence-dictionary*))

(define (qmem sym list)
  (cond ((null? list) '())
        ((eq? sym (Car list)) list)
        (else (qmem sym (cdr list)))))

(define (augend expr) 
  (let ((a (cdr (memq '+ expr)))) 
    (if (singleton? a) 
        (car a) 
        a)))

(define (addend expr) 
  (let ((a (qmem '+ expr))) 
    (if (singleton? a) 
        (car a) 
        a)))

(define (multiplier expr) 
  (let ((m (qmem '* expr))) 
    (if (singleton? m) 
        (car m) 
        m))) 
  
(define (multiplicand expr) 
  (let ((m (cdr (memq '* expr)))) 
    (if (singleton? m) 
        (car m) 
        m)))

;; Final make-sum and make-product procedures with infix list notation
(define (make-sum a1 a2) 
  (cond ((=number? a1 0) a2) 
        ((=number? a2 0) a1) 
        ((and (number? a1) (number? a2)) 
         (+ a1 a2)) 
        (else (list a1 '+ a2))))

(define (make-product m1 m2) 
  (cond ((=number? m1 1)  m2) 
        ((=number? m2 1)  m1) 
        ((or (=number? m1 0) (=number? m2 0))  0) 
        ((and (number? m1) (number? m2)) 
         (* m1 m2)) 
        (else (list m1 '* m2)))) 