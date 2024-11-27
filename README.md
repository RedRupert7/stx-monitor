

# STX Price Monitor Smart Contract

A Clarity smart contract for monitoring STX price movements and notifying users of significant price changes on the Stacks blockchain.

## Features

- Real-time STX price monitoring
- Customizable price change notifications
- User subscription management
- Secure price updates via authorized oracle
- Configurable notification thresholds
- Event-driven architecture for off-chain notifications

## Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) installed
- [Node.js](https://nodejs.org/) (v14 or higher) for running off-chain services
- Access to a Stacks node (local or network)

## Final Project Structure
## Note: still in progress
```
stx-price-monitor/
├── contracts/          # Smart contract files
├── tests/             # Contract test files
├── scripts/           # Deployment and utility scripts
├── settings/          # Environment configurations
└── off-chain/         # Price monitoring service
```

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/stx-price-monitor.git
cd stx-price-monitor
```

2. Install dependencies:
```bash
clarinet requirements
cd off-chain && npm install
```

3. Configure your environment:
```bash
cp settings/Devnet.toml.example settings/Devnet.toml
# Edit settings/Devnet.toml with your configuration
```

## Smart Contract Usage

### Deploying the Contract

```bash
clarinet deploy --network testnet
```

### User Functions

1. Subscribe to price notifications:
```clarity
(contract-call? .stx-monitor subscribe u10) ;; 10% threshold
```

2. Unsubscribe from notifications:
```clarity
(contract-call? .stx-monitor unsubscribe)
```

3. Check current price:
```clarity
(contract-call? .stx-monitor get-last-price)
```

### Admin Functions

1. Update STX price (only contract owner):
```clarity
(contract-call? .stx-monitor set-price u100)
```

## Off-Chain Service

The off-chain service monitors contract events and sends notifications to subscribed users.

### Starting the Service

```bash
cd off-chain
npm run build
npm start
```

### Configuration

Edit `off-chain/config/default.json` to configure:
- Price update frequency
- Notification methods
- API endpoints
- Network settings

## Testing

Run contract tests:
```bash
clarinet test
```

Run off-chain service tests:
```bash
cd off-chain && npm test
```

## Security Considerations

- Only the contract owner can update prices
- Minimum notification threshold enforced
- Rate limiting on subscription changes
- Protected user settings
- Input validation for all public functions

## Events and Notifications

The contract emits events for:
- Price updates
- Threshold crossings
- Subscription changes

Event format:
```json
{
  "event": "price-change",
  "old-price": "uint",
  "new-price": "uint",
  "change-percentage": "uint",
  "direction": "string"
}
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

Your Name - [@yourusername](https://twitter.com/yourusername)
Project Link: [https://github.com/yourusername/stx-price-monitor](https://github.com/yourusername/stx-price-monitor)

## Acknowledgments

- Stacks Foundation
- Clarity Language Documentation
- Community Contributors
