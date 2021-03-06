/*
  warning: This is NOT a trustless contract. This contract also haven't been unit tested yet!
           I did this contract as a hobby! The creator of this contract is not responsible for any 
           loss of fund or vulnerability found in the contract. 
           Use at your own risk!
  @author tc216997
  @description: A modified contract from the original u/cintix monetha pooling contract 
                for pooling eth and distributing tokens that was received.
                only the owner address with password can set the saleAddress and tokenAddress.
                only the owner can send out the eth and calling the payout function
                The fees only pays out if the funds have been sent out.
                only pool participants can call refund if the funds haven't been sent out.
                only pool participants call withdraw tokens if the tokens have been deposited.
*/
pragma solidity ^0.4.17;

import "./erc20.sol";
import "./ownable.sol";
import "./safemath.sol";

// pool contract and logic
contract Pool is ERC20, Ownable {  
  using SafeMath for uint;

  // modifier to make sure only withdrawTokens and refunds can be called by pool participants
  modifier onlyParticipants() {
    require(balances[msg.sender] > 0);
    _;
  }  
  
  // key:value pair of address to eth balances
  mapping (address => uint) balances;
  // saleContract and tokenContract are set by the owner
  address saleAddress;
  // tokencontract address to be set by the owner
  ERC20 tokenContract;
  // fee of the contract to be paid to the contract owner
  uint fee;
  // total eth value of the contract that was deposited
  uint totalEth;
  // flags for eth sent out, sale address being set, token address being set and emergency
  bool ethSent = false;
  bool saleAddressSet = false;
  bool tokenSet = false;
  bool emergency = false;

  // a one-time emergency function for a compromised wallet
  // to change to a new owner
  function changeOwnerAddress(address newOwner) public onlyOwner {
    // check if this function has been triggered before
    require(!emergency);
    // flip the emergency flag to true so it can't be triggered again
    emergency = true;
    // assign the new owner address as the contract owner
    owner = newOwner;
  }

  // owner function to set the sale address to send the eth to, only can be called by owner
  function setSaleAddress(address to) public onlyOwner {
    // double check to make sure the owner didn't set the address to burn
    require(to != 0x0);
    // check to see if the contract have been set already
    require(!saleAddressSet);
    // flip the flag
    saleAddressSet = true;    
    // set the saleContract
    saleAddress = to;
  }
  // owner function to set the token contract address
  function setTokenAddress(address token) public onlyOwner {
    // double check to make sure the owner didn't set the address to burn
    require(token != 0x0);
    // can only set the tokenAddress once
    require(!tokenSet);
    // flip the tokenSet flag
    tokenSet = true;    
    // set tokenContract
    tokenContract = ERC20(token);
  }

  // Buy the tokens. Sends ETH to the presale wallet and records the ETH amount held in the contract.
  function sendIt() public onlyOwner {    
    // check to see if the eth have been sent before
    require(!ethSent);
    // check to see if the address has been set
    require(saleAddressSet);
    //Record that the contract has bought the tokens.
    ethSent = true;
    // calculate the fee
    // fee is calculated by balance of contract * numerator / denominator
    fee = fee.mul(this.balance.mul(150)).div(10000);
    // subtract the fee from the contract balance and record it
    totalEth = this.balance.sub(fee);
    // Transfer the eth minus the fee to the set address
    saleAddress.transfer(totalEth);
  }

  // owner function to withdraw the fee
  function withdrawFee() public onlyOwner { 
    // check to see if the funds has been sent
    require(ethSent);
    // check to see if the fee has been paid out
    require(fee > 0);
    // temp variable to store the fee
    uint feeToWithdraw = fee;
    // set fee to 0 to prevent additional calls
    fee = 0;
    // send the fee to the owner
    owner.transfer(feeToWithdraw);
  }

  // pool participants function for refunding people
  function refund() public onlyParticipants {
    // check if the funds hasn't been sent yet
    require(!ethSent);
    // store the refund amount to a temp variable
    uint refundAmount = balances[msg.sender];
    // set the balance of msg.sender to 0 to prevent additional calls
    balances[msg.sender] = 0;
    // send the eth to the function caller
    msg.sender.transfer(refundAmount);
  }

  // pool participants function for withdrawing tokens
  function withdrawTokens() public onlyParticipants {
    uint contractTokenBalance = tokenContract.balanceOf(address(this));
    // check if the funds have been sent
    require(ethSent);
    // check if there is tokens in the contract
    require(contractTokenBalance > 0);
    // check if the token address have been set
    require(tokenSet);
    // calculate the amount of tokens that user can withdraw and set it to temp variable
    // tokens to withdraw is calculated by contractTokenBalance / (totalEth - fee) * balances[msg.sender]
    uint tokensToWithdraw = contractTokenBalance.div(totalEth.sub(fee)).mul(balances[msg.sender]);
    // set the function caller eth balance to 0 before sending to prevent additional calls
    balances[msg.sender] = 0;
    // transfer the token to the function caller
    tokenContract.transfer(msg.sender, tokensToWithdraw);
  }

  // anonymous function that allows the contract to receive ether
  function () external payable {
    // check if the funds hasn't been sent yet
    require(!ethSent);
    // update the balance value whenever someone 
    balances[msg.sender].add(msg.value);
  }
}