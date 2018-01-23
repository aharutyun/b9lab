pragma solidity ^0.4.4;

contract RockPaperScissors {
    struct Game {
        uint depositAmount;
        address player1;
        uint8 player1Done;
        bytes32 player1ChoiceHash;
        address player2;
        uint8 player2Done;
        bytes32 player2ChoiceHash;

    }

    enum Choice {None, Rock, Paper, Scissors }


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

    //player choose rock, scissors, paper, hash it with secret and pass to function
    function playerMove(bytes32 _choiceHashWithSecret, string _gameName) external payable {
        require(games[_gameName].depositAmount != 0);
        require(msg.value == games[_gameName].depositAmount);
        if (msg.sender == games[_gameName].player1) {
            // already made a choice before
            require(games[_gameName].player1Done == 0);

            games[_gameName].player1ChoiceHash = _choiceHashWithSecret;
            games[_gameName].player1Done = 1;
        } else if (msg.sender == games[_gameName].player2) {
             // already made a choice before
            require(games[_gameName].player2Done == 0);

            games[_gameName].player2ChoiceHash = _choiceHashWithSecret;
            games[_gameName].player2Done = 1;
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
        require(games[_gameName].player1Done == 1 && games[_gameName].player2Done == 1);

        //get choice names from hash
        Choice player1Choice = getChoiceFromHash(games[_gameName].player1ChoiceHash, _player1Secret);
        Choice player2Choice = getChoiceFromHash(games[_gameName].player2ChoiceHash, _player2Secret);

        address winnerAddress;
        //if players chose other that rock, paper, scissors`
        if (player1Choice == Choice.None && player2Choice != Choice.None) {
            winnerAddress = games[_gameName].player2;
            return;
        }
        if (player2Choice == Choice.None && player1Choice != Choice.None) {
            winnerAddress = games[_gameName].player1;
        }

        // play criteria
        if (player1Choice == Choice.Rock) {
            if (player2Choice == Choice.Scissors) {
                winnerAddress = games[_gameName].player1;
            } else if (player2Choice == Choice.Paper) {
                winnerAddress = games[_gameName].player2;
            }
        } else if (player1Choice == Choice.Scissors) {
            if (player2Choice == Choice.Paper) {
                winnerAddress = games[_gameName].player1;
            } else if (player2Choice == Choice.Rock) {
                winnerAddress = games[_gameName].player2;
            }
        } else if (player1Choice == Choice.Paper) {
            if (player2Choice == Choice.Rock) {
                winnerAddress = games[_gameName].player1;
            } else if (player2Choice == Choice.Scissors) {
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

    function calculateKeccak(uint choice, string _secret) public constant returns (bytes32 hash) {
        return keccak256(choice, _secret);
    }

    function getChoiceFromHash(bytes32 _hash, string _secret) private constant returns (Choice choice) {
        if (_hash == keccak256(uint(Choice.Rock), _secret)) {
            return Choice.Rock;
        } else if (_hash == keccak256(uint(Choice.Paper), _secret)) {
            return Choice.Paper;
        } else if (_hash == keccak256(uint(Choice.Scissors), _secret)) {
            return Choice.Scissors;
        }
        return Choice.None;
    }

}