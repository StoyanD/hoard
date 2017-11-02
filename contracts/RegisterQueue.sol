pragma solidity ^0.4.17;
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract RegisterQueue is Ownable {
    int public queueFront = 0;

    //Don't send money to this contract
    function(){
      revert();
    }

    //Register user into the queue at the end of the line, return the
    //position of the user once inserted
    function registerUser(address referrerAddress) returns (int){
      return 1;
    }

    //Move any user in the queue to a point where they are allowed
    //access to the app utilizing this contract
    function skipLine(address userAddress) onlyOwner returns (int){
      return 1;
    }

    function getQueueFront() view returns (int){
      return queueFront;
    }
}
