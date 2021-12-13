// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./Whitelist.sol";

interface IAssetBox {
    function totalSupply() external view returns (uint);
    function getTotalSupplyOfRole(uint8 roleIndex) external view returns (uint);
    function getbalance(uint8 roleIndex, uint tokenID) external view returns (uint);
    function mint(uint8 roleIndex, uint tokenID, uint amount) external;
    function setRole(uint8 index, address role) external;
    function getRole(uint8 index) external view returns (address);
    function transfer(uint8 roleIndex, uint from, uint to, uint amount) external;
    function burn(uint8 roleIndex, uint tokenID, uint amount) external;
}


contract AssetBox is Whitelist, IAssetBox {

    string public name;
    uint8 public constant decimals = 0;

    mapping(uint8 => address) private roles;

    uint public totalSupply;

    mapping(uint8 => uint) private totalSupplyOfRole;

    mapping(uint8 => mapping(uint => uint)) private balance;

    event Transfer(uint8 roleIndex, uint indexed from, uint indexed to, uint amount);
    event Burn(uint8 roleIndex, uint indexed from, uint amount);

    constructor (address ms_, bytes32 symbol_, string memory name_) Whitelist(ms_, symbol_) {
        name = name_;
    }

    function getTotalSupplyOfRole(uint8 roleIndex) external view returns (uint){
        return totalSupplyOfRole[roleIndex];
    }

    function getbalance(uint8 roleIndex, uint tokenID) external view returns (uint){
        return balance[roleIndex][tokenID];
    }

    function mint(uint8 roleIndex, uint tokenID, uint amount) external is_approved {
        totalSupply += amount;
        totalSupplyOfRole[roleIndex] += amount;
        balance[roleIndex][tokenID] += amount;

        emit Transfer(roleIndex, tokenID, tokenID, amount);
    }

    function getRole(uint8 index) external view returns (address) {
        return roles[index];
    }

    function setRole(uint8 index, address role) external is_approved{
        roles[index] = role;
    }

    function transfer(uint8 roleIndex, uint from, uint to, uint amount) external is_approved{
        balance[roleIndex][from] -= amount;
        balance[roleIndex][to] += amount;

        emit Transfer(roleIndex, from, to, amount);
    }

    function burn(uint8 roleIndex, uint tokenID, uint amount) external is_approved {
        totalSupply -= amount;
        totalSupplyOfRole[roleIndex] -= amount;
        balance[roleIndex][tokenID] -= amount;

        emit Burn(roleIndex, tokenID, amount);
    }

}