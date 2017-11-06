pragma solidity ^0.4.13;
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract RegisterQueue is Ownable {
    uint queuePosition = 1;
    uint allowedInPosition = 0;

    struct Registry {
      uint position;
      bool set;
    }

    //Queue to store the position of each address
    mapping(address => Registry) queue;

    //array to store all the addresses that are in the queue
    address[] queueArray;

    //check that the user has been registered in the queue
    modifier isRegistered(address userAddress) {
      require(queue[userAddress].set);
      _;
    }

    modifier isNotRegistered(address userAddress) {
      require(!queue[userAddress].set);
      _;
    }

    modifier validAddress(address userAddress){
      require(userAddress != address(0));
      _;
    }

    function RegisterQueue(){

    }

    //Don't send money to this contract
    function() payable public {
      revert();
    }

    //Register user into the queue at the end of the line, return the
    //position of the user once inserted
    function registerUser() isNotRegistered(msg.sender) returns (uint){
      queue[msg.sender] = Registry(queuePosition, true);
      queueArray.push(msg.sender);
      return queuePosition++;
    }

    //Move any user in the queue to a point where they are allowed
    //access to the app utilizing this contract
    //userAddress has to have already been registered in order to skip them to
    //the front of the line
    function skipLine(address userAddress) validAddress(userAddress) isRegistered(userAddress) onlyOwner{
      queue[userAddress].position = 0;
    }

    //Update the front of the queue, new front has to
    //be greater than the old one
    function updateAllowedInPosition(uint allowIn) onlyOwner{
      require(allowIn >= allowedInPosition);//dont disable already enabled users
      allowedInPosition = allowIn;
    }

    //checks if the user is allowed to participate, their position should
    //be less to or equal to allowedInPosition
    function isUserApproved(address userAddress) isRegistered(userAddress) constant returns (bool){
      return queue[userAddress].position <= allowedInPosition;
    }

    //gets the current front of the queue
    function getQueuePosition() constant returns (uint){
      return queuePosition;
    }
}
