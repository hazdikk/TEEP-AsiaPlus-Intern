pragma solidity ^ 0.5.0;

import "./Storage.sol";
import "./SpaceOwner.sol";

contract Provider is Storage, SpaceOwner{

    function getDevice(address who, uint index) public view returns(string memory, string memory, string memory, string memory, string memory) {
        return (TheDeviceData[index][who].deviceName,
                TheDeviceData[index][who].companyName,
                TheDeviceData[index][who].location,
                TheDeviceData[index][who].spaceName,
                TheDeviceData[index][who].providerName);
    }

    function getDeviceID(address who, uint index) public view returns(uint, uint){
        return (TheDeviceData[index][who].deviceID,
                TheDeviceData[index][who].NumberofPeople);
    }

    function getProviderList(uint index) public view returns(address add){
        return ProviderList[index];
    }

    function setProviderList(uint index, address payable add) public{
        ProviderList[index] = add;
    }

    bool success;
    uint public count_device;

    event register(string device_name, uint id, string company_name, string location, string space_name, string provider_name);

    /* Install the device */
    function RegisterDevice(string memory _devicename,
                            uint _id,
                            string memory _companyname,
                            string memory _location,
                            string memory _spacename,
                            string memory _providername,
                            uint _numofpeople) public payable{
                                
        for (uint i = 0; i < count_device ; i++){
            require(_id != TheDeviceData[i][ProviderList[i]].deviceID, " This device already registered");
        }

        Device storage device = TheDeviceData[count_device][msg.sender];

        device.deviceName = _devicename;
        device.deviceID = _id;
        device.companyName = _companyname;
        device.location = _location;
        device.spaceName = _spacename;
        device.providerName = _providername;
        device.NumberofPeople = _numofpeople;
        device.status = false;
        device.timestamp = now;
        balances[msg.sender] += msg.value;

        ProviderList.push(msg.sender);

        count_device++;

        emit register(_devicename, _id, _companyname, _location, _spacename, _providername);

    }

}
