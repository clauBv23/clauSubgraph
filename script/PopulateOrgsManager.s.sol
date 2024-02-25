// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console2, console} from "forge-std/Script.sol";
import {OrgsManager} from "../src/OrgsManager.sol";

contract PopulateOrgsManager is Script {
    OrgsManager manager;

    uint256 alliance1Number = 1;
    uint256 alliance2Number = 2;

    uint256 alice = vm.envUint("PRIVATE_KEY1");
    uint256 bob = vm.envUint("PRIVATE_KEY2");
    uint256 charlie = vm.envUint("PRIVATE_KEY3");

    uint256 aliceId = 1;
    uint256 bobId = 2;
    uint256 charlieId = 3;

    uint256 aliceOrgId = 10;
    uint256 bobOrgId = 20;
    uint256 charlieOrgId = 30;

    function run(address _managerAddr) public {
        manager = OrgsManager(_managerAddr);

        // create Alice, Bob, and Charlie members and their organizations
        _createMembersAndOrgs();

        // join members to organizations
        _joinMembersToOrgs();

        // set voting power to members
        _setMembersVotingPower();

        // create alliances and join organizations
        _createAllianceAndJoinOrganizations();

        // define delegator to members
        _defineDelegatorToMember();
    }

    function _createMembersAndOrgs() internal {
        vm.startBroadcast(alice);
        manager.createMember(bytes32(aliceId), "Alice");
        manager.createOrganization(bytes32(aliceOrgId), "Alice's Org");
        vm.stopBroadcast();

        vm.startBroadcast(bob);
        manager.createMember(bytes32(bobId), "Bob");
        manager.createOrganization(bytes32(bobOrgId), "Bob's Org");
        vm.stopBroadcast();

        vm.startBroadcast(charlie);
        manager.createMember(bytes32(charlieId), "Charlie");
        manager.createOrganization(bytes32(charlieOrgId), "Charlie's Org");
        vm.stopBroadcast();
    }

    function _joinMembersToOrgs() internal {
        // join Alice to Charlie and Bob's orgs
        vm.startBroadcast(alice);
        manager.joinOrganization(bytes32(bobOrgId), bytes32(aliceId));
        manager.joinOrganization(bytes32(charlieOrgId), bytes32(aliceId));
        vm.stopBroadcast();

        // join Bob to Alice and Charlie's orgs
        vm.startBroadcast(bob);
        manager.joinOrganization(bytes32(aliceOrgId), bytes32(bobId));
        manager.joinOrganization(bytes32(charlieOrgId), bytes32(bobId));
        vm.stopBroadcast();

        // join Charlie to Alice and Bob's orgs
        vm.startBroadcast(charlie);
        manager.joinOrganization(bytes32(aliceOrgId), bytes32(charlieId));
        manager.joinOrganization(bytes32(bobOrgId), bytes32(charlieId));
        vm.stopBroadcast();
    }

    function _setMembersVotingPower() internal {
        // set voting power to Bob, and Charlie in Alice's org
        vm.startBroadcast(alice);
        manager.setVotingPowerToMember(
            bytes32(aliceOrgId),
            bytes32(bobId),
            200
        );
        manager.setVotingPowerToMember(
            bytes32(aliceOrgId),
            bytes32(charlieId),
            300
        );
        vm.stopBroadcast();

        // set voting power to Alice, and Charlie in Bob's org
        vm.startBroadcast(bob);
        manager.setVotingPowerToMember(
            bytes32(bobOrgId),
            bytes32(aliceId),
            100
        );
        manager.setVotingPowerToMember(
            bytes32(bobOrgId),
            bytes32(charlieId),
            300
        );
        vm.stopBroadcast();

        // set voting power to Alice, and Bob in Charlie's org
        //!!!!!!! it is wrong in the original script
        vm.startBroadcast(bob);
        manager.setVotingPowerToMember(
            bytes32(charlieOrgId),
            bytes32(aliceId),
            100
        );
        manager.setVotingPowerToMember(
            bytes32(charlieOrgId),
            bytes32(bobId),
            200
        );
        vm.stopBroadcast();
    }

    function _createAllianceAndJoinOrganizations() internal {
        // set voting power to Bob, and Charlie in Alice's org
        vm.startBroadcast();
        manager.createAlliance(alliance1Number);
        manager.createAlliance(alliance2Number);
        vm.stopBroadcast();

        // join alice's and bob's org to alliance1
        vm.startBroadcast(alice);
        manager.joinAlliance(alliance1Number, bytes32(aliceOrgId));
        vm.stopBroadcast();

        // set voting power to Alice, and Charlie in Bob's org
        vm.startBroadcast(bob);
        manager.joinAlliance(alliance1Number, bytes32(bobOrgId));
        vm.stopBroadcast();

        // join charlie's org to alliance2
        vm.startBroadcast(charlie);
        manager.joinAlliance(alliance2Number, bytes32(charlieOrgId));
        vm.stopBroadcast();
    }

    function _defineDelegatorToMember() internal {
        // define the script address as alice bob and charlie's delegator
        vm.startBroadcast(alice);
        manager.addMemberDelegator(bytes32(aliceId), address(this));
        vm.stopBroadcast();

        vm.startBroadcast(bob);
        manager.addMemberDelegator(bytes32(bobId), address(this));

        vm.stopBroadcast();

        vm.startBroadcast(charlie);
        manager.addMemberDelegator(bytes32(charlieId), address(this));
        vm.stopBroadcast();
    }

    /**
     *  1- Alice
     *  2- Bob
     *  3- Charlie
     *
     *  10- Alice's Org
     *  20- Bob's Org
     *  30- Charlie's Org
     */
    function memberLeaveOrg(uint256 _memberNo, uint256 _orgNo) external {
        vm.startBroadcast();
        manager.leaveOrganization(bytes32(_orgNo), bytes32(_memberNo));
        vm.stopBroadcast();
    }

    function orgLeaveAlliance(uint256 _allianceNo, uint256 _orgNo) external {
        vm.startBroadcast();
        manager.leaveAlliance(_allianceNo, bytes32(_orgNo));
        vm.stopBroadcast();
    }
}
