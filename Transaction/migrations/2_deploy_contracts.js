var Room = artifacts.require("./Room.sol");
var Storage = artifacts.require("./Storage.sol");
var SafeMath = artifacts.require("./SafeMath.sol");

module.exports = function(deployer) {
  deployer.deploy(Storage);
  deployer.link(Storage, Room);
  deployer.deploy(SafeMath);
  deployer.link(SafeMath, Room);
  deployer.deploy(Room);
};
