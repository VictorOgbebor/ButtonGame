// SPDX-License-Identifier: Mine
pragma solidity 0.8.10;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

error MUST_DEPOSIT_ENTRY_FEE(); 
error GAME_IS_CLOSED();
error NO_NEED_FOR_UPKEEP();

contract ButtongameV2 {
    uint256 private immutable _entryFee;

    enum GameState {
        Open,
        Closed
    }

    GameState public _gameState;

    address payable[] public _addressOfPlayers;
    address public lastAddress;
    uint256 public _interval;
    uint256 public _lastTimestamp;
    VRFCoordinatorV2Interface public immutable _vrf;
    bytes32 public _gasLane;

    event ButtonHit(address indexed player);

    constructor(uint256 entry, uint256 interval, address vrf, bytes32 gasLane) {
        _entryFee = entry;
        _interval = interval;
        _lastTimestamp = block.timestamp;
        _vrf = VRFCoordinatorV2Interface(vrf);
        _gasLane = gasLane;

    }

    function PressButton() external payable {
        // save on gas
        if (msg.value != _entryFee) {
            revert MUST_DEPOSIT_ENTRY_FEE();
        }

        // open Calculating a Winner
        if (_gameState != GameState.Open) {
            revert GAME_IS_CLOSED();
        }
        // Allowed to enter!
        _addressOfPlayers.push(payable(msg.sender));
         emit ButtonHit(msg.sender);
    }

    // We want a random winner => But we dont 
    // We want it dont automaticlly

    // Chainlink Keeper => Check contract to Will Trigger to finD winner
        /**
        1. Be true after some time interval
        2. how long to keep game going
        3. the contract has ETH
        4. Keepers has LINK
         */
        function checkUpkeep(bytes memory /* checkData */) public view returns(bool upkeepNeeded, bytes memory /* performData */) {
            uint current = block.timestamp;
            bool Open = GameState.Open == _gameState;
            bool timePassed = ((current - _lastTimestamp) > _interval);
            bool hasBalance = address(this).balance > 0;
            bool hasPlayers = _addressOfPlayers.length > 0;
            upkeepNeeded = (timePassed && Open && hasBalance && hasPlayers);
            return (upkeepNeeded, "0x0");

        }

        function performUpkeep(bytes calldata /* performData */) external  {
            (bool upkeepNeed, ) = checkUpkeep('');

            if (!upkeepNeed) {
                revert NO_NEED_FOR_UPKEEP();
            }

            _gameState = GameState.Closed;

            // we want it to not be the random winner, but in this we will
        }
}

