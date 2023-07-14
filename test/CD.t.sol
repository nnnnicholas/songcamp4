// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/CD.sol";

contract EmptyTest_Unit is Test {
    address deployer = address(420);
    address minter = address(69);

    function setUp() public {
        vm.deal(deployer, 1000 ether);
        vm.deal(minter, 1000 ether);
    }

    // Setup
    // uint256 constant FORK_BLOCK_NUMBER = 17149178; // All tests executed at this block
    // string RPC_MAINNET = "RPC_MAINNET";
    // uint256 forkId = vm.createSelectFork(vm.envString(RPC_MAINNET), FORK_BLOCK_NUMBER);
    CD cd = new CD(0);

    function testMint() public {
        cd.mint{value: 0.01 ether}(1);
    }

    function testBurnSongs() public {
        testMint();
        cd.burnSongs(1, cd.packValues(1, 2, 3, 4));
    }

    function testOutputMint() public {
        testMint();
        string memory returnedUri = cd.tokenURI(1);

        // The following lines open the SVG in your default SVG reader. This part of the code depends upon `ffi`. Note: `ffi` is not safe in repos where untrusted parties can mutate the code (incl PRs). If a malicious party introduces code and the dev runs it using `ffi`, it is executed by node and has full disk access. In sum: if you're working on a shared codebase that others can push to, or are running tests on a PR by an untrusted party, consider removing the `ffi` code below.
        string[] memory inputs = new string[](3);
        inputs[0] = "node";
        inputs[1] = "./open.js";
        inputs[2] = returnedUri;
        // bytes memory res = vm.ffi(inputs); // Complains that res is not used
        vm.ffi(inputs);
    }

    function testOutputBurned() public {
        testBurnSongs();
        string memory returnedUri = cd.tokenURI(1);

        // The following lines open the SVG in your default SVG reader. This part of the code depends upon `ffi`. Note: `ffi` is not safe in repos where untrusted parties can mutate the code (incl PRs). If a malicious party introduces code and the dev runs it using `ffi`, it is executed by node and has full disk access. In sum: if you're working on a shared codebase that others can push to, or are running tests on a PR by an untrusted party, consider removing the `ffi` code below.
        string[] memory inputs = new string[](3);
        inputs[0] = "node";
        inputs[1] = "./open.js";
        inputs[2] = returnedUri;
        // bytes memory res = vm.ffi(inputs); // Complains that res is not used
        vm.ffi(inputs);
    }
}
