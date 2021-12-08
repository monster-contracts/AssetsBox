// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


interface IMonster {
    function getApproved(uint) external view returns (address);
    function ownerOf(uint) external view returns (address);
}


contract MonsterDao {

    IMonster constant mm = IMonster(0x2D2f7462197d4cfEB6491e254a16D3fb2d2030EE);

    // z
    address constant public a = 0x2E62C9F8D794337728ddEfB8fD9b7457A8cde090; 
    // K
    address constant public b = 0x4f18a84affe7d03E6824A076f3c02F726bE16866;
    // H
    address constant public c = 0x9D944Ba1541903e6D7E2e8720620Fc20F3df990c;

    struct Proposal {
        string symbol;
        string description;
        address operator;
        bool arg;
        uint8 approved; 
        uint8 disapproved;
        uint voted;
        uint voteYes;
        uint voteNo;
    }

    Proposal[] public proposals;

    mapping (uint=> mapping (address => bool)) public isOnevoted;

    mapping (uint=> mapping (uint => bool)) public isVoted;

    modifier only_admin() {
        require(msg.sender == a || msg.sender == b || msg.sender == c, "Not admin");
        _;
    }

    modifier not_onevoted(uint _index) {
        require(!isOnevoted[_index][msg.sender], "Had voted");
        _;
    }

    modifier not_voted(uint _index, uint _tokenid) {
        require(!isVoted[_index][_tokenid], "Monster had voted");
        _;
    }

    event Onevoted(address sender, uint index, bool isApproved);
    event Voted(uint tokeid, uint index, bool isApproved);

    function get_proposals_length() external view returns (uint) {
        return proposals.length;
    }

    function create(string memory _symbol, string memory _desc, address _operator, bool _arg) external only_admin{
        proposals.push(Proposal(_symbol, _desc, _operator, _arg, 0, 0, 0, 0, 0));
    }

    function onevote(uint _index, bool _isApproved) external only_admin not_onevoted(_index){
        if(_isApproved){
            proposals[_index].approved += 1;
        } else {
            proposals[_index].disapproved += 1;
        }

        isOnevoted[_index][msg.sender] = true;

        emit Onevoted(msg.sender, _index, _isApproved);
    }

    function vote(uint _index, bool _isApproved, uint _tokenid) external not_voted(_index, _tokenid){
        require(_isApprovedOrOwner(_tokenid), "Only approved or owner");

        if(_isApproved){
            proposals[_index].voteYes += 1;
        } else {
            proposals[_index].voteNo += 1;
        }

        proposals[_index].voted += 1;

        isVoted[_index][_tokenid] = true;

        emit Voted(_tokenid, _index, _isApproved);
    }

    function _isApprovedOrOwner(uint _tokenid) internal view returns (bool) {
        return mm.getApproved(_tokenid) == msg.sender || mm.ownerOf(_tokenid) == msg.sender;
    }

}