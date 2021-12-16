// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


interface IMultiSignature {
    function is_apporved(uint) external view returns (string memory, uint, address, bool);
}

contract Whitelist {

    mapping(uint => bool) public hasBeenProcessed;

    mapping(address => bool) public isApproved;

    address public immutable ms;
    string public symbol;

    modifier is_approved() {
        require(isApproved[msg.sender], "Not approved");
        _;
    }

    event Whitelisted(string symbol, uint index, address operator, bool arg);

    constructor(address ms_, string memory symbol_) {
       ms = ms_;
       symbol = symbol_;
    }

    function whitelist(uint proposalIndex) external {
        string memory _symbol;
        uint approved = 0;
        address operator = address(0);
        bool arg = false;
        
        (_symbol, approved, operator, arg) = IMultiSignature(ms).is_apporved(proposalIndex);
        
        require(!hasBeenProcessed[proposalIndex], "Proposal has been processed");
        require(keccak256(abi.encodePacked(_symbol)) == keccak256(abi.encodePacked(symbol)));
        require(approved >= 2, "Less than 2");

        isApproved[operator] = arg;
        hasBeenProcessed[proposalIndex] = true;

        emit Whitelisted(_symbol, proposalIndex, operator, arg);
    }
}