pragma solidity >=0.8.0 <0.8.18;

/* 
    In this variant owner gets 10% fee when the lottery is ended.
 */

contract Lottery {
    address payable[] public players;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {
        require(msg.value == 0.1 ether, "Value must be 0.1 ether");
        players.push(payable(msg.sender));
    }

    function getBalance() public view returns (uint) {
        require(msg.sender == owner);
        return address(this).balance;
    }

    function getPlayers() public view returns (address payable[] memory) {
        require(msg.sender == owner);
        return players;
    }

    // Computed using deterministic values
    // Not to be used in production
    function random() internal view returns (uint) {
        return
            uint(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.difficulty,
                        players.length
                    )
                )
            );
    }

    function rewardWinner() public {
        require(msg.sender == owner);
        require(players.length >= 3, "Too few players");

        uint bal = getBalance();
        uint fee = (bal * 10 wei) / 100 wei;

        uint i = random() % players.length;
        address payable winner = players[i];

        winner.transfer(bal - fee);
        payable(owner).transfer(fee);

        // Reset Lottery
        players = new address payable[](0);
    }
}
