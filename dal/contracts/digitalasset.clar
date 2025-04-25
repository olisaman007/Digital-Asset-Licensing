;; Define constants for license types
(define-constant STANDARD_LICENSE u1)
(define-constant EXTENDED_LICENSE u2)

;; Define prices for each license type (in microSTX)
(define-constant STANDARD_PRICE u2000000) ;; 2 STX
(define-constant EXTENDED_PRICE u10000000) ;; 10 STX

;; Define the licenses map: user principal -> (asset-id, license-type, expiration)
(define-map licenses { user: principal, asset-id: uint } { license-type: uint, expiration: uint })

;; Define assets map to track available assets
(define-map assets uint { name: (string-ascii 64), creator: principal, available: bool })

;; Asset counter
(define-data-var asset-counter uint u0)

;; Helper function to get the current block height
(define-read-only (get-current-block-height)
  stacks-block-height)

;; Helper function to get the price for a given license type
(define-private (get-license-price (license-type uint))
  (if (is-eq license-type STANDARD_LICENSE)
      STANDARD_PRICE
      EXTENDED_PRICE))

;; Helper function to get license duration in blocks
(define-private (get-license-duration (license-type uint))
  (if (is-eq license-type STANDARD_LICENSE)
      u4320 ;; 30 days (144 blocks per day)
      u8640)) ;; 60 days

;; Function to register a new asset
(define-public (register-asset (name (string-ascii 64)))
  (let ((asset-id (+ (var-get asset-counter) u1)))
    (map-set assets asset-id { name: name, creator: tx-sender, available: true })
    (var-set asset-counter asset-id)
    (ok asset-id)))

;; Function to purchase a license
(define-public (purchase-license (asset-id uint) (license-type uint))
  (let ((price (get-license-price license-type))
        (current-height (get-current-block-height))
        (duration (get-license-duration license-type))
        (asset (map-get? assets asset-id)))
    (asserts! (is-some asset) (err u4)) ;; Asset must exist
    (asserts! (get available (unwrap-panic asset)) (err u5)) ;; Asset must be available
    
    (if (is-eq license-type STANDARD_LICENSE)
        (process-license-purchase asset-id license-type price current-height duration)
        (if (is-eq license-type EXTENDED_LICENSE)
            (process-license-purchase asset-id license-type price current-height duration)
            (err u1))))) ;; Invalid license type

;; Helper function to process license purchase
(define-private (process-license-purchase (asset-id uint) (license-type uint) (price uint) (current-height uint) (duration uint))
  (let ((expiration (+ current-height duration))
        (asset-creator (get creator (unwrap-panic (map-get? assets asset-id)))))
    (if (is-ok (stx-transfer? price tx-sender asset-creator))
        (begin
          (map-set licenses { user: tx-sender, asset-id: asset-id } { license-type: license-type, expiration: expiration })
          (ok true))
        (err u2)))) ;; STX transfer failed

;; Function to check license status
(define-read-only (get-license-status (user principal) (asset-id uint))
  (let ((license (map-get? licenses { user: user, asset-id: asset-id })))
    (if (is-some license)
        (let ((lic (unwrap-panic license)))
          (if (>= (get expiration lic) (get-current-block-height))
              (ok { license-type: (get license-type lic), active: true })
              (ok { license-type: u0, active: false })))
        (ok { license-type: u0, active: false }))))

;; Function to revoke a license (only asset creator can do this)
(define-public (revoke-license (user principal) (asset-id uint))
  (let ((asset (map-get? assets asset-id)))
    (asserts! (is-some asset) (err u4)) ;; Asset must exist
    (asserts! (is-eq (get creator (unwrap-panic asset)) tx-sender) (err u6)) ;; Only creator can revoke
    
    (if (map-delete licenses { user: user, asset-id: asset-id })
        (ok true)
        (err u7)))) ;; License doesn't exist

;; Function to transfer license to another user
(define-public (transfer-license (asset-id uint) (recipient principal))
  (let ((license (map-get? licenses { user: tx-sender, asset-id: asset-id })))
    (asserts! (is-some license) (err u7)) ;; License must exist
    (asserts! (>= (get expiration (unwrap-panic license)) (get-current-block-height)) (err u8)) ;; License must be active
    
    (map-delete licenses { user: tx-sender, asset-id: asset-id })
    (map-set licenses { user: recipient, asset-id: asset-id } (unwrap-panic license))
    (ok true)))

;; Function to disable an asset (make it unavailable for new licenses)
(define-public (disable-asset (asset-id uint))
  (let ((asset (map-get? assets asset-id)))
    (asserts! (is-some asset) (err u4)) ;; Asset must exist
    (asserts! (is-eq (get creator (unwrap-panic asset)) tx-sender) (err u6)) ;; Only creator can disable
    
    (map-set assets asset-id (merge (unwrap-panic asset) { available: false }))
    (ok true)))