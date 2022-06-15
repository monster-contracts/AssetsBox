// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IERC20 {
    function mint(address to, uint256 amount) external returns (bool);
}

contract TokenProxy{
    // z
    address immutable public a; 
    // K
    address immutable public b;
    // H
    address immutable public c;

    address public immutable token;
    address public operator;

    uint public totalSupply;
    uint public limit;
    uint public tmp;

    mapping (uint => uint8) voted;
    uint index;
    mapping (uint => mapping(address => bool)) public isVoted;

    constructor (address token_, address a_, address b_, address c_) {
        token = token_;
        a = a_;
        b = b_;
        c = c_;
    }

    modifier only_admin() {
        require(msg.sender == a || msg.sender == b || msg.sender == c, "Not admin");
        _;
    }

    modifier not_voted() {
        require(!isVoted[index][msg.sender], "Had voted");
        _;
    }

    function initOperator(address _operator) external only_admin{
        require(operator == address(0), "has been inited");
        operator = _operator;
    }

    function vote(uint tmp_) external only_admin not_voted{
        require(tmp == tmp_);
        require(limit != tmp);
        isVoted[index][msg.sender] = true;
        voted[index] += 1;

        if (voted[index] >= 2) {
            limit = tmp;
        }
    }

    function proposal(uint limit_) external only_admin{
        tmp = limit_;

        index += 1;
        voted[index] = 0;

        isVoted[index][msg.sender] = true;
    }

    function mint(address to, uint amount) external {
        require(operator == msg.sender, "Has not been authorized");
        require(totalSupply + amount <= limit, "Exceed limit");

        IERC20(token).mint(to, amount);
    }

}