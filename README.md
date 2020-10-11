# Prefix to infix notation in Scheme 

This is a continuation of the [symbolic-differentiator](https://github.com/muffpy/symbolic-differentiator) repo. Scheme uses **paranthesized prefix notation** to evaluate expressions (like much of the members in the Lisp family of dialects.) Now, we change the representation of **prefix** operators **`+`** and **`*`** in our language to **infix form**.

Recall the `deriv` procedure:
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
```
---------------------------------------------------------------------------

The two primary observations to approach this problem:
* Recognising that the given expression is a _sum_ or a _product_,i.e, the last one applied to the terms if the expression is evaluated.
* The parantheses are **ambiguous** in the expression. On one hand, they enclose mathematical sub-expressions and OOTH, they are sub-lists in the list structure and hence, can be recursed upon.
                  
## sum? or product?
To tell what sort of expression we have, we find the last operator applied to the terms. This has to be the operator with the **lowest precedence** among all the visible ones. The predicates `sum?` and `product?` will search out the lowest-precedence operator - 
```
 (define (sum? expr) 
   (eq? '+ (last-op expr))) 
  
 (define (product? expr) 
   (eq? '* (last-op expr))) 
```

Where last-op searches an expression for the lowest-precedence operator, which can be done as an **accumulation** (zip in Haskell):
```
 (define (last-op expr) 
   (accumulate (lambda (a b) 
                 (if (operator? b) 
                     (min-precedence a b) 
                     a)) 
               'maxop 
               expr)) 
```
Basically the accumulation of the cdr of the list returns the lowest-precedence operator in the last n-1 terms. We compare this with the first element to get the result. This is obviously done **recursively**. 

And now we define the predicates and selectors we used:
- `operator?` : returns true if symbol is a recognisible operator

- `min-precedence` : returns the _"minimum"_ of two operators

- `'max-op` : a placeholder that always has a greater precedence than any operator

Translating this to code:
```
 (define *precedence-dictionary*   ;; maps operator symbols to their precedences
   '( (maxop . 10000) 
      (minop . -10000) 
      (+ . 0) 
      (* . 1) )) 
  
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
```

## Constructors and selectors
So now that **sums** and **products** can be identified in this language, we look at ways of _extracting_ their parts or _making_ new ones. 
Given the smallest-precedence operator, we can find the preceding and succeeding lists using `memq` and its (made up) opposite `qmem`:
```
(define (qmem sym list)
       (cond ((null? list) '())
             ((eq? sym (Car list)) list)
             (else (qmem sym (cdr list)))))
```
We define `make-sum` and `make-product` using these tools. [PrefixToInfix.scm](PrefixToInfix.scm) contains these procedures along with their prediactes.

## Testing

```
]=> (deriv '(x + 3 * (x + y + 2)) 'x)
4

]=> (deriv '(x + 3) 'x)
1

]=> (deriv '(x * y * (x + 3)) 'x)
((x * y) + (y * (x + 3)))

```






