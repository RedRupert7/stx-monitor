;; stx-monitor.clar
(define-constant contract-owner tx-sender)
(define-data-var last-price uint u0)

(define-public (set-price (new-price uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err u403))
    (var-set last-price new-price)
    (ok true)))

(define-read-only (get-last-price)
  (ok (var-get last-price)))