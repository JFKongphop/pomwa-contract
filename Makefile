com:
	npx hardhat compile

call:
	node shortcuts/call.js

gt:
	npx hardhat test test/groth16Verifier.ts 

ht:
	npx hardhat test test/hasher.ts 

deploy:
	npx hardhat run --network ${chain} scripts/deploy.ts

dph:
	npx hardhat run --network scroll scripts/hasher.ts

dpv:
	npx hardhat run --network scroll scripts/groth16Verifier.ts

dpd:
	npx hardhat run --network sepolia scripts/deposit.ts

dpw:
	npx hardhat run --network scroll scripts/withdraw.ts

slt:
	node shortcuts/sendLinkToken.js

