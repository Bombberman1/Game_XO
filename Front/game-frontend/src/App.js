import React, { useState } from 'react';
import { AppBar, Toolbar, Button, Typography, Container } from '@mui/material';
import GameList from './components/GameList';
import CurrentGame from './components/CurrentGame';

function App() {
  const [view, setView] = useState('current');

  return (
    <div className="App">
      <AppBar position="static">
        <Toolbar style={{ display: 'flex', justifyContent: 'center' }}>
          <Button style={{ marginLeft: "15px", marginRight: "15px" }} color="inherit" onClick={() => setView('current')}>
            Current Game
          </Button>
          <Typography variant="h6" style={{ flexGrow: 1, textAlign: 'center' }}>
            Game X/O
          </Typography>
          <Button style={{ marginLeft: "15px", marginRight: "15px" }} color="inherit" onClick={() => setView('games')}>
            Game History
          </Button>
        </Toolbar>
      </AppBar>
      <Container style={{ marginTop: '20px' }}>
        {view === 'current' ? <CurrentGame /> : <GameList />}
      </Container>
    </div>
  );
}

export default App;
