pragma solidity ^0.5.0;

contract Storage {

  struct Room{
        uint roomID;
        string roomName;
        uint price;
        address payable realOwner;
        bool status; //turn on or off
        address currOwner;
        address prevOwner;
        uint startTime;
        uint timestamp;
        uint endTime;
    }
    mapping( uint => Room) public roomData;
}
