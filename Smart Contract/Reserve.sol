pragma solidity ^0.5.0;

import "./Storage.sol";
import "./Provider.sol";
import"./SpaceOwner.sol";

contract Requester is Storage, SpaceOwner, Provider{

    /* get and set functions for the proxy contract*/
    function getBalance(address who) view public returns (uint) {
        return balances[who];
    }

    function setBalance(address who, uint256 value) public {
        balances[who] = value;
    }

    function getRequest(address who, uint index) view public returns (string memory, string memory, string memory, string memory) {
        return (TheRequestData[index][who].name, TheRequestData[index][who].purpose, TheRequestData[index][who].location, TheRequestData[index][who].spaceName);
    }

    function getRequestDate(address who, uint index) view public returns (uint, uint, uint){
        return (TheRequestData[index][who].date, TheRequestData[index][who].time_begining, TheRequestData[index][who].time_ending);
    }

    function getRequestList(uint index) view public returns(address add){
        return TheRequestList[index];
    }

    function setOwnerList(uint index, address payable add) public{
        TheRequestList[index] = add;
    }


   /* declare variables */
   address owner;
   uint public count_requester;//current number of requester who already registered
   uint count_devicelist;
   uint public difference; // difference between beginning time and ending time
   bool public start; //check the current statue
   bool _override; //override statue
   uint price; //the rental fee from providers to the space owner
   mapping(address=> mapping( uint => uint)) public devicelist;// the devicelist to be easier finding the provider's address

   constructor() public {
        owner = msg.sender;
    }
   event _reserve(uint count, address requestAdd);
   event _devicelist(uint count);



   /* reserve the room*/
   function Reserve(string memory _name, uint _date, uint _time_begining, uint _time_ending
   , string memory _purpose, string memory _location, string memory _room) public payable {

       /* cannot override */
       for( uint i =0; i< count_requester; i++){

           if(keccak256(abi.encodePacked(_location)) == keccak256(abi.encodePacked(TheRequestData[i][TheRequestList[i]].location))){
               if (keccak256(abi.encodePacked(_room)) == keccak256(abi.encodePacked(TheRequestData[i][TheRequestList[i]].spaceName))){
                   for(uint j = 0; j < count_space; j++){
                       if(keccak256(abi.encodePacked(_room)) == keccak256(abi.encodePacked(TheRentalData[j][OwnerList[j]].spaceName))){
                           require(_time_begining >= TheRentalData[j][OwnerList[j]].openTime && _time_ending <= TheRentalData[j][OwnerList[j]].closeTime, "Space is not available for the reserve time");
                       }
                   }

                   if(_date == TheRequestData[i][TheRequestList[i]].date){

                       /*cannot be overrided during this period*/
                       if(((_time_begining > TheRequestData[i][TheRequestList[i]].time_begining) && (_time_begining < TheRequestData[i][TheRequestList[i]].time_ending))||
                       ((_time_ending > TheRequestData[i][TheRequestList[i]].time_begining) && (_time_ending < TheRequestData[i][TheRequestList[i]].time_ending))){
                           _override =true;
                       }
                       else{
                           _override =false;
                       }
                   }
               }

           }
       }

       if(count_requester==0){
           _override=false;
       }


       require(_override != true, "Override");

       /* input the data */
       Requester storage request = TheRequestData[count_requester][msg.sender];

       request.name = _name;
       request.date = _date;
       request.time_begining = _time_begining;
       request.time_ending = _time_ending;
       request.purpose = _purpose;
       request.location = _location;
       request.spaceName = _room;
       request.isRegistered = true;
       request.timestamp = now;

       balances[msg.sender] += msg.value;

       /*Check the location is the same and pay the rental fee to space owner*/
       for (uint i=0; i<OwnerList.length;i++){
           if(keccak256(abi.encodePacked(_location))==keccak256(abi.encodePacked(TheRentalData[i][OwnerList[i]].location))){
               difference = (_time_ending - _time_begining);
               transfer(OwnerList[i], difference * 10 ether); // 10NTD/hour, it is around 0.001397 ether
           }
       }

       TheRequestList.push(msg.sender);
       emit _reserve(count_requester, msg.sender);
       count_requester++;

   }


   /* create device list*/
   function DeviceList(string memory _device) public {

       for (uint i=0;i<count_requester;i++){
           for(uint j=0;j<count_device;j++){
               if((keccak256(abi.encodePacked(TheDeviceData[j][ProviderList[j]].location)) == keccak256(abi.encodePacked(TheRequestData[i][TheRequestList[i]].location))) &&
               (keccak256(abi.encodePacked(TheDeviceData[j][ProviderList[j]].spaceName)) == keccak256(abi.encodePacked(TheRequestData[i][TheRequestList[i]].spaceName))) &&
               keccak256(abi.encodePacked(_device)) == keccak256(abi.encodePacked(TheDeviceData[j][ProviderList[j]].deviceName))){
                   devicelist[msg.sender][count_devicelist] = TheDeviceData[j][ProviderList[j]].deviceID;


               }

           }
       }

       emit _devicelist(count_devicelist);
       count_devicelist++;



   }
   /* control the service time/ start the service time */
   function Switch() external{

       for( uint i=0; i< count_requester;i++){
           if( TheRequestList[i] == msg.sender){
               require( msg.sender == TheRequestList[i], "You cannot open this service");
           }
       }

       if( start == false){
           start = true;
       }
       else{
           start = false;
           price = difference*5 ether; // 一度電五塊，約0.0007ether

           for( uint i=0; i< count_devicelist; i++){

               for(uint j=0;j< count_device;j++){

                   if( devicelist[msg.sender][i] == TheDeviceData[j][ProviderList[j]].deviceID){

                       require( devicelist[msg.sender][i] == TheDeviceData[j][ProviderList[j]].deviceID, "Device ID is not the same");
                       transfer(ProviderList[j], price);

                       for( uint k=0; k< count_space;k++){
                           if( keccak256(abi.encodePacked(TheDeviceData[j][ProviderList[j]].location)) == keccak256(abi.encodePacked(TheRentalData[k][OwnerList[k]].location)) &&
                           keccak256(abi.encodePacked(TheDeviceData[j][ProviderList[j]].spaceName)) == keccak256(abi.encodePacked(TheRentalData[k][OwnerList[k]].spaceName))){

                             transfer(OwnerList[k], price/10);
                           }
                       }
                   }

               }

           }


       }
   }

   /* transfer the ether to account from contract*/
   function transfer(address payable to, uint256 value) public returns (bool result){

       if(balances[msg.sender]>=value){
           to.transfer(value);
           balances[msg.sender] -= value;
           balances[to] += value;
           return true;
       }

   }


   /* only owner can start and end the service time for testing */
   modifier OnlyOwner(){
       require(msg.sender == owner, "Only owner can control the service time");
       _;
   }

}
