pragma solidity ^0.5.0;

import "./Storage.sol";

contract SpaceOwner is Storage {



    function getBalance(address who, uint index) view public returns (string memory, string memory, string memory, string memory) {
        return (TheRentalData[index][who].location, TheRentalData[index][who].ownerName, TheRentalData[index][who].spaceName, TheRentalData[index][who].spaceType);
    }

    function getOwnerList(uint index) view public returns(address add){
        return OwnerList[index];
    }

    function setOwnerList(uint index, address payable add) public{
        OwnerList[index] = add;
    }

    uint public count_space;

    function getIndex() view public returns (uint){
        return count_space;
    }

    event register(uint count_space, address OwnerAddr);

    function RegisterSpace(string memory _location, string memory  _spacename, string memory _ownername, string memory _spaceType, uint _openTime, uint _closeTime) payable public returns(bool result){

        for (uint i =0; i< count_space; i++){
            require(keccak256(abi.encodePacked(_location)) != keccak256(abi.encodePacked(TheRentalData[i][OwnerList[i]].location)),"This space is registered already");
        }

        Rental storage rental = TheRentalData[count_space][msg.sender];
        rental.location = _location;
        rental.spaceName = _spacename;
        rental.ownerName = _ownername;
        rental.spaceType = _spaceType;
        rental.openTime = _openTime;
        rental.closeTime = _closeTime;
        rental.isRegistered = true;
        rental.timestamp = now;
        balances[msg.sender]+=msg.value;


        //require: the location cannot be the same
        OwnerList.push(msg.sender);
        emit register(count_space, msg.sender);

        count_space++;
        return(true);
    }
}
