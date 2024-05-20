import React from 'react';
import './GameBoard.css';
import { Box, Typography } from '@mui/material';

function GameBoard({ row0, row1, row2, winningCombination }) {
  const board = [row0, row1, row2];

  const isWinningCell = (rowIndex, cellIndex) => {
    if (!winningCombination) return false;
    return winningCombination.some(([r, c]) => r === rowIndex && c === cellIndex);
  };

  return (
    <Box className="game-board" display="flex" flexDirection="column" alignItems="center">
      {board.map((row, rowIndex) => (
        <Box key={rowIndex} display="flex">
          {row.split('').map((cell, cellIndex) => (
            <Box 
              key={cellIndex} 
              className={`game-cell ${cell === 'X' ? 'cell-x' : cell === 'O' ? 'cell-o' : 'cell-empty'} ${isWinningCell(rowIndex, cellIndex) ? 'winning-cell' : ''}`}
            >
              <Typography variant="h4">{cell !== "-" ? cell : ""}</Typography>
            </Box>
          ))}
        </Box>
      ))}
    </Box>
  );
}

export default GameBoard;
