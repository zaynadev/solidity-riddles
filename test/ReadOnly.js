const { time, loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");

const NAME = "ReadOnlyPool";

describe(NAME, function () {
    async function setup() {
        const [, attackerWallet] = await ethers.getSigners();

        const ReadOnlyFactory = await ethers.getContractFactory(NAME);
        const readOnlyContract = await ReadOnlyFactory.deploy();

        const VulnerableDeFiFactory = await ethers.getContractFactory("VulnerableDeFiContract");
        const vulnerableDeFiContract = await VulnerableDeFiFactory.deploy(readOnlyContract.address);

        await readOnlyContract.addLiquidity({
            value: ethers.utils.parseEther("100"),
        });
        await readOnlyContract.earnProfit({ value: ethers.utils.parseEther("1") });
        await vulnerableDeFiContract.snapshotPrice();

        // you start with 2 ETH
        await network.provider.send("hardhat_setBalance", [
            attackerWallet.address,
            ethers.utils.parseEther("2.0").toHexString(),
        ]);

        return {
            readOnlyContract,
            vulnerableDeFiContract,
            attackerWallet,
        };
    }

    describe("exploit", async function () {
        let readOnlyContract, vulnerableDeFiContract, attackerWallet;
        before(async function () {
            ({ readOnlyContract, vulnerableDeFiContract, attackerWallet } = await loadFixture(setup));
        });

        // prettier-ignore
        it("conduct your attack here", async function () {
      
            const ReadOnlyPoolAttacker = await ethers.getContractFactory("ReadOnlyPool_Attacker");
            const readOnlyPoolAttacker = await ReadOnlyPoolAttacker.deploy(readOnlyContract.address,vulnerableDeFiContract.address);
            await attackerWallet.sendTransaction({
                to: readOnlyPoolAttacker.address,
                value: ethers.utils.parseEther("1.8"),
            });
            await readOnlyPoolAttacker.connect(attackerWallet).exploit();
    });

        after(async function () {
            console.log(await vulnerableDeFiContract.lpTokenPrice());
            expect(await vulnerableDeFiContract.lpTokenPrice()).to.be.equal(0, "snapshotPrice should be zero");
            expect(await ethers.provider.getTransactionCount(attackerWallet.address)).to.lessThan(
                3,
                "must exploit two transactions or less"
            );
        });
    });
});
