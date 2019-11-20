pragma solidity ^ 0.5.0;

import "./SafeMath.sol";

contract Storage{

    using SafeMath for uint256;

    /* proxy contract variable*/
    address public implementation;
    address public owner;

    /*this concept jsut like easy card */
    mapping (address =>uint256) public balances;

    /* Room inforamtion*/
    struct Rental{

        string location;
        string spaceName;
        string ownerName;
        string spaceType;
        uint openTime;
        uint closeTime;
        bool isRegistered;
        uint timestamp;
        }

    mapping( uint => mapping(address=>Rental)) public TheRentalData;

    /* Device information */
    struct Device{

        string deviceName;
        uint deviceID;
        string companyName;
        string location;
        string spaceName;
        string providerName;
        uint timestamp;
        uint NumberofPeople;
        bool status; //turn on or off
        //bool received;
    }
    mapping( uint=> mapping (address => Device)) public TheDeviceData;

    /* Requester's information */

    struct Requester{

        string name;
        uint date;
        uint time_begining;
        uint time_ending;
        string purpose;
        string location;
        string spaceName;
        bool isRegistered;
        uint timestamp;

    }

    mapping(uint => mapping(address => Requester)) public TheRequestData;

    address payable [] public ProviderList;
    //mapping(address => mapping(uint => address payable)) public DeviceId; //store user's device list
    address payable [] OwnerList;
    address payable [] public TheRequestList;


}
