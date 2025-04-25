### Digital Asset Licensing Smart Contract

A Clarity smart contract for the Stacks blockchain that enables creators to register digital assets and users to purchase licenses with different durations and privileges.

## Overview

This smart contract provides a decentralized platform for digital asset licensing, allowing creators to monetize their digital content (images, music, software, etc.) through a transparent and secure licensing system on the Stacks blockchain.

## Features

- **Asset Registration**: Creators can register their digital assets on the blockchain
- **Multiple License Types**: Support for Standard and Extended licenses with different durations and pricing
- **License Management**: Purchase, check status, transfer, and revoke licenses
- **Creator Controls**: Asset creators maintain control over availability and can revoke licenses if needed
- **Transparent Payments**: Direct payments from licensees to creators without intermediaries


## Contract Details

### Constants

- `STANDARD_LICENSE (u1)`: Identifier for the standard license tier
- `EXTENDED_LICENSE (u2)`: Identifier for the extended license tier
- `STANDARD_PRICE (u2000000)`: Price for standard license (2 STX)
- `EXTENDED_PRICE (u10000000)`: Price for extended license (10 STX)


### License Durations

- Standard License: 30 days (4320 blocks)
- Extended License: 60 days (8640 blocks)


## Functions

### For Creators

#### `register-asset`

Register a new digital asset on the blockchain.

```plaintext
(register-asset (name (string-ascii 64)))
```

- **Parameters**: `name` - Name of the asset (up to 64 ASCII characters)
- **Returns**: Asset ID (uint)


#### `disable-asset`

Make an asset unavailable for new licenses.

```plaintext
(disable-asset (asset-id uint))
```

- **Parameters**: `asset-id` - ID of the asset to disable
- **Returns**: Success/failure status


#### `revoke-license`

Revoke a user's license (only callable by the asset creator).

```plaintext
(revoke-license (user principal) (asset-id uint))
```

- **Parameters**:

- `user` - Principal of the license holder
- `asset-id` - ID of the licensed asset



- **Returns**: Success/failure status


### For Users

#### `purchase-license`

Purchase a license for a specific asset.

```plaintext
(purchase-license (asset-id uint) (license-type uint))
```

- **Parameters**:

- `asset-id` - ID of the asset to license
- `license-type` - Type of license (1 for Standard, 2 for Extended)



- **Returns**: Success/failure status


#### `get-license-status`

Check the status of a license.

```plaintext
(get-license-status (user principal) (asset-id uint))
```

- **Parameters**:

- `user` - Principal of the license holder
- `asset-id` - ID of the licensed asset



- **Returns**: License type and active status


#### `transfer-license`

Transfer an active license to another user.

```plaintext
(transfer-license (asset-id uint) (recipient principal))
```

- **Parameters**:

- `asset-id` - ID of the licensed asset
- `recipient` - Principal of the license recipient



- **Returns**: Success/failure status


## Error Codes

- `u1`: Invalid license type
- `u2`: STX transfer failed
- `u4`: Asset does not exist
- `u5`: Asset is not available
- `u6`: Not authorized (not the asset creator)
- `u7`: License does not exist
- `u8`: License is not active


## Usage Examples

### Registering an Asset

```plaintext
;; As a creator
(contract-call? .digital-asset-licensing register-asset "My Digital Artwork")
;; Returns (ok u1) where u1 is the asset ID
```

### Purchasing a License

```plaintext
;; As a user
(contract-call? .digital-asset-licensing purchase-license u1 u1)
;; Purchase a standard license (u1) for asset ID u1
;; Returns (ok true) if successful
```

### Checking License Status

```plaintext
;; Check if a license is active
(contract-call? .digital-asset-licensing get-license-status tx-sender u1)
;; Returns (ok {license-type: u1, active: true}) if license is active
```

### Transferring a License

```plaintext
;; Transfer a license to another user
(contract-call? .digital-asset-licensing transfer-license u1 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
;; Returns (ok true) if successful
```

## Deployment

To deploy this contract on the Stacks blockchain:

1. Install the [Clarinet](https://github.com/hirosystems/clarinet) development environment
2. Create a new project: `clarinet new digital-asset-licensing`
3. Replace the default contract with this contract
4. Test locally: `clarinet console`
5. Deploy to testnet/mainnet using Clarinet or the Stacks CLI


## Requirements

- Stacks blockchain
- Clarity language support
- STX tokens for contract deployment and license purchases


## Security Considerations

- The contract does not store the actual digital assets on-chain, only their registration information
- License purchases are non-refundable
- Asset creators should maintain off-chain records of their registered assets
- Users should verify asset authenticity before purchasing licenses


## License

This smart contract is released under the MIT License.
