pragma solidity ^0.8.0;

import "./ExampleLogicContract.sol";
import "../Spawner.sol";


contract SpawnerTester is Spawner {
  constructor() public {
    // deploy the example logic contract.
    ExampleLogicContract logic = new ExampleLogicContract();

    // set test values for the constructor args.
    address testValue = address(0x0101010101010101010101010101010101010101);
    string memory testString = "this is a test string.";
    bytes32 testStringHash = keccak256(bytes(testString));

    // find an address ahead of time.
    address precomputeSpawnedContract = _computeNextAddress(
      address(logic),
      abi.encodeWithSelector(logic.initialize.selector, testValue, testString)
    );

    // spawn a contract, providing logic contract address and initializer data.
    address spawnedContract = _spawn(
      address(logic),
      abi.encodeWithSelector(logic.initialize.selector, testValue, testString)
    );

    require(precomputeSpawnedContract == spawnedContract, "precompute failed.");

    ExampleLogicContract implementation = ExampleLogicContract(spawnedContract);

    // call it and check that it was correctly set up.
    require(implementation.hasBeenInitialized(), "not initialized correctly");
    require(implementation.testValue() == testValue, "incorrect test value");
    require(
      keccak256(bytes(implementation.testString())) == testStringHash,
      "incorrect test string"
    );

    // ensure that the contract cannot be initialized again.
    (bool ok, ) = spawnedContract.call(
      abi.encodeWithSelector(logic.initialize.selector, address(0), testString)
    );
    require(!ok, "does not prevent re-initialization correctly");

    // find the next address ahead of time.
    precomputeSpawnedContract = _computeNextAddress(
      address(logic),
      abi.encodeWithSelector(logic.initialize.selector, testValue, testString)
    );

    // spawn a new contract with the same logic contract and initializer data.
    spawnedContract = _spawn(
      address(logic),
      abi.encodeWithSelector(logic.initialize.selector, testValue, testString)
    );

    require(precomputeSpawnedContract == spawnedContract, "precompute failed.");

    ExampleLogicContract implTwo = ExampleLogicContract(spawnedContract);

    // call it and check that it was correctly set up.
    require(implTwo.hasBeenInitialized(), "not initialized correctly");
    require(implTwo.testValue() == testValue, "incorrect test value");
    require(
      keccak256(bytes(implTwo.testString())) == testStringHash,
      "incorrect test string"
    );

    // ensure that the contract cannot be initialized again.
    (ok, ) = spawnedContract.call(
      abi.encodeWithSelector(logic.initialize.selector, address(0), testString)
    );
    require(!ok, "does not prevent re-initialization correctly");
  }
}
