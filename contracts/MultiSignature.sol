// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


contract MultiSignature {
    // z
    address immutable public a; 
    // K
    address immutable public b;
    // H
    address immutable public c;

    struct Proposal {
        string symbol;
        string description;
        address operator;
        bool arg;
        uint8 approved; 
        uint8 disapproved;
    }

    Proposal[] public proposals;

    mapping (uint=> mapping (address => bool)) public isVoted;

    modifier only_admin() {
        require(msg.sender == a || msg.sender == b || msg.sender == c, "Not admin");
        _;
    }

    modifier not_voted(uint index) {
        require(!isVoted[index][msg.sender], "Had voted");
        _;
    }

    event Voted(address sender, uint index, bool isApproved);

    constructor(address a_, address b_, address c_) {
        a = a_;
        b = b_;
        c = c_;
    }

    function get_proposals_length() external view returns (uint) {
        return proposals.length;
    }

    function create(string memory symbol, string memory desc, address operator, bool arg) external only_admin{
        proposals.push(Proposal(symbol, desc, operator, arg, 0, 0));
    }

    function vote(uint index, bool isApproved) external only_admin not_voted(index){
        if(isApproved){
            proposals[index].approved += 1;
        } else {
            proposals[index].disapproved += 1;
        }

        isVoted[index][msg.sender] = true;

        emit Voted(msg.sender, index, isApproved);
    }

    function is_apporved(uint _index) view external returns(string memory symbol, uint approved, address operator, bool arg){
        Proposal memory prp = proposals[_index];
        symbol = prp.symbol;
        approved = prp.approved;
        operator = prp.operator;
        arg = prp.arg;
    }

}