# DolarCoin (DLC) - Binance Smart Chain Token

**DolarCoin (DLC)** is a decentralized token deployed on the Binance Smart Chain (BSC). This token operates with a fixed total supply of 21 million tokens, and it implements a mining mechanism where users are rewarded with tokens for mining. It also features a transaction fee system that is used to provide liquidity for future purchases.

## Features

- **Total Supply**: 21,000,000 DLC (fixed supply).
- **Mining**: Users mine DLC tokens by solving a cryptographic puzzle, and they are rewarded with DLC tokens.
- **Halving Mechanism**: Mining rewards are halved every 5,000 blocks.
- **Deflationary**: A percentage of the mined tokens are locked in the contract to provide liquidity.
- **Transaction Fees**: Every transaction has a small fee in BNB used to cover liquidity or to ensure the contract has enough BNB.

## How it Works

### Mining
DolarCoin uses a mining mechanism where users can solve a cryptographic puzzle to mine new blocks and earn rewards. The difficulty adjusts based on the time elapsed between blocks, creating a deflationary model.

- **Reward System**: The mining reward starts at 2000 DLC and decreases by half every 5,000 blocks.
- **Max Supply**: The total supply of DLC is capped at 21 million tokens. Once this limit is reached, no more tokens can be mined.

### Purchasing and Selling Tokens
DolarCoin tokens can be bought or sold through the contract using BNB:

- **Buying DLC**: Users can purchase DLC tokens by sending BNB to the contract. The price of DLC is adjusted dynamically based on the amount of available tokens in the contract.
- **Selling DLC**: Users can also sell their DLC tokens back to the contract and receive BNB in return.

### Transaction Fee
A small transaction fee (in BNB) is collected for each buy/sell transaction to ensure that the contract maintains enough liquidity for future transactions.

## How to Interact with the Contract

### Prerequisites
To interact with the DolarCoin contract, you will need:
- A wallet compatible with Binance Smart Chain (e.g., MetaMask).
- Some BNB in your wallet for gas fees and purchases.

### Functions Available
1. **buyTokens()**: Allows users to buy DLC tokens with BNB. The price of DLC is adjusted dynamically after each purchase.
2. **sellTokens()**: Allows users to sell their DLC tokens back to the contract in exchange for BNB.
3. **mineBlock()**: Allows users to mine DLC tokens by solving a cryptographic puzzle.
4. **getMiningReward()**: Returns the current mining reward available for the next block.
5. **approve()**: Allows users to approve a third party to spend DLC tokens on their behalf.
6. **transfer()**: Allows users to transfer DLC tokens to another address.
7. **getTokensForBNB()**: Returns the number of DLC tokens a user will receive in exchange for a specified amount of BNB.

