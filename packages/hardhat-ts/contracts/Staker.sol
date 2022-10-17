pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import 'hardhat/console.sol';
import './ExampleExternalContract.sol';

contract Staker {
  ExampleExternalContract public exampleExternalContract;

  constructor(address exampleExternalContractAddress) public {
    exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  receive() external payable {
    stake();
  }

  mapping(address => uint256) public balances;

  uint256 public constant threshold = 1 ether;

  event Stake(address, uint256);

  uint256 public deadline = block.timestamp + 72 hours;

  bool public openForWithdraw;
  bool public alreadyExecuted;

  modifier notCompleted() {
    bool completed = exampleExternalContract.completed();
    require(!completed, 'already completed');
    _;
  }

  function stake() public payable {
    require(timeLeft() > 0, 'Deadline expired');
    // require(msg.value + balances[msg.sender] <= threshold, 'Test 123');
    balances[msg.sender] += msg.value;
    emit Stake(msg.sender, balances[msg.sender]);
  }

  function execute() public notCompleted {
    require(!alreadyExecuted, 'already executed');
    require(timeLeft() == 0, 'Deadline not expired yet');
    if (address(this).balance > threshold) {
      exampleExternalContract.complete{value: address(this).balance}();
    } else {
      openForWithdraw = true;
    }
    alreadyExecuted = true;
  }

  function timeLeft() public view returns (uint256) {
    if (block.timestamp >= deadline) return 0;
    return deadline - block.timestamp;
  }

  function withdraw() public notCompleted {
    require(openForWithdraw, 'not available');
    require(timeLeft() == 0, 'Deadline not expired yet');
    (bool success, ) = msg.sender.call{value: balances[msg.sender]}('');
    require(success, 'Transfer failed!');
    balances[msg.sender] = 0;
  }

  // TODO: Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )

  // TODO: After some `deadline` allow anyone to call an `execute()` function
  //  It should call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value

  // TODO: if the `threshold` was not met, allow everyone to call a `withdraw()` function

  // TODO: Add a `timeLeft()` view function that returns the time left before the deadline for the frontend

  // TODO: Add the `receive()` special function that receives eth and calls stake()
}
