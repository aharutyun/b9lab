pragma solidity ^0.4.4;

contract RockPaperScissors {
    struct Game {
        uint depositAmount;
        address player1;
        bool player1Done;
        bytes32 player1ChoiceHash;
        address player2;
        bool player2Done;
        bytes32 player2ChoiceHash;

    }


    mapping(string => Game) games;

    event LogWinnerAddress(string _gameName, address _winnerAddress, uint _depositAmount);

    function RockPaperScissors() public {

    }

    //create new game with 2 players
    function newGame(string _gameName, address _secondPlayer, uint _depositAmount) external {
        //depositAmount cannot be 0
        require(_depositAmount != 0);
        //start game with the name, it must be unique
        require(games[_gameName].depositAmount == 0);

        //register gamers
        games[_gameName].depositAmount = _depositAmount;
        games[_gameName].player1 = msg.sender;
        games[_gameName].player2 = _secondPlayer;
    }

    //player choose rock, scissors, paper, and secret to hash, hide its choice
    function playerMove(string _choice, string _secret, string _gameName) external payable {
        require(games[_gameName].depositAmount != 0);
        require(msg.value == games[_gameName].depositAmount);
        if (msg.sender == games[_gameName].player1) {
            // already made a choice before
            require(!games[_gameName].player1Done);

            //hash move with secret key, in order to not store in contract
            games[_gameName].player1ChoiceHash = keccak256(_choice, _secret);
            games[_gameName].player1Done = true;
        } else if (msg.sender == games[_gameName].player2) {
             // already made a choice before
            require(!games[_gameName].player2Done);

            //hash move with secret key, in order to not store in contract
            games[_gameName].player2ChoiceHash = keccak256(_choice, _secret);
            games[_gameName].player2Done = true;
        } else {
            revert();
        }
    }

    //the decission
    function play(string _gameName, string _player1Secret, string _player2Secret) external payable {
        //players provide their secrets, in order to check moves
        //game must be exists
        require(games[_gameName].depositAmount != 0);

        //must be called by one of the players
        require(msg.sender == games[_gameName].player1 || msg.sender == games[_gameName].player2);

        //both players moves must be done
        require(games[_gameName].player1Done && games[_gameName].player2Done);

        //get choice names from hash
        bytes32 player1Choice = getChoiceFromHash(games[_gameName].player1ChoiceHash, _player1Secret);
        bytes32 player2Choice = getChoiceFromHash(games[_gameName].player2ChoiceHash, _player2Secret);

        address winnerAddress;
        //if players chose other that rock, paper, scissors`
        if (player1Choice == bytes32("") && player2Choice != bytes32("")) {
            winnerAddress = games[_gameName].player2;
            return;
        }
        if (player2Choice == "" && player1Choice != "") {
            winnerAddress = games[_gameName].player1;
        }

        // play criteria
        if (player1Choice == bytes32("rock")) {
            if (player2Choice == bytes32("scissors")) {
                winnerAddress = games[_gameName].player1;
            } else if (player2Choice == bytes32("paper")) {
                winnerAddress = games[_gameName].player2;
            }
        } else if (player1Choice == bytes32("scissors")) {
            if (player2Choice == bytes32("paper")) {
                winnerAddress = games[_gameName].player1;
            } else if (player2Choice == bytes32("rock")) {
                winnerAddress = games[_gameName].player2;
            }
        } else if (player1Choice == bytes32("paper")) {
            if (player2Choice == bytes32("rock")) {
                winnerAddress = games[_gameName].player1;
            } else if (player2Choice == bytes32("scissors")) {
                winnerAddress =  games[_gameName].player2;
            }
        }

        //if it is not draw, send the deposit amount to winner
        if (winnerAddress != 0) {
            winnerAddress.transfer(games[_gameName].depositAmount * 2);
        }

        LogWinnerAddress(_gameName, winnerAddress, games[_gameName].depositAmount);
        // clean up
        delete games[_gameName];

    }

    function getChoiceFromHash(bytes32 _hash, string _secret) private constant returns (bytes32) {
        if (_hash == keccak256("rock", _secret)) {
            return bytes32("rock");
        } else if (_hash == keccak256("paper", _secret)) {
            return bytes32("paper");
        } else if (_hash == keccak256("scissors", _secret)) {
            return bytes32("scissors");
        }
        return bytes32("");
    }

}