# Spawner

![GitHub](https://img.shields.io/github/license/0age/Spawner.svg?colorB=brightgreen)
[![Build Status](https://travis-ci.org/0age/Spawner.svg?branch=master)](https://travis-ci.org/0age/Spawner)
[![standard-readme compliant](https://img.shields.io/badge/standard--readme-OK-green.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

> Spawn EIP 1167 minimal proxies with an included initialization step during contract creation.

These contracts demonstrate a technique for initializing and deploying [EIP 1167](https://eips.ethereum.org/EIPS/eip-1167) minimal proxies that point to designated logic contracts. Logic contracts should make an initialization function available that only allows it to be called during contract construction (i.e. `assembly { if extcodesize(address) { revert(0, 0) } }`).

## Table of Contents

- [Install](#install)
- [Usage](#usage)
- [API](#api)
- [Maintainers](#maintainers)
- [Contribute](#contribute)
- [License](#license)

## Install
To install locally, you'll need Node.js 10+ and Yarn *(or npm)*. To get everything set up:
```sh
$ git clone https://github.com/0age/Spawner.git
$ cd Spawner
$ yarn install
$ yarn build
```

## Usage
Inherit Spawner on a contract and call `_spawn` with the desired logic contract and ABI-encoded initialization calldata:

```
address spawnedContract = _spawn(
  address(logicContract),
  abi.encodeWithSelector(
  	logicContract.initialize.selector,
  	exampleArgumentOne,
  	exampleArgumentTwo
  )
);
```

To run tests locally, start the testRPC, trigger the tests, and tear down the testRPC *(you can do all of this at once via* `yarn all` *if you prefer)*:
```sh
$ yarn start
$ yarn test
$ yarn stop
```

## Maintainers

[@0age](https://github.com/0age)

## Contribute

PRs accepted gladly - make sure the tests pass. *(Changes to the contracts themselves should bump the version number and be marked as pre-release.)*

## License

MIT © 2019 0age
