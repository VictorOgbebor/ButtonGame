// SPDX-License-Identifier: BlockchainBic

pragma solidity 0.8.10;

contract ControlRoom {

address public owner;

modifier ForOwners  {

require(owner == msg.sender, "Not Permitted");

_;

}

constructor() {

owner = msg.sender;

}

}

contract Timer {

uint start;

uint end;

modifier TimerDone {

require(block.timestamp <= end, "timer over");

_;

}

function setTimerStart() public {

start = block.timestamp ;

}

function TimerGoing() public {

end = 60 seconds + start;

}

function getTime() public TimerDone view returns(uint){

return end - block.timestamp;

}

}

contract ButtonGame is ControlRoom, Timer {

uint currentTime = block.timestamp;

address[] public allAddress;

address public lastAddress;

modifier winnerOnly() {

// require msg.sender should match the the address that is called in lastAddress()

require(lastAddress == msg.sender, "You are not the last");

_;

}

function PressButton() external payable {

require(msg.value == 1 ether, "has to be 1 ether to deposit"); // require msg.value = 1 ether

allAddress.push(msg.sender); // add to list

lastAddress = allAddress[allAddress.length - 1];

TimerGoing(); // call StartTime() to restart timer

}

function getLastAddress() public view returns (address) {

return lastAddress;

}

// Check Reward Balance = this will be the ether deposted into contract

function CheckReward() public view returns (uint) {

return address(this).balance;

}

function ClaimTreasure() external TimerDone { // only the winner or admin can call this

require(lastAddress == msg.sender, "NOPE");

address payable winner = payable(lastAddress);

winner.transfer(address(this).balance);

}


}