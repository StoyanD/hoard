pragma solidity ^0.4.13;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/RegisterQueue.sol";

contract TestRegisterQueue {
  /*RegisterQueue queue;

  function beforeAll(){
    queue = RegisterQueue(DeployedAddresses.RegisterQueue());
  }*/

  function testRegisteringUsers(){
    RegisterQueue queue = new RegisterQueue();
    Assert.equal(queue.registerUser(), 1, "first registered user should have position 1");
    /*Assert.equal(queue.registerUser(), 2, "first registered user should have position 1");
    Assert.equal(queue.registerUser(), 3, "first registered user should have position 1");*/
  }

  function testSkipLine(){

  }

  function testUserApproved(){

  }

  function testSendEtherFail(){

  }
}
