pragma solidity ^0.4.17;

// erc20 token contract and overriding 2 function from it
contract ERC20 {
  function balanceOf(address _tokenOwner) public constant returns (uint balance);
  function transfer(address _to, uint _amt) public returns (bool success);
}