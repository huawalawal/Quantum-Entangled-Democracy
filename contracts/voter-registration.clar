;; Voter Registration Contract

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-already-registered (err u101))
(define-constant err-not-registered (err u102))

(define-map voters principal { registered: bool, quantum-id: (optional (buff 32)) })

(define-public (register-voter (quantum-id (buff 32)))
    (let ((current-voter-info (default-to { registered: false, quantum-id: none } (map-get? voters tx-sender))))
        (asserts! (not (get registered current-voter-info)) err-already-registered)
        (ok (map-set voters tx-sender { registered: true, quantum-id: (some quantum-id) }))
    )
)

(define-public (update-quantum-id (new-quantum-id (buff 32)))
    (let ((current-voter-info (default-to { registered: false, quantum-id: none } (map-get? voters tx-sender))))
        (asserts! (get registered current-voter-info) err-not-registered)
        (ok (map-set voters tx-sender (merge current-voter-info { quantum-id: (some new-quantum-id) })))
    )
)

(define-read-only (get-voter-info (voter principal))
    (default-to { registered: false, quantum-id: none } (map-get? voters voter))
)

(define-read-only (is-registered (voter principal))
    (get registered (get-voter-info voter))
)

