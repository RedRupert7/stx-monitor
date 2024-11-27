;; stx-monitor.clar
;; Constants for price thresholds and notification settings
(define-constant contract-owner tx-sender)
(define-constant PRICE_DECIMALS u6)
(define-constant MIN_NOTIFICATION_THRESHOLD u5) ;; 5% change
(define-constant MIN_PRICE u1) ;; Minimum valid price
(define-constant MAX_PRICE u1000000000) ;; Maximum valid price to prevent overflow

;; Data vars
(define-data-var last-price uint u0)
(define-data-var notification-threshold uint MIN_NOTIFICATION_THRESHOLD)

;; Data maps
(define-map user-notifications 
  { user: principal } 
  { enabled: bool, threshold: uint })

;; Error codes
(define-constant ERR_UNAUTHORIZED (err u403))
(define-constant ERR_INVALID_PRICE (err u401))
(define-constant ERR_INVALID_THRESHOLD (err u402))

;; Read-only functions
(define-read-only (get-last-price)
  (ok (var-get last-price)))

(define-read-only (get-user-settings (user principal))
  (match (map-get? user-notifications {user: user})
    settings (ok settings)
    (err u0)))

;; Public functions
(define-public (set-price (new-price uint))
  (begin
    ;; Check authorization
    (asserts! (is-eq tx-sender contract-owner) ERR_UNAUTHORIZED)
    ;; Validate price range
    (asserts! (and (>= new-price MIN_PRICE) (<= new-price MAX_PRICE)) ERR_INVALID_PRICE)
    
    (let
      (
        (old-price (var-get last-price))
        (validated-price new-price)
        (price-change (calculate-price-change old-price validated-price))
      )
      (var-set last-price validated-price)
      (notify-users validated-price old-price price-change)
      (ok true)
    )
  ))

(define-public (subscribe (threshold uint))
  (begin
    (asserts! (>= threshold MIN_NOTIFICATION_THRESHOLD) ERR_INVALID_THRESHOLD)
    (ok (map-set user-notifications
      {user: tx-sender}
      {enabled: true, threshold: threshold}))
  ))

(define-public (unsubscribe)
  (ok (map-delete user-notifications {user: tx-sender})))

;; Private functions
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