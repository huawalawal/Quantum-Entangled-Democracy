;; Vote Counting Contract

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-vote (err u101))
(define-constant err-voting-closed (err u102))

(define-map votes { proposal-id: uint, voter: principal } { choice: (string-ascii 10) })
(define-map vote-counts { proposal-id: uint, choice: (string-ascii 10) } uint)

(define-public (cast-vote (proposal-id uint) (choice (string-ascii 10)))
    (let ((proposal (unwrap! (contract-call? .proposal-management get-proposal proposal-id) err-invalid-vote)))
        (asserts! (< block-height (get end-block proposal)) err-voting-closed)
        (asserts! (contract-call? .voter-registration is-registered tx-sender) err-invalid-vote)
        (asserts! (or (is-eq choice "yes") (is-eq choice "no") (is-eq choice "abstain")) err-invalid-vote)

        (map-set votes { proposal-id: proposal-id, voter: tx-sender } { choice: choice })
        (map-set vote-counts
            { proposal-id: proposal-id, choice: choice }
            (+ (default-to u0 (map-get? vote-counts { proposal-id: proposal-id, choice: choice })) u1)
        )
        (ok true)
    )
)

(define-read-only (get-vote (proposal-id uint) (voter principal))
    (map-get? votes { proposal-id: proposal-id, voter: voter })
)

(define-read-only (get-vote-count (proposal-id uint) (choice (string-ascii 10)))
    (default-to u0 (map-get? vote-counts { proposal-id: proposal-id, choice: choice }))
)

