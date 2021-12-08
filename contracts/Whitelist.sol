// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


interface IMultiSignature {
    function is_apporved(uint) external view returns (bytes32, uint, address, bool);
}

contract Whitelist {

    mapping(uint => bool) public hasBeenProcessed;

    mapping(address => bool) public isApproved;

    address public immutable ms;
    bytes32 public immutable symbol;

    modifier is_approved() {
        require(isApproved[msg.sender], "Not approved");
        _;
    }

    event Whitelisted(bytes32 symbol, uint index, address operator, bool arg);

    constructor(address ms_, bytes32 symbol_) {
       ms = ms_;
       symbol = symbol_;
    }

    function whitelist(uint proposalIndex) external {
        bytes32 _symbol;
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