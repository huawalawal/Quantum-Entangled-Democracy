;; Proposal Management Contract

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-proposal (err u101))

(define-data-var proposal-counter uint u0)

(define-map proposals uint {
    title: (string-ascii 100),
    description: (string-utf8 1000),
    proposer: principal,
    start-block: uint,
    end-block: uint,
    status: (string-ascii 20)
})

(define-public (submit-proposal (title (string-ascii 100)) (description (string-utf8 1000)) (voting-period uint))
    (let
        ((proposal-id (+ (var-get proposal-counter) u1))
         (start-block (+ block-height u1))
         (end-block (+ start-block voting-period)))
        (asserts! (> (len title) u0) err-invalid-proposal)
        (asserts! (> (len description) u0) err-invalid-proposal)
        (asserts! (> voting-period u0) err-invalid-proposal)

        (map-set proposals proposal-id {
            title: title,
            description: description,
            proposer: tx-sender,
            start-block: start-block,
            end-block: end-block,
            status: "active"
        })
        (var-set proposal-counter proposal-id)
        (ok proposal-id)
    )
)

(define-public (update-proposal-status (proposal-id uint) (new-status (string-ascii 20)))
    (let ((proposal (unwrap! (map-get? proposals proposal-id) err-invalid-proposal)))
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (or (is-eq new-status "active") (is-eq new-status "completed") (is-eq new-status "cancelled")) err-invalid-proposal)

        (ok (map-set proposals proposal-id
            (merge proposal { status: new-status })))
    )
)

(define-read-only (get-proposal (proposal-id uint))
    (map-get? proposals proposal-id)
)

(define-read-only (get-proposal-count)
    (var-get proposal-counter)
)

