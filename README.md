# MEME merchant contract

Contract that works with offchain backend service (python) to summon a random meme picture.

## Step to deploy on local
1. Start ganache with the command `ganache-cli` (*Note: you might need to install ganache with npm, follow steps [here](https://www.npmjs.com/package/ganache-cli))
2. Select 1 private key from the ganache list above, replace variable `private_key` 
3. Run all the cells in `deploy.ipynb`. Take note of the deployed contract address (var `exploit_address`)
4. From `process.ipynb`, update `exploit_address`, and owner's private key (var `private_key`).
5. Run all the cells until `Withdraw funds with the following cells` (note: the last cell will run infinity as it will be served as backend service) 
6. From `sample-call.ipynb`, update `exploit_address`, `YOUR_SK`, `YOUR_PK`. 
7. Run all the cells in `sample-call.ipynb`.

## Process Flow
![Process flow](./flow.png)
