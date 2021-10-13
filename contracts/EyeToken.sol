// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EyeToken is ERC721, Ownable {
  constructor(string memory _name, string memory _symbol)
    ERC721(_name, _symbol)
  {}

  uint256 COUNTER;

  uint256 fee = 0.01 ether;

  struct Eye {
    string name;
    uint256 id;
    uint256 dna;
    uint8 level;
    uint8 rarity;
  }

  Eye[] public eyes;

  event NewEye(address indexed owner, uint256 id, uint256 dna);

  // Helpers
  function _createRandomNum(uint256 _mod) internal view returns (uint256) {
    uint256 randomNum = uint256(
      keccak256(abi.encodePacked(block.timestamp, msg.sender))
    );
    return randomNum % _mod;
  }

  function updateFee(uint256 _fee) external onlyOwner() {
    fee = _fee;
  }

  function withdraw() external payable onlyOwner() {
    address payable _owner = payable(owner());
    _owner.transfer(address(this).balance);
  }

  // Creation
  function _createEye(string memory _name) internal {
    uint8 randRarity = uint8(_createRandomNum(100));
    uint256 randDna = _createRandomNum(10**16);
    Eye memory newEye = Eye(_name, COUNTER, randDna, 1, randRarity);
    eyes.push(newEye);
    _safeMint(msg.sender, COUNTER);
    emit NewEye(msg.sender, COUNTER, randDna);
    COUNTER++;
  }

  function createRandomEye(string memory _name) public payable {
    require(msg.value >= fee);
    _createEye(_name);
  }

  // Getters
  function getEyes() public view returns (Eye[] memory) {
    return eyes;
  }

  function getOwnerEyes(address _owner) public view returns (Eye[] memory) {
    Eye[] memory result = new Eye[](balanceOf(_owner));
    uint256 counter = 0;
    for (uint256 i = 0; i < eyes.length; i++) {
      if (ownerOf(i) == _owner) {
        result[counter] = eyes[i];
        counter++;
      }
    }
    return result;
  }

  // Actions
  function levelUp(uint256 _EyeId) public {
    require(ownerOf(_EyeId) == msg.sender);
    Eye storage eye = eyes[_EyeId];
    eye.level++;
  }
}