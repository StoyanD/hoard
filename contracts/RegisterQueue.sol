pragma solidity ^0.4.13;
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract RegisterQueue is Ownable {
    uint private REFERRAL_BONUS = 5;
    uint private queuePosition = 1;
    uint private allowedInPosition = 0;

    struct Registry {
      uint position;
      string hashedEmail;
      bool set;
    }

    //Queue to store the position of each address
    mapping(address => Registry) private queue;

    //array to store all the addresses that are in the queue
    address[] private queueArray;

    //way to say sorry to the support team when we block previously
    //allowed user from starting
    event BuySupportTeamBeers(uint beerNumber);

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
    function registerUser(string hashedEmail) validAddress(msg.sender) isNotRegistered(msg.sender) returns (uint){
      queue[msg.sender] = Registry(queuePosition, hashedEmail, true);
      queueArray.push(msg.sender);
      return queuePosition++;
    }

    //register new user with a referrer. The referrer has to already be registered,
    //and they get moved up in the queue by REFERRAL_BONUS.
    //NOTE: referrer can hack this and register a bunch of fake addresses to
    //      skip themselves to the front of the queue
    function registerUserWithReferral(string hashedEmail, address referrer) isRegistered(referrer){
      registerUser(hashedEmail);
      moveInQueue(referrer, false);
    }

    //Move any user in the queue to a point where they are allowed
    //access to the app utilizing this contract
    //userAddress has to have already been registered in order to skip them to
    //the front of the line
    function skipLine(address userAddress) onlyOwner{
      moveInQueue(userAddress, true);
    }

    //moves the user in the line by the REFERRAL_BONUS or to the front if
    //toFront is set to true
    function moveInQueue(address userAddress, bool toFront) private validAddress(userAddress) isRegistered(userAddress){
      if(toFront
        || 0 >= int(queue[userAddress].position - REFERRAL_BONUS)){
        queue[userAddress].position = 0;
      }else{
        queue[userAddress].position -= REFERRAL_BONUS;
      }
    }

    //Update the front of the queue, new front has to
    //be greater than the old one
    function updateAllowedInPosition(uint allowIn) onlyOwner{
      //keep support team happy when you do this to them XD
      if(allowIn < allowedInPosition){
          BuySupportTeamBeers(allowedInPosition - allowIn);
      }
      allowedInPosition = allowIn;
    }

    //sets the referral bonus
    function setReferralBonus(uint bonusMoves) onlyOwner{
      REFERRAL_BONUS = bonusMoves;
    }

    //returns the user position in the queue, throws if user is not registered
    function getUserQueuePosition(address userAddress) validAddress(userAddress) isRegistered(userAddress) constant returns (uint){
      return queue[userAddress].position;
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

    //gets the referral bonus that referrers get to skip in line by
    //when one of their referrees registers
    function getReferralBonus() constant returns (uint){
      return REFERRAL_BONUS;
    }
}
