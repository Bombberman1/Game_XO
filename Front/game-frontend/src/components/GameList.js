import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { Card, CardContent, Typography } from '@mui/material';
import GameBoard from './GameBoard';
import './GameList.css';

function GameList() {
  const [games, setGames] = useState([]);

  useEffect(() => {
    axios.get('http://localhost:8080/api/game')
      .then(response => {
        setGames(response.data.reverse());
      })
      .catch(error => {
        console.error('There was an error fetching the games!', error);
      });
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

  return (
    <div className="game-list">
      {games.map((game, index) => (
        <div key={index} style={{ marginBottom: '20px' }}>
          <Card className="game-card">
            <CardContent>
              <Typography variant="h6">Game {games.length - index}</Typography>
              <GameBoard row0={game.row0} row1={game.row1} row2={game.row2} winningCombination={getWinningCombination(game)} />
              <div style={{ marginTop: '10px' }}>
                <Typography variant="body1" style={{ marginBottom: '5px' }}>
                  <strong>Mode:</strong> {game.mode}
                </Typography>
                <Typography variant="body1" style={{ marginBottom: '5px' }} className={game.lsign === "X" ? "sign-x" : "sign-o"}>
                  <strong>Player1 Sign:</strong> {game.lsign}
                </Typography>
                <Typography variant="body1" style={{ marginBottom: '5px' }} className={game.rsign === "O" ? "sign-o" : "sign-x"}>
                  {
                  game.mode === "Player" ? <><strong>Player2 Sign:</strong> {game.rsign}</> :
                  game.mode === "Bot" ? <><strong>Bot Sign:</strong> {game.rsign}</> : 
                  <><strong>Blue2 Sign:</strong> {game.rsign}</>
                  }
                </Typography>
                <Typography variant="body1" style={{ marginBottom: '5px' }}>
                  <strong>Game Date:</strong> {game.gameDate}
                </Typography>
                <Typography variant="h4" color="secondary" className='winner-msg'>
                  <strong>Winner:</strong> {game.winner}
                </Typography>
              </div>
            </CardContent>
          </Card>
        </div>
      ))}
    </div>
  );
}

export default GameList;
