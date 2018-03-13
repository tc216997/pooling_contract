/*
  warning: This is NOT a trustless contract. This contract also haven't been unit tested yet!
           I did this contract as a hobby! The creator of this contract is not responsible for any 
           loss of fund or vulnerability found in the contract. 
  @author tc216997
  @description: A contract for pooling eth and distributing tokens that was received.
                only the owner address can set the saleAddress and tokenAddress.
                The fees only pays out if the funds have been sent out.
                Public can call refund if the funds haven't been sent out.
                Public call withdraw tokens if the tokens have been deposited.
*/
pragma solidity ^0.4.17;

// erc20 token contract and overriding 2 function from it
contract ERC20 {
  function balanceOf(address _tokenOwner) public constant returns (uint balance);
  function transfer(address _to, uint _amt) public returns (bool success);
}

// pool contract and logic
contract Pool {  
  // key:value pair of address to eth balances
  mapping (address => uint) balances;
  // wallet address that can calls special owner function
  // this is the test wallet address from truffle ganache using the default mnemonic
  address owner = 0x627306090abaB3A6e1400e9345bC60c78a8BEf57;
  // saleContract and tokenContract are set by the owner
  address saleContract;
  // tokencontract address to be set by the owner
  ERC20 tokenContract;
  // fee of the contract to be paid to the contract owner
  uint fee;
  // total eth value of the contract that was deposited
  uint totalEth;
  // flags for eth sent out, sale address being set, and token address being set
  bool ethSent = false;
  bool saleContractSet = false;
  bool tokenSet = false;

  // modifier to make sure only certain functions can be called by owner only
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  // owner function to set the sale address to send the eth to, only can be called by owner
  function setSaleAddress(address to) external onlyOwner {
    // double check to make sure the owner didn't set the address to burn
    require(to != 0x0);
    // check to see if the contract have been set already
    require(!saleContractSet);
    // flip the flag
    saleContractSet = true;    
    // set the saleContract
    saleContract = to;
  }
  function setTokenAddress(address token) external onlyOwner {
    // double check to make sure the owner didn't set the address to burn
    require(token != 0x0);
    // can only set the tokenAddress once
    require(!tokenSet);
    // flip the tokenSet flag
    tokenSet = true;    
    // set tokenContract
    tokenContract = ERC20(token);
  }

  // owner specific function to send the eth to the address
  function sendEth() external onlyOwner {
    // check to see if the address have been set
    require(saleContractSet);    
    // check to see if the address isn't a burn address and have been set
    require(saleContract != 0x0);
    //calculate the contract fee which is 1.5%
    fee = totalEth * 150;
    // flip the ethSent flag
    ethSent = true;
    // send the eth minus the contract fee
    saleContract.transfer(totalEth - fee);
  }
  // owner function to withdraw the fee
  function payTheDev() external onlyOwner {
    // check to see if the funds has been sent
    require(ethSent);
    saleContract.transfer(fee);
  }

  // public function for refunding people
  function refund() external {
    // check if the funds hasn't been sent yet
    require(!ethSent);
    // check if msg.sender actually sent eth before
    require(balances[msg.sender] > 0);
    // store the refund amount to a temp variable
    uint refundAmount = balances[msg.sender];
    // set the balance of msg.sender to 0 to prevent a recursive call
    balances[msg.sender] = 0;
    msg.sender.transfer(refundAmount);
  }

  // public function for withdrawing tokens
  function withdrawTokens() external {
    uint contractTokenBalance = tokenContract.balanceOf(address(this));
    // check if the funds have been sent
    require(ethSent);
    // check if the function caller actually has tokens
    require(balances[msg.sender] > 0);
    // check if there is tokens in the contract
    require(contractTokenBalance > 0);
    // check if the token address have been set
    require(tokenSet);
    // calculate the amount of tokens that user can withdraw and set it to temp variable
    uint tokensToWithdraw = contractTokenBalance / (totalEth - fee) * balances[msg.sender];
    // set the function caller eth balance to 0 before sending to prevent recursive call
    balances[msg.sender] = 0;
    // transfer the token to the function caller
    tokenContract.transfer(msg.sender, tokensToWithdraw);
  }

  // anonymous function that allows the contract to receive ether
  function () external payable {
    // check if the funds hasn't been sent yet
    require(!ethSent);
    // update the balance value whenever someone 
    balances[msg.sender] += msg.value;
    // update the contract total eth value
    totalEth += msg.value;
  }
}