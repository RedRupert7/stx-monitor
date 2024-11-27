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
  ;; Added subscription functionality
(define-constant MIN_NOTIFICATION_THRESHOLD u5)
(define-data-var notification-threshold uint MIN_NOTIFICATION_THRESHOLD)

(define-map user-notifications 
  { user: principal } 
  { enabled: bool, threshold: uint })

(define-public (subscribe (threshold uint))
  (begin
    (asserts! (>= threshold MIN_NOTIFICATION_THRESHOLD) (err u400))
    (ok (map-set user-notifications
      {user: tx-sender}
      {enabled: true, threshold: threshold}))))

(define-public (unsubscribe)
  (ok (map-delete user-notifications {user: tx-sender})))
  ;; Added notification system
(define-private (notify-users (new-price uint) (old-price uint) (price-change uint))
  (begin
    (if (> price-change (var-get notification-threshold))
      (begin
        (print {
          event: "price-change",
          old-price: old-price,
          new-price: new-price,
          change-percentage: price-change,
          direction: (if (> new-price old-price) "increased" "decreased")
        })
        true)
      true)
    true))
    ;; Added validation constants and error codes
(define-constant MIN_PRICE u1)
(define-constant MAX_PRICE u1000000000)
(define-constant ERR_UNAUTHORIZED (err u403))
(define-constant ERR_INVALID_PRICE (err u401))
(define-constant ERR_INVALID_THRESHOLD (err u402))

;; Updated set-price with validation
(define-public (set-price (new-price uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) ERR_UNAUTHORIZED)
    (asserts! (and (>= new-price MIN_PRICE) (<= new-price MAX_PRICE)) ERR_INVALID_PRICE)
    (let
      ((old-price (var-get last-price))
       (validated-price new-price)
       (price-change (calculate-price-change old-price validated-price)))
      (var-set last-price validated-price)
      (notify-users validated-price old-price price-change)
      (ok true))))