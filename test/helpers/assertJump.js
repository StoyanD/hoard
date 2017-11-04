//Assert to check that a VM opcode error was thrown, such as require(), revert()...
module.exports = function(error, message = 'Invalid opcode error must be returned') {
  assert.isAbove(error.message.search('invalid opcode'), -1, message);
}
