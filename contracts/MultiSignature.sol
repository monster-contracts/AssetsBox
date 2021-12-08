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
        bytes32 symbol;
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

    modifier not_voted(uint _index) {
        require(!isVoted[_index][msg.sender], "Had voted");
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

    function create(bytes32 _symbol, string memory _desc, address _operator, bool _arg) external only_admin{
        proposals.push(Proposal(_symbol, _desc, _operator, _arg, 0, 0));
    }

    function vote(uint _index, bool _isApproved) external only_admin not_voted(_index){
        if(_isApproved){
            proposals[_index].approved += 1;
        } else {
            proposals[_index].disapproved += 1;
        }

        isVoted[_index][msg.sender] = true;

        emit Voted(msg.sender, _index, _isApproved);
    }

    function is_apporved(uint _index) view external returns(bytes32 _symbol, uint _approved, address _operator, bool _arg){
        Proposal memory prp = proposals[_index];
        _symbol = prp.symbol;
        _approved = prp.approved;
        _operator = prp.operator;
        _arg = prp.arg;
    }

}