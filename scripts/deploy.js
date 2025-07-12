const hre = require("hardhat");

async function main() {
  const PrivateVote = await hre.ethers.getContractFactory("PrivateVote");
  const privateVote = await PrivateVote.deploy();
  await privateVote.deployed();
  console.log("PrivateVote deployed to:", privateVote.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
