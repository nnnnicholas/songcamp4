// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "src/CD.sol";

contract DeployScript is Script {

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("GOERLI_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        CD cd = new CD(0, "ipfs://QmSYZdipjfLJyg7kLj9ffKLfx3jLG6LA2vzHHjvjdSRMCh");
        vm.stopBroadcast();
    }
}
