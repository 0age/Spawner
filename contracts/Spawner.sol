pragma solidity 0.5.10;


/**
 * @title Spawn
 * @notice This contract provides creation code that is used by Spawner in order
 * to initialize and deploy eip-1167 minimal proxies for a given logic contract.
 */
contract Spawn {
  constructor(
    address logicContract,
    bytes memory initializationCalldata
  ) public payable {
    // delegatecall into the logic contract to perform initialization.
    (bool ok, ) = logicContract.delegatecall(initializationCalldata);
    if (!ok) {
      // pass along failure message from delegatecall and revert.
      assembly {
        returndatacopy(0, 0, returndatasize)
        revert(0, returndatasize)
      }
    }

    // place eip-1167 runtime code in memory.
    bytes memory runtimeCode = abi.encodePacked(
      bytes10(0x363d3d373d3d3d363d73),
      logicContract,
      bytes15(0x5af43d82803e903d91602b57fd5bf3)
    );

    // return eip-1167 code to write it to spawned contract runtime.
    assembly {
      return(add(0x20, runtimeCode), 45) // eip-1167 runtime code, length
    }
  }
}


/**
 * @title Spawner
 * @notice This contract spawns and initializes an eip-1167 minimal proxy that
 * points to an existing logic contract. The logic contract needs to have an
 * intitializer function that should only callable when no contract exists at
 * its current address (i.e. it is being delegatecalled from a constructor).
 */
contract Spawner {
  function _spawn(
    address logicContract,
    bytes memory initializationCalldata
  ) internal returns (address spawnedContract) {
    // example create2 salt derivation - tweak to taste: nonce, extcodehash, etc
    bytes32 salt = keccak256(
      abi.encodePacked(
        msg.sender,
        logicContract,
        initializationCalldata
      )
    );

    // place creation code and constructor args of contract to spawn in memory.
    bytes memory initCode = abi.encodePacked(
      type(Spawn).creationCode,
      abi.encode(logicContract, initializationCalldata)
    );

    assembly {
      let encoded_data := add(0x20, initCode) // load initialization code.
      let encoded_size := mload(initCode)     // load the init code's length.
      spawnedContract := create2(             // call CREATE2 with 4 arguments.
        callvalue,                            // forward any supplied endowment.
        encoded_data,                         // pass in initialization code.
        encoded_size,                         // pass in init code's length.
        salt                                  // pass in the salt value.
      )

      // pass along failure message from failed contract deployment and revert.
      if iszero(spawnedContract) {
        returndatacopy(0, 0, returndatasize)
        revert(0, returndatasize)
      }
    }
  }
}