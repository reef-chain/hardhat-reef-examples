const hre = require("hardhat");

async function main() {
  // We will deploy Token contract with alice
  // It is going to have the pool of 1000000 tokens
  const acc = await hre.reef.getSignerByName("testnet_account");
  const Token = await hre.reef.getContractFactory("Usdc", acc);
  const args = ["USDC","USDC"];
  const token = await Token.deploy(...args);
//const token = await Token.attach('0x9b9a32c56c8F5C131000Acb420734882Cc601d39');
  await token.deployed();
  console.log("Deploy done");
  console.log({
    token: token.address,
  });
  await hre.reef.verifyContract(token.address, "Usdc", args);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
