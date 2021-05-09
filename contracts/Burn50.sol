// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Burn50 {

    uint256 public burntBalance;
    mapping(address => uint256) public balances;
    mapping(address => address) public ancestry;
    mapping(address => address[]) public reverseAncestry;
    
    event NewRelation(address parent, address child);
    event RoyaltyPaid(address byAddress, address toAddress, uint256 royaltyFee);
    event EarnedBonus(address receiver, uint256 bonusAmount);

    function join() public payable {
        require(ancestry[msg.sender] == address(0), "Account already exists");
        require(msg.value >= 20000000 gwei, "Atleast 0.02 required");
        ancestry[msg.sender] = address(0x1);
        reverseAncestry[address(0x1)].push(msg.sender);
        balances[address(0x1)] += msg.value;
        emit NewRelation(address(0x1), msg.sender);
    }
    
    function invite(address newAddress) public payable {
        require(ancestry[msg.sender] != address(0), "Account does not exist");
        require(ancestry[newAddress] == address(0), "Account already exists");
        require(msg.value >= 2000000 gwei, "Atleast 0.002 required");
        uint256 bonusBalance = balances[address(0x1)];
        uint256 bonus = bonusBalance / 10;
        uint256 burnValue = bonus;
        balances[address(0x1)] -= (bonus + burnValue);
        if (bonus != 0) {
            burntBalance += burnValue;
            emit EarnedBonus(newAddress, bonus);
        }
        balances[newAddress] = msg.value + bonus;
        ancestry[newAddress] = msg.sender;
        reverseAncestry[msg.sender].push(newAddress);
        emit NewRelation(msg.sender, newAddress);
    }
    
    function pay(address payable to, uint256 value) public payable {
        require(ancestry[msg.sender] != address(0), "Account does not exist");
        uint256 balance = balances[msg.sender];
        uint256 royaltyFee = value;
        require((value + royaltyFee) <= balance, "Insufficient balance to pay royaltyFee");
        address ancestor = ancestry[msg.sender];
        balances[msg.sender] -= value + royaltyFee;
        to.transfer(value);   
        balances[ancestor] += royaltyFee;
        emit RoyaltyPaid(msg.sender, ancestor, royaltyFee);
    }
}
