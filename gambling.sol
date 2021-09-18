pragma solidity 0.6.6;

import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

contract gambling is VRFConsumerBase  {
    uint  public  maxPlayer;
    address[] public player;
    mapping(address=>uint)playerAddress;
    uint public minimumContribution;
    address public owner;
    address public winner;
    
    bytes32 internal keyHash;
    uint256 internal fee;
    
    uint256 public randomResult;

    constructor(uint  _contribution, uint _maxPlayer ) VRFConsumerBase(
            0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9, // VRF Coordinator
            0xa36085F69e2889c224210F603D836748e7dC0088  // LINK Token
        ) public {
            keyHash = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
        fee = 0.1 * 10 ** 18; // 0.1 LINK (Varies by network)

            
       owner = msg.sender;
       minimumContribution = _contribution;
       maxPlayer = _maxPlayer;
    }
    
    function getRandomNumber() private returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee);
    }
    
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = randomness.mod(maxPlayer).add(1);
    }
    
    modifier checkAmount(uint amount){
        require(minimumContribution <= amount);
        _;
    }
    
    modifier checkNumberOfPlayer(){
        require(maxPlayer > player.length);
        _;
    }
    
    modifier isContributed(address _address) {
        require(playerAddress[_address] > 0);
        _;
    }
    
    modifier isOwner(address _address) {
        require(owner != msg.sender);
        _;
    }
    
    function contribut(uint _amount) public  isOwner(msg.sender) checkAmount(_amount){
        player.push(msg.sender);
        playerAddress[msg.sender] = _amount;
    }
    
    function refund() payable public isContributed(msg.sender) checkNumberOfPlayer {
        // playerAddress[msg.sender]
        uint a = playerAddress[msg.sender] - 1;
        msg.sender.transfer(a);
        playerAddress[msg.sender] = 0;
    }
    
    function yourContribution() public view returns(uint) {
        return playerAddress[msg.sender];
    }
    
    function pickWiner() payable public {
        require(maxPlayer == player.length);
        getRandomNumber();
        winner = player[randomResult];
    }
    
    
} 