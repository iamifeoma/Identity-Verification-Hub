# Identity Verification Hub 🔐

A decentralized identity verification system built on Stacks blockchain that enables secure, transparent, and user-controlled identity validation.

## 🚀 Features

- **Decentralized Verification**: No single point of failure or control
- **Multi-level Trust System**: Three-tier trust levels (Basic, Standard, Premium)
- **User Self-Sovereignty**: Users maintain full control over their identity data
- **Transparent Validation**: All verification actions are recorded on-chain
- **Flexible Administration**: Contract admin can manage validator network
- **Self-Revocation**: Users can revoke their own verification status

## 🏗️ Architecture

### Trust Levels
- **Level 1 (Basic)**: Basic identity verification
- **Level 2 (Standard)**: Enhanced identity verification with additional checks
- **Level 3 (Premium)**: Maximum security verification with comprehensive validation

### Key Components
- **Contract Admin**: Manages the validator network
- **Authorized Validators**: Perform identity verification
- **Identity Registry**: Stores verification records on-chain
- **Credential Hashing**: Secure storage of identity data hashes

## 📋 Smart Contract Functions

### Administrative Functions
- `authorize-validator`: Add new validators to the network
- `revoke-validator`: Remove validators from the network

### Verification Functions
- `verify-identity`: Validate user identity with specified trust level
- `revoke-identity-verification`: Remove verification status
- `update-trust-level`: Modify existing verification trust level
- `self-revoke-identity`: User-initiated verification removal

### Query Functions
- `is-authorized-validator`: Check validator authorization status
- `is-identity-verified`: Check if identity is verified
- `get-identity-record`: Retrieve complete verification record
- `get-identity-trust-level`: Get current trust level

## 🔧 Usage

### For Validators
1. Get authorized by the contract admin
2. Verify user identities with appropriate trust levels
3. Maintain verification records and update as needed

### For Users
1. Submit identity information to authorized validators
2. Receive verification with assigned trust level
3. Manage your verification status (including self-revocation)

### For Third Parties
1. Query verification status of any address
2. Check trust levels for risk assessment
3. Verify validator authorization before trusting verification

## 🛡️ Security Features

- **Access Control**: Only authorized validators can perform verifications
- **Data Integrity**: Credential hashes ensure data hasn't been tampered with
- **Audit Trail**: All actions are recorded with timestamps and validator info
- **User Control**: Users can revoke their own verification at any time

## 🚦 Error Codes

| Code | Description |
|------|-------------|
| 100  | Access denied |
| 101  | Validator already exists |
| 102  | Invalid validator |
| 103  | Identity already verified |
| 104  | Identity not found |
| 105  | Invalid trust level |
| 106  | Admin-only function |
| 107  | Invalid credential hash |

## 📦 Deployment

Deploy the contract to Stacks blockchain using Clarinet or your preferred deployment tool. The deploying address automatically becomes the contract admin.

## 🤝 Contributing

Contributions are welcome! Please ensure all changes maintain security standards and include appropriate tests.