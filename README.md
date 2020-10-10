# Prefix to infix notation in Scheme 

This is a continuation of the [symbolic-differentiator](https://github.com/muffpy/symbolic-differentiator) repo. Scheme uses **paranthesized prefix notation** to evaluate expressions (like much of the members in the Lisp family of dialects.) Now, we change the representation of **prefix** operators **`+`** and **`*`** in our language to **infix form**.

Recall the `deriv` procedure and the constructors `make-sum` and `make-product`:
```
(define (deriv exp var)
       (cond ((constant? exp) 0)
              ((same-variable? exp var) 1))
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
                  
 ;; Sums and products constructed using lists mirroring parenthesized prefix notation t
(define (make-sum a1 a2) 
  (cond ((=number? a1 0) a2) 
        ((=number? a2 0) a1) 
        ((and (number? a1) (number? a2)) (+ a1 a2)) 
        (else (list '+ a1 a2)))) 
  
(define (make-product m1 m2) 
  (cond ((or (=number? m1 0) (=number? m2 0)) 0) 
        ((=number? m1 1) m2) 
        ((=number? m2 1) m1) 
        ((and (number? m1) (number? m2)) (* m1 m2)) 
        (else (list '* m1 m2))))       
```
                  
                  

