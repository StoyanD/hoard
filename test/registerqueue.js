var RegisterQueue = artifacts.require("./RegisterQueue.sol");
const assertJump = require('./helpers/assertJump');

contract('RegisterQueue', function(accounts){
  var instance;

  beforeEach(async function() {
    instance = await RegisterQueue.new();
  });

  it("should register new users", async function(){
    let pos = await instance.registerUser.call({from: accounts[0]});
    assert.equal(pos.valueOf(), 1, "1 should be the first position");
    let tx_id = await instance.registerUser({from: accounts[0]});
    var erMessage = "transaction registerUser should fail because user has been registerd already";
    try {
      //should fail to register the same user more than once
      let regCall = await instance.registerUser.call({from: accounts[0]});
      assert.fail(erMessage);
    }catch(error){
      assertJump(error, erMessage);
    }
  });

  it("should return the queue position", async function(){
    let pos = await instance.getQueuePosition.call();
    assert.equal(pos.valueOf(), 1, "initial queue position should be 1");
    let tx_id = await instance.registerUser({from: accounts[0]});
    pos = await instance.getQueuePosition.call();
    assert.equal(pos.valueOf(), 2, "next queue position should be 2");
    try{
      await instance.registerUser({from: accounts[0]});
      assert.fail('should have thrown before');
    }catch(error){
      assertJump(error);
    }
    pos = await instance.getQueuePosition.call();
    assert.equal(pos.valueOf(), 2, "failure to re-register the same user should not move the queue position");
  });

  it("should allow owner to skip the line for registered users", async function(){
    await instance.registerUser({from: accounts[0]});
    try{
      await instance.skipLine(accounts[0], {from:accounts[1]});
      assert.fail('should have thrown before');
    }catch(error){
      assertJump(error, "Only the owner of the contract should be able to skip users");
    }

    let allowed = await instance.isUserApproved(accounts[0]);
    assert.equal(allowed.valueOf(), false, "first user should not be skipped by non-owner call");
    //do the valid owner call of skip
    await instance.skipLine(accounts[0], {from:accounts[0]});
    allowed = await instance.isUserApproved(accounts[0]);
    assert.equal(allowed.valueOf(), true, "first user should allowed to skip now");
  });

  it("should require valid addresses to skip the line", async function(){
    await instance.registerUser({from: accounts[0]});
    let allowed = await instance.isUserApproved(accounts[0]);
    assert.equal(allowed.valueOf(), false, "first user should not be allowed to skip yet");
    try{
      await instance.skipLine(accounts[1]);
      assert.fail('should have thrown before');
    }catch(error){
      assertJump(error, "This user has not been registered yet, so should throw");
    }

    await instance.registerUser({from: accounts[1]});
    await instance.skipLine(accounts[0]);
    allowed = await instance.isUserApproved(accounts[0]);
    assert.equal(allowed.valueOf(), true, "first user should allowed to skip now");
    allowed = await instance.isUserApproved(accounts[1]);
    assert.equal(allowed.valueOf(), false, "second user should not be skipped when we skip the first user");
    await instance.skipLine(accounts[1]);
    allowed = await instance.isUserApproved(accounts[1]);
    assert.equal(allowed.valueOf(), true, "second user should be skipped now");
  });

  it("should update the position of allowed users from the queue", async function(){
    await instance.registerUser({from: accounts[0]});
    await instance.registerUser({from: accounts[1]});
    await instance.registerUser({from: accounts[2]});
    try{
      await instance.updateAllowedInPosition(1, {from: accounts[1]});
      assert.fail('should have thrown before');
    }catch(error){
      assertJump(error, "Only the owner should be able to call this function");
    }

    //Allow the first two users in
    await instance.updateAllowedInPosition(2);
    let allowed = await instance.isUserApproved(accounts[0]);
    assert.equal(allowed.valueOf(), true, "should be allowed in");
    allowed = await instance.isUserApproved(accounts[1]);
    assert.equal(allowed.valueOf(), true, "should be allowed in");
    allowed = await instance.isUserApproved(accounts[2]);
    assert.equal(allowed.valueOf(), false, "should not be allowed in");

    //Dont allow the allowedInPosition to go backwards
    try{
      await instance.updateAllowedInPosition(1);
      assert.fail('should have thrown before');
    }catch(error){
      assertJump(error, "Should not be able to move the allowedInPosition backwards");
    }

  });

});//end contract tests
