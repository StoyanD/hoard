var RegisterQueue = artifacts.require("./RegisterQueue.sol");

contract('RegisterQueue', function(accounts){
  it("should register new users", function(done){
    RegisterQueue.new().then(function(instance){
      instance.registerUser.call({from: accounts[0]}).then(function(pos){
            console.log(pos.valueOf());
            assert.equal(pos.valueOf(), 1, "1 should be the first position");
            instance.registerUser({from: accounts[0]}).then(function(tx_id){
              console.log(tx_id);
              var errMessage = "transaction registerUser failed because user has been registerd already";
              instance.registerUser.call({from: accounts[0]}).then(function(pos){
                console.log(pos.valueOf());
                assert.fail(errMessage);
                done();
              }).catch(function(e){
                //There should be a VM error, but not our assert eeror
                assert.notEqual(e.message, "assert.fail()", errMessage);
                done();
              });
            });
      });
    });
  });//.then(done).catch(done);
});
//     return RegisterQueue.new().then(function(instance){
//     //   qInst = instance;
//     //   return qInst.registerUser.call({from: accounts[0]});
//     // }).then(function(userPos){
//       // console.log(userPos.valueOf());
//       // assert.equal(userPos.valueOf(), 1, "1 should be the first position");
//       instance.registerUser({from: accounts[0]}).then(function(tx_id){
//         // var pos = instance.registerUser.call({from: accounts[0]});
//         // assert.equal(pos.valueOf(), 1, "1 should be the first position");
//         // instance.registerUser({from: accounts[1]}).then(function(tx_id){
//         //     pos = instance.registerUser.call({from: accounts[0]});
//         //     assert.equal(pos.valueOf(), 2, "2 should be the second position");
//         // }).catch(function(e) {
//         //   // assert.fail("transaction failed");
//         //   // There was an error! Handle it.
//         // });
//       // }).catch(function(e) {
//       //   assert.fail("transaction failed registerUser");
//         // There was an error! Handle it.
//       });
//     });
//   // });
// });
