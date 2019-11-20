pragma solidity ^0.5.0;

import "./Storage.sol";
import "./SafeMath.sol";

contract Room is Storage {

  using SafeMath for uint256;

  uint count;
  uint256 tempValue;
  uint256 oneEther = 1 ether;

  function computeFee(uint _id, uint _timestamp) public returns (uint256) {
    tempValue = roomData[_id].price.mul(oneEther) * _timestamp;
    return tempValue;
  }

  function register(string memory _name, uint _price) public {
    roomData[count].roomID = count;
    roomData[count].roomName = _name;
    roomData[count].price = _price;
    roomData[count].realOwner = msg.sender;
    roomData[count].status = false;
    roomData[count].currOwner = address(0);
    roomData[count].prevOwner = address(0);
    roomData[count].startTime = 0;
    roomData[count].timestamp = 0;
    roomData[count].endTime = 0;
    count++;
  }

  function getIndex() public view returns (uint) {
    return count;
  }

  //only can return 7 variables
  function getAddress(uint _id) public view returns (uint, string memory, address, address, address, bool) {
    return (roomData[_id].roomID,
            roomData[_id].roomName,
            roomData[_id].realOwner,
            roomData[_id].currOwner,
            roomData[_id].prevOwner,
            roomData[_id].status);
  }

  function checkAvailable(uint _id) public view returns(uint){
    if(roomData[_id].realOwner == msg.sender){
      return 0;
    }else if(roomData[_id].currOwner == address(0)){
      return 1;
    }else{
      return 2;
    }
  }

  function getTime(uint _id) public view returns (uint, uint, uint, bool){
    return (roomData[_id].startTime,
            roomData[_id].timestamp,
            roomData[_id].endTime,
            roomData[_id].status);
  }

  function rental(uint _id, uint _start, uint _timestamp, uint _end) public payable{
    require(msg.value == computeFee(_id, _timestamp), "Insufficient money");
    roomData[_id].currOwner = msg.sender;
    // roomData[_id].status = true;
    roomData[_id].startTime = _start;
    roomData[_id].timestamp = _timestamp;
    roomData[_id].endTime = _end;
    roomData[_id].realOwner.transfer(msg.value);
  }

  function startRent(uint _id) public{
    roomData[_id].status = true;
  }

  function restore(uint _id) public{
    roomData[_id].currOwner = address(0);
    roomData[_id].prevOwner = msg.sender;
    roomData[_id].status = false;
    roomData[_id].startTime = 0;
    roomData[_id].timestamp = 0;
    roomData[_id].endTime = 0;
  }
}
