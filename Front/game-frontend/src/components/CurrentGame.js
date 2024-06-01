import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { Card, CardContent, Typography } from '@mui/material';
import GameBoard from './GameBoard';
import Confetti from 'react-confetti';
import useWindowSize from 'react-use/lib/useWindowSize';
import './CurrentGame.css';

function CurrentGame() {
  const [currentGame, setCurrentGame] = useState(null);
  const { width, height } = useWindowSize();

  useEffect(() => {
    const fetchCurrentGame = () => {
      axios.get('http://localhost:8080/api/game/current-game')
        .then(response => {
          setCurrentGame(response.data);
        })
        .catch(error => {
          console.error('There was an error fetching the current game!', error);
        });
    };

    fetchCurrentGame();
    const intervalId = setInterval(fetchCurrentGame, 500);

    return () => clearInterval(intervalId);
  }, []);

  const getWinningCombination = (game) => {
    const lines = [
      [[0, 0], [0, 1], [0, 2]],
      [[1, 0], [1, 1], [1, 2]],
      [[2, 0], [2, 1], [2, 2]],
      [[0, 0], [1, 0], [2, 0]],
      [[0, 1], [1, 1], [2, 1]],
      [[0, 2], [1, 2], [2, 2]],
      [[0, 0], [1, 1], [2, 2]],
      [[0, 2], [1, 1], [2, 0]]
    ];

    for (let line of lines) {
      const [[a, b], [c, d], [e, f]] = line;
      if (game[`row${a}`][b] === game[`row${c}`][d] && game[`row${a}`][b] === game[`row${e}`][f] && game[`row${a}`][b] !== '-') {
        return line;
      }
    }

    return null;
  };

  const winningCombination = currentGame ? getWinningCombination(currentGame) : null;

  return (
    <Card style={{padding:'20px'}}>
      <CardContent>
        {currentGame ? (
          <div>
            <Typography variant="h6">Current Game {currentGame.plays && <span style={{ float: 'right' }}>Plays: {currentGame.plays}</span>}</Typography>
            <GameBoard 
              row0={currentGame.row0} 
              row1={currentGame.row1} 
              row2={currentGame.row2} 
              winningCombination={winningCombination} 
            />
            <div style={{ marginTop: '10px' }}>
              <Typography variant="body1" style={{ marginBottom: '5px' }}>
                <strong>Mode:</strong> {currentGame.mode}
              </Typography>
              <Typography variant="body1" style={{ marginBottom: '5px' }} className={currentGame.lsign === "X" ? "sign-x" : "sign-o"}>
                <strong>Player1 Sign:</strong> {currentGame.lsign}
              </Typography>
              <Typography variant="body1" style={{ marginBottom: '5px' }} className={currentGame.rsign === "O" ? "sign-o" : "sign-x"}>
                {
                  currentGame.mode === "Player" ? <><strong>Player2 Sign:</strong> {currentGame.rsign}</> :
                  currentGame.mode === "Bot" ? <><strong>Bot Sign:</strong> {currentGame.rsign}</> : 
                  <><strong>Blue2 Sign:</strong> {currentGame.rsign}</>
                }
              </Typography>
              <Typography variant="body1" style={{ marginBottom: '5px' }}>
                <strong>Game Date:</strong> {currentGame.gameDate}
              </Typography>
              {currentGame.winner && currentGame.winner !== "None" && (
                <>
                  {currentGame.winner !== "Draw" && <Confetti width={width} height={height} />}
                  <Typography variant="h4" color="secondary" className='winner-message'>
                    <strong>Winner:</strong> {currentGame.winner}
                  </Typography>
                </>
              )}
            </div>
          </div>
        ) : (
          <Typography textAlign={'center'}>No current game.</Typography>
        )}
      </CardContent>
    </Card>
  );
}

export default CurrentGame;
