## Decentralized Crypto exchange on Ethereum

## 🔧 Project Diagram

<img width="1256" alt="Screen Shot 2022-10-17 at 9 58 17 AM" src="https://user-images.githubusercontent.com/85246268/196211782-ae60863b-ede3-44ce-9fba-5fd9e98fa6af.png">

<img width="1500" alt="Screen Shot 2022-10-17 at 9 58 28 AM" src="https://user-images.githubusercontent.com/85246268/196211804-081dc671-e12e-4092-aa2c-70c737bf85fa.png">

# My web3 portfolio starts with my own cryptocurrency exchange built on the Kovan network. 

In it you can deposit or withdraw tokens and place, cancel or fill orders. It logs every transaction and shows the token's price changes in a dynamic candle shart. For the back-end and test units I used Hardhat, JavaScript with Chai and for the front-end I used React, Redux and Ethers.

To use the Exchange you'll need to get NOAH from the faucet. Then deposit it in the Exchange and then you can fill orders with it. The only pair available right now is NOAH/COO. When you make a trade; you can withdraw your new tokens to visualize them in your wallet.

Follow the steps below to download, install, and run this project.

## Dependencies
Install these prerequisites to follow along with the tutorial. See free video tutorial or a full explanation of each prerequisite.
- NPM: https://nodejs.org
- Hardhat: https://hardhat.org/
- Metamask: https://metamask.io/

## Step 1. Clone the project
`git clone https://github.com/itahand/Crypto-Exchange`

## Step 2. Install dependencies
```
$ cd crypto-exchange
$ npm install


## Step 3. Run Hardhat network
```
$ npx hardhat node
$ npx hardhat run --network localhost scripts/1_deploy.js
