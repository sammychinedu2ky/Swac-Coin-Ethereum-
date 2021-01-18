// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function transfer(address _to, uint256 _value)
        external
        returns (bool success);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);

    function approve(address _spender, uint256 _value)
        external
        returns (bool success);

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256 remaining);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Swac is ERC20 {
    string public name = "SWAC COIN";
    string public symbol = "SWC";
    uint256 public decimals = 18;
    uint256 public override totalSupply;
    uint256 ethToSwac = 10;
    address payable contractOwner;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    constructor(uint256 initialAmount) {
        totalSupply = initialAmount;
        balances[msg.sender] = initialAmount;
        contractOwner = payable(msg.sender);
    }

    function balanceOf(address _owner) public view override returns (uint256) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value)
        public
        override
        returns (bool)
    {
        if (_value > balances[msg.sender]) return false;
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public override returns (bool) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value) {
            balances[_from] -= _value;
            balances[_to] += _value;
            allowed[_from][msg.sender] -= _value;
            emit Transfer(_from, _to, _value);
            return true;
        }
        return false;
    }


    function approve(address _spender, uint256 _value)
        public
        override
        returns (bool)
    {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender)
        public
        view
        override
        returns (uint256)
    {
        return allowed[_owner][_spender];
    }

    receive() external payable {
        uint256 token = msg.value * ethToSwac;
        if (balances[contractOwner] < token) {
            payable(msg.sender).transfer(msg.value);
            return;
        }
        balances[msg.sender] += token;
        balances[contractOwner] -= token;
        contractOwner.transfer(msg.value);
        emit Transfer(msg.sender, contractOwner, token);
    }
}
