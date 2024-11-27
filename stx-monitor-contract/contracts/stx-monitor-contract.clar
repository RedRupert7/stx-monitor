;; stx-monitor.contract
(define-constant contract-owner tx-sender)
(define-data-var last-price uint u0)

(define-public (set-price (new-price uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err u403))
    (var-set last-price new-price)
    (ok true)))

(define-read-only (get-last-price)
  (ok (var-get last-price)))
  ;; Added functions
(define-constant PRICE_DECIMALS u6)

(define-private (calculate-price-change (old-price uint) (new-price uint))
  (let
    (
      (price-diff (if (> new-price old-price)
        (- new-price old-price)
        (- old-price new-price)))
      (percentage (* (/ (* price-diff u100) old-price) u1))
    )
    percentage
  ))