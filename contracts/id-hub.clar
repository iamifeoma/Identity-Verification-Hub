;; Identity Verification Hub Smart Contract
;; This contract implements a decentralized identity verification system where:
;; 1. Authorized validators can verify user identities
;; 2. Users can submit their credentials for validation
;; 3. Third parties can check verification status
;; 4. Users maintain full control over their identity credentials

(define-constant contract-admin tx-sender)

;; Error codes
(define-constant err-access-denied (err u100))
(define-constant err-validator-exists (err u101))
(define-constant err-invalid-validator (err u102))
(define-constant err-identity-verified (err u103))
(define-constant err-identity-not-found (err u104))
(define-constant err-invalid-trust-level (err u105))
(define-constant err-admin-only (err u106))
(define-constant err-invalid-credential-hash (err u107))

;; Data structures
(define-map authorized-validators principal bool)
(define-map identity-registry 
  { identity: principal } 
  { 
    is-verified: bool, 
    trust-level: uint, 
    validation-timestamp: uint, 
    credential-hash: (buff 32),
    validator-address: principal 
  }
)

;; Trust levels
;; 1 = Basic trust level
;; 2 = Standard trust level
;; 3 = Premium trust level

;; Read-only functions

;; Check if an address is an authorized validator
(define-read-only (is-authorized-validator (validator-address principal))
  (default-to false (get-validator-status validator-address))
)

;; Get validator authorization status
(define-read-only (get-validator-status (validator-address principal))
  (map-get? authorized-validators validator-address)
)

;; Check if an identity is verified
(define-read-only (is-identity-verified (identity-address principal))
  (default-to false (get is-verified (get-identity-record identity-address)))
)

;; Get complete identity verification record
(define-read-only (get-identity-record (identity-address principal))
  (map-get? identity-registry { identity: identity-address })
)

;; Get identity trust level
(define-read-only (get-identity-trust-level (identity-address principal))
  (default-to u0 (get trust-level (get-identity-record identity-address)))
)

;; Helper function to validate trust level
(define-private (is-valid-trust-level (level uint))
  (or (is-eq level u1) (is-eq level u2) (is-eq level u3))
)

;; Helper function to validate credential hash (non-zero)
(define-private (is-valid-credential-hash (hash (buff 32)))
  (not (is-eq hash 0x0000000000000000000000000000000000000000000000000000000000000000))
)

;; Public functions

;; Add a new validator (only contract admin can do this)
(define-public (authorize-validator (validator-address principal))
  (begin
    (asserts! (is-eq tx-sender contract-admin) err-access-denied)
    (asserts! (not (is-authorized-validator validator-address)) err-validator-exists)
    (ok (map-set authorized-validators validator-address true))
  )
)

;; Remove a validator (only contract admin can do this)
(define-public (revoke-validator (validator-address principal))
  (begin
    (asserts! (is-eq tx-sender contract-admin) err-access-denied)
    (asserts! (is-authorized-validator validator-address) err-invalid-validator)
    (ok (map-set authorized-validators validator-address false))
  )
)

;; Verify an identity (only authorized validators can do this)
(define-public (verify-identity (identity-address principal) (trust-level uint) (credential-hash (buff 32)))
  (begin
    (asserts! (is-authorized-validator tx-sender) err-access-denied)
    (asserts! (is-valid-trust-level trust-level) err-invalid-trust-level)
    (asserts! (is-valid-credential-hash credential-hash) err-invalid-credential-hash)
    
    ;; Store the identity verification record
    (let ((identity-key { identity: identity-address })
          (verification-record { 
            is-verified: true, 
            trust-level: trust-level, 
            validation-timestamp: block-height, 
            credential-hash: credential-hash,
            validator-address: tx-sender 
          }))
      (ok (map-set identity-registry identity-key verification-record))
    )
  )
)

;; Revoke identity verification (can be done by the validator who verified the identity or contract admin)
(define-public (revoke-identity-verification (identity-address principal))
  (let ((current-record (unwrap! (get-identity-record identity-address) err-identity-not-found))
        (identity-key { identity: identity-address })
        (revoked-record { 
          is-verified: false, 
          trust-level: u0, 
          validation-timestamp: block-height, 
          credential-hash: 0x0000000000000000000000000000000000000000000000000000000000000000,
          validator-address: tx-sender 
        }))
    (begin
      (asserts! (or 
                 (is-eq tx-sender (get validator-address current-record))
                 (is-eq tx-sender contract-admin)) 
                err-access-denied)
      (ok (map-set identity-registry identity-key revoked-record))
    )
  )
)

;; Users can remove their own identity verification (self-revocation)
(define-public (self-revoke-identity)
  (let ((identity-address tx-sender)
        (identity-key { identity: tx-sender })
        (revoked-record { 
          is-verified: false, 
          trust-level: u0, 
          validation-timestamp: block-height, 
          credential-hash: 0x0000000000000000000000000000000000000000000000000000000000000000,
          validator-address: tx-sender 
        }))
    (begin
      (asserts! (is-identity-verified identity-address) err-identity-not-found)
      (ok (map-set identity-registry identity-key revoked-record))
    )
  )
)

;; Update trust level (only authorized validators can do this)
(define-public (update-trust-level (identity-address principal) (new-trust-level uint))
  (let ((current-record (unwrap! (get-identity-record identity-address) err-identity-not-found))
        (identity-key { identity: identity-address }))
    (begin
      (asserts! (is-authorized-validator tx-sender) err-access-denied)
      (asserts! (is-valid-trust-level new-trust-level) err-invalid-trust-level)
      
      ;; Create an updated record with the new trust level
      (let ((updated-record (merge current-record { trust-level: new-trust-level })))
        (ok (map-set identity-registry identity-key updated-record))
      )
    )
  )
)