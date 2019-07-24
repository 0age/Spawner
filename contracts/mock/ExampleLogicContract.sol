pragma solidity 0.5.10;


contract ExampleLogicContract {
  bool public hasBeenInitialized;
  address public testValue;
  string public testString;
  
  function initialize(
    address initialTestValue,
    string calldata initialTestString
  ) external {
    // only allow this function to be called from within a constructor.
    assembly { if extcodesize(address) { revert(0, 0) } }

    // perform initialization.
    hasBeenInitialized = true;
    testValue = initialTestValue;
    testString = initialTestString;
  }
}