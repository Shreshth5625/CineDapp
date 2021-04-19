pragma solidity ^0.5.1;

import "./SafeMath.sol";

 contract ERC20Interface {
     // Get the total token supply
     function totalSupply() public returns (uint256 _totalSupply);

     // Get the account balance of another account with address _owner
     function balanceOf(address _owner) public returns (uint256 balance);

     // Send _value amount of tokens to address _to
     function transfer(address _to, uint256 _value) public returns (bool success);

     // Triggered when tokens are transferred.
     event Transfer(address indexed _from, address indexed _to, uint256 _value);


 }

 contract TokenFactory is ERC20Interface {
     
     using SafeMath for uint256;
      string public symbol;
      string public name;
      uint256 public decimals = 18;
      uint256 public TotalSupply;
    

     // Owner of this contract
     address public owner;

     // Balances for each account
     mapping(address => uint256) public balances;

     // Owner of account approves the transfer of an amount to another account
     mapping(address => mapping (address => uint256)) allowed;

     // Functions with this modifier can only be executed by the owner
     modifier onlyOwner() {
         require(msg.sender != owner); 
          _;
      }

      // Constructor
      constructor(string memory _symbol, string memory _name, uint256 _initalSupply) public{// redundant change total supply to budget
          owner = msg.sender;
          balances[msg.sender] = _initalSupply.mul(10 ** decimals);
          symbol = _symbol;
          name = _name;
          TotalSupply = _initalSupply.mul(10 ** decimals);//redundant change to budget/#tokens
      } 

      function totalSupply() public returns (uint256){
         return TotalSupply;
      }

      // What is the balance of a particular account?
      function balanceOf(address _owner) public returns (uint256 balance) {//redundant should have require statement inside
         return balances[_owner];
      }

      // Transfer the balance from owner's account to another account
      function transfer(address _to, uint256 _amount) public returns (bool success) {//redundant not of use
         if (balances[msg.sender] >= _amount
              && _amount > 0) {
              balances[msg.sender] -= _amount;
              balances[_to] += _amount;
              emit Transfer(msg.sender, _to, _amount);
              return true;
          } else {
              return false;
         }
      }

     
}
