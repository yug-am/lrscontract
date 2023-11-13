# Land Registry Contract

Indian land registration system Proof Of Concept based on Blockchain.
The Smart Contract focuses on minimizing disruptions with the current Indian system and is in line with [Torren's System](https://en.wikipedia.org/wiki/Torrens_title) as the insurance can be guaranteed by court Order.


## Deploying the contract
The contract can be deployed on an Ethereum chain using various [tools](https://ethereum.org/en/developers/docs/smart-contracts/deploying/) including [Truffle](https://trufflesuite.com/) and [Remix](https://remix.ethereum.org/) 

## Truffle Quick Run
The contract can be quickly deployed and tested in a Truffle [development environment](https://trufflesuite.com/docs/truffle/how-to/debug-test/use-truffle-develop-and-the-console/) 
There is no need for accounts setup, chain configuration and blockchain client.

### Installation

Truffle Installation [documentation](https://trufflesuite.com/docs/truffle/how-to/install/)

### Starting Development Environment

```
 truffle develop
```

### Deploying
Navigate to project directory and run the migrate command

```
truffle migrate
```

### Interaction

Get contract instance

```
let instance = await LR.deployed()

```

#### Examples: createRegistryOffice (call from acc[0]) making acc[1] land reg. office

- Use instance variable to interact with the contract
- Accounts array can be accessed from accounts

```
await instance.createRegistryOffice(accounts[1],1,'Kerala',3,673601,{from:dac});
```


## Deploying on Chain

The contract can be deployed on chain using [Remix](https://remix.ethereum.org/) [deployment](https://remix-ide.readthedocs.io/en/latest/create_deploy.html) or [Truffle](https://trufflesuite.com/) using `truffle-config.js` [configuration](https://trufflesuite.com/docs/truffle/reference/configuration/)

Post deployment, the [Web3](https://web3js.readthedocs.io/en/v1.2.11/web3-eth.html) APIs can be used for contract interaction


#### Deployment check

```
console.log(eth.getCode('contractAddress'));
```

#### Contract Instance

##### [Geth](https://geth.ethereum.org/) console example 

We will first get Application Binary Interface(ABI), which is the standard way to interact with contracts in ethereum [ref](https://docs.soliditylang.org/en/latest/abi-spec.html). Then we will create the contract instance.
Replace <content> with your contract values

- Get ABI from value of 'abi' key in the  contract json file  `./build/contracts/LR.json` 
- `var contractABI = <Above ABI>`
- `var  contractAddress = '<Contract Address>'` 
- `var contractInstance = web3.eth.contract(contractABI).at(contractAddress);`	

##### create LRO example
```contractInstance.createRegistryOffice.sendTransaction(<lro_acc_address>,1,'Kerala',3,673601,{from:<department_acc>, gasPrice: 1});```

![Eth](https://img.shields.io/badge/Ethereum-3C3C3D?style=for-the-badge&logo=Ethereum&logoColor=white)
![Solidity](https://img.shields.io/badge/Solidity-e6e6e6?style=for-the-badge&logo=solidity&logoColor=black)