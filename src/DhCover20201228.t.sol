// SPDX-License-Identifier: None
pragma solidity ^0.7.4;

import "ds-test/test.sol";
import "ds-token/token.sol";

import "./Blacksmith.sol";
import "./COVER.sol";

interface Hevm {
    function warp(uint256) external;
}

contract DhCover20201228Test is DSTest {

    // CHEAT_CODE = 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D
    bytes20 constant CHEAT_CODE =
        bytes20(uint160(uint256(keccak256('hevm cheat code'))));

    Hevm hevm;

    COVER coverToken;
    Blacksmith blacksmith;
    DSToken lpToken;

    function setUp() public {
        hevm = Hevm(address(CHEAT_CODE));

        coverToken = new COVER();
        address governance = address(this);
        address treasury = address(0x1);
        blacksmith = new Blacksmith(address(coverToken), governance, treasury);
        hevm.warp(1605830400);  // 11/20/2020 12am UTC
        coverToken.release(treasury, address(0x2), address(blacksmith), address(0x3));

        lpToken = new DSToken("LPTOKEN");
        blacksmith.addPool(address(lpToken), 100);
    }

    function test_exploit() public {
    }
}
