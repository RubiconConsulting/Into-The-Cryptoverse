// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interface/AggregatorV3Interface.sol";
import {IVRFCoordinatorV2Plus} from "chainlink/src/v0.8/vrf/dev/interfaces/IVRFCoordinatorV2Plus.sol";
import {VRFConsumerBaseV2Plus} from "chainlink/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "chainlink/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

contract Rubbicon is VRFConsumerBaseV2Plus {
    IERC20 public crytoverseToken;

    uint32 liveLineDeduction =10;
    uint32 failQuestionORtrapBlock = 3;
    uint32 winQuestion = 5;
    uint32 asGameBegins = 20;

    IVRFCoordinatorV2Plus COORDINATOR;

    // Your subscription ID.
    uint256 s_subscriptionId;

    // past requests Id.
    uint256[] public requestIds;
    uint256 public lastRequestId;

    bytes32 keyHash =
        0x816bedba8a50b294e5cbd47842baf240c2385f2eaf719edbd4f250a137a8c899;

    uint32 callbackGasLimit = 100000;

    uint16 requestConfirmations = 3;

    uint32 numWords = 1;


    enum CharacterType {
        CypherPunk,
        Whale,
        Trader,
        Investor,
        Satoshi,
        Degen
    }

    struct Character {
        string name;
        string strengths;
        string weaknesses;
        string tactics;
    }

    /// if any of these is done reduce the users tokens by 100 GTK
    enum liveLines {
        AskRubiconAI, // if players asks AI question reduce tokens
        CompetitorHelp // if players ask Competitor reduce tokens
    }

    enum blocks {
        passAquestion, // this is for both the flash block and question block
        failAquestion, // this is for both the flash block and question block
        trap //Trap block only tokens are deducted
    }

    mapping(CharacterType => Character) public characters;
    mapping(address => uint256) public playerTokens;
    mapping(uint256 => RequestStatus) public s_requests;


    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);

    event TokensDeducted(address indexed player, uint256 amount, blocks eventType);
    event TokensAwarded(address indexed player, uint256 amount, blocks eventType);
    event liveLineUsed(address indexed player, uint256 amount, liveLines eventType);

    struct RequestStatus {
        bool fulfilled;
        bool exists;
        uint256[] randomWords;
    }

    modifier hasEnoughTokens(address user, uint256 amount) {
        require(playerTokens[user] >= amount, "Not enough tokens");
        _;
    }

    // polygon COORDINATOR 0x343300b5d84D444B2ADc9116FEF1bED02BE49Cf2
    constructor(
        uint256 subscriptionId,
        address _tokenAddress
    ) VRFConsumerBaseV2Plus(0x343300b5d84D444B2ADc9116FEF1bED02BE49Cf2) {
        COORDINATOR = IVRFCoordinatorV2Plus(
            0x343300b5d84D444B2ADc9116FEF1bED02BE49Cf2
        );
        s_subscriptionId = subscriptionId;
        crytoverseToken = IERC20(_tokenAddress);
    }


    function rollDice() external returns (uint256 requestId) {
        requestId = requestRandomWords();
    }

    function beginGame() external{
        playerTokens[msg.sender] += asGameBegins;
    }

    function EndGame() external{
        uint256 balance = playerTokens[msg.sender] * 1e18;
        crytoverseToken.transfer(msg.sender,balance);

    }

    // Function to handle different LiveLine events
    function triggerLiveLineEvent(liveLines eventType) external {
        if (eventType == liveLines.AskRubiconAI || eventType == liveLines.CompetitorHelp ) {
            deductTokens(liveLineDeduction);
            emit liveLineUsed(msg.sender, liveLineDeduction, eventType);
        }
    }

    // Function to handle different Block events
    function triggerBlockEvent(blocks eventType)  external {
        if (eventType == blocks.failAquestion|| eventType == blocks.trap ) {
            deductTokens(failQuestionORtrapBlock);
            emit TokensDeducted(msg.sender, failQuestionORtrapBlock, eventType);
        }else{
            awardTokens(winQuestion);
            emit TokensAwarded(msg.sender, winQuestion, eventType);
        }
    }
    
    function getRequestStatus(
        uint256 _requestId
    ) external view returns (bool fulfilled, uint256[] memory randomWords) {
        require(s_requests[_requestId].exists, "request not found");
        RequestStatus memory request = s_requests[_requestId];
        return (request.fulfilled, request.randomWords);
    }

    /// Balance used during the game. The total amount of tokens a player have in wallet will determine 
    function getBalance(address user) external view returns (uint256) {
        return playerTokens[user];
    }


    ////////////////***********************HELPERS *********************//////////////////////
    
    // Function to handle token deduction
    function deductTokens(uint256 amount) internal hasEnoughTokens(msg.sender, amount) {
        playerTokens[msg.sender] -= amount;
    }
    
    // Function to handle token awarding
    function awardTokens(uint256 amount) internal {
        playerTokens[msg.sender] += amount;
    }

    /////////////////////VRF//////////////////////////////
    function requestRandomWords() internal returns (uint256 requestId) {
        requestId = COORDINATOR.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: keyHash,
                subId: s_subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: numWords,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: true})
                )
            })
        );
        s_requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);
        return requestId;
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] calldata _randomWords
    ) internal override {
        require(s_requests[_requestId].exists, "request not found");
        
        // Create a new array to store the adjusted random words
        uint256[] memory adjustedRandomWords = new uint256[](_randomWords.length);
        
        // Adjust each random word to be between 1 and 6
        for (uint256 i = 0; i < _randomWords.length; i++) {
            adjustedRandomWords[i] = (_randomWords[i] % 6) + 1;
        }
        
        // Mark the request as fulfilled
        s_requests[_requestId].fulfilled = true;
        
        // Store the adjusted random words
        s_requests[_requestId].randomWords = adjustedRandomWords;
        
        // Emit an event to signal the request has been fulfilled
        emit RequestFulfilled(_requestId, adjustedRandomWords);
    }

    /////////////////////VRF//////////////////////////////

    // Other game logic functions...
    //Its only the tokens you earn during the game u can use now
}


// forge create --rpc-url <your_rpc_url> \
// --constructor-args "ForgeUSD" "FUSD" 18 1000000000000000000000 \
// --private-key <your_private_key> \
// --etherscan-api-key <your_etherscan_api_key> \
// --verify \
// src/MyToken.sol:MyToken


