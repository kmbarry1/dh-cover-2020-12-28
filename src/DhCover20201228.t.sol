pragma solidity ^0.6.7;

import "ds-test/test.sol";

import "./DhCover20201228.sol";

contract DhCover20201228Test is DSTest {
    DhCover20201228 cover;

    function setUp() public {
        cover = new DhCover20201228();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
