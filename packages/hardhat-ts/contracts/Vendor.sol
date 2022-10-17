pragma solidity >=0.8.0 <0.9.0;
// SPDX-License-Identifier: MIT

import '@openzeppelin/contracts/access/Ownable.sol';
import './YourToken.sol';

contract Vendor is Ownable {
  YourToken public yourToken;

  constructor(address tokenAddress) public {
    yourToken = YourToken(tokenAddress);
  }

  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
  event SellTokens(address sender, uint256 amountOfTokens, address recipient);

  uint256 public constant tokensPerEth = 100;

  // ToDo: create a payable buyTokens() function:
  function buyTokens() public payable {
    uint256 amount = msg.value * tokensPerEth;
    require(yourToken.balanceOf(address(this)) >= amount);
    bool ok = yourToken.transfer(msg.sender, amount);
    require(ok, 'transfer failed');
    emit BuyTokens(msg.sender, msg.value, amount);
  }

  // ToDo: create a withdraw() function that lets the owner withdraw ETH
  function withdraw() external onlyOwner {
    uint256 totalBalance = address(this).balance;
    require(totalBalance > 0, 'vendor broke');
    (bool success, ) = msg.sender.call{value: totalBalance}('');
    require(success, 'withdraw failed');
  }

  // ToDo: create a sellTokens() function:
  function sellTokens(uint256 value) public {
    uint256 amount = value / tokensPerEth;
    address sender = msg.sender;
    bool ok = yourToken.transferFrom(sender, address(this), value);
    require(ok, 'sell failed');
    (bool success, ) = sender.call{value: amount}('');
    require(success, 'retrieve eth failed');
    emit SellTokens(sender, amount, address(this));
  }
}
