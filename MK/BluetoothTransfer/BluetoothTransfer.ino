#include <Keypad.h>
#include <LiquidCrystal.h>
#define RS 37
#define EN 36
#define D4 35
#define D5 34
#define D6 33
#define D7 32
#define ROWS 4
#define COLS 3
#define BUZ 56

LiquidCrystal lcd(RS, EN, D4, D5, D6, D7);

char keys[ROWS][COLS] = {
  {'1', '2', '3'},
  {'4', '5', '6'},
  {'7', '8', '9'},
  {'*', '0', '#'}
};

byte rowPinsL[ROWS] = {22, 23, 24, 25};
byte colPinsL[COLS] = {26, 27, 28};

byte rowPinsR[ROWS] = {53, 52, 51, 50};
byte colPinsR[COLS] = {10, 11, 12};

Keypad keypadL = Keypad(makeKeymap(keys), rowPinsL, colPinsL, ROWS, COLS);
Keypad keypadR = Keypad(makeKeymap(keys), rowPinsR, colPinsR, ROWS, COLS);

char gameArr[3][3] = {
  {0, 0, 0},
  {0, 0, 0},
  {0, 0, 0}
};

char Lsign = 'X';
char Rsign = 'O';
char gameMode = 0;
char plays = 0;
char start = 0;
float seed = 0.0;

inline void useBuzzer() {
  PORTF |= (1 << 2);
  delay(500);
  PORTF &= ~(1 << 2);
}

inline void startGame(char mode) {
  for(char i = 0; i < 3; i++) {
    for(char j = 0; j < 3; j++) {
      gameArr[i][j] = 0;
    }
  }

  lcd.setCursor(0, 0);
  if(mode == 'S') {
    lcd.print("..... Settings .....");
    if(gameMode) {
      lcd.setCursor(0, 1);
      lcd.print("Mode: Player");
      
      lcd.setCursor(0, 2);
      lcd.print("Player1:");
      lcd.print(Lsign);
      lcd.setCursor(11, 2);
      lcd.print("Player2:");
      lcd.print(Rsign);

      lcd.setCursor(0, 3);
      lcd.print("Now plays: ");
      if(plays == 0) {
        lcd.print("Player1");
      } else if(plays == 1) {
        lcd.print("Player2");
      }
    } else {
      lcd.setCursor(0, 1);
      lcd.print("Mode: Bot   ");
      
      lcd.setCursor(0, 2);
      lcd.print("Player1:");
      lcd.print(Lsign);
      lcd.setCursor(11, 2);
      lcd.print("    Bot:");
      lcd.print(Rsign);

      lcd.setCursor(0, 3);
      lcd.print("Now plays: ");
      if(plays == 0) {
        lcd.print("Player1");
      } else if(plays == 1) {
        lcd.print("Bot    ");
      }
    }
  } else if(mode == 'G') {
    lcd.print("..... Game X/O .....");
    Serial.print("{start");
    Serial.print(",");
    for(char a = 0; a < 3; a++) {
      Serial.print(gameArr[a][0] > 0 ? gameArr[a][0] : '-');
      Serial.print(gameArr[a][1] > 0 ? gameArr[a][1] : '-');
      Serial.print(gameArr[a][2] > 0 ? gameArr[a][2] : '-');
      Serial.print(",");
    }
    Serial.print(gameMode == 0 ? "Bot" : "Player");
    Serial.print(",");
    Serial.print(Lsign);
    Serial.print(",");
    Serial.print(Rsign);
    Serial.print(",");
    Serial.print("None");
    Serial.print(",");
    if(plays == 0) {
      Serial.print("Player1");
    } else if(plays == 1) {
      if(gameMode == 0) {
        Serial.print("Bot");
      } else {
        Serial.print("Player2");
      }
    }
    Serial.print("}");
  }
}

void placeSign(char position, char sign) {
  char insRow = 0;
  char insCol = 0;
  if(position < 3) {
    insCol = position;
  } else if(position < 6) {
    insRow = 1;
    insCol = position - 3;
  } else if(position < 9) {
    insRow = 2;
    insCol = position - 6;
  }

  if(seed == 0.0) {
    seed = micros();
    randomSeed(seed);
  }

  if(gameArr[insRow][insCol] == 0) {
    gameArr[insRow][insCol] = sign;
    char winner = checkWinner(sign);
    plays ^= 1;
    if(winner == 0 || winner == 1) {
      blinkingWin(winner);
      lcd.clear();
      delay(250);
      startGame('S');
      start = 1;
    } else {
      if(freeCells() == 0) {
        blinkingDraw();
        lcd.clear();
        delay(250);
        startGame('S');
        start = 1;

        return;
      }

      Serial.print("{start");
      Serial.print(",");
      for(char a = 0; a < 3; a++) {
        Serial.print(gameArr[a][0] > 0 ? gameArr[a][0] : '-');
        Serial.print(gameArr[a][1] > 0 ? gameArr[a][1] : '-');
        Serial.print(gameArr[a][2] > 0 ? gameArr[a][2] : '-');
        Serial.print(",");
      }
      Serial.print(gameMode == 0 ? "Bot" : "Player");
      Serial.print(",");
      Serial.print(Lsign);
      Serial.print(",");
      Serial.print(Rsign);
      Serial.print(",");
      Serial.print("None");
      Serial.print(",");

      lcd.setCursor(0, 3);
      lcd.print("Now plays: ");
      if(plays == 0) {
        lcd.print("Player1");
        Serial.print("Player1");
      } else if(plays == 1) {
        if(gameMode == 0) {
          lcd.print("Bot    ");
          Serial.print("Bot");
        } else if(gameMode == 1) {
          lcd.print("Player2");
          Serial.print("Player2");
        }
      }
      Serial.print("}");
    }
  } else {
    useBuzzer();
  }
}

char freeCells() {
  char freeC = 0;
  for(char i = 0; i < 3; i++) {
    for(char j = 0; j < 3; j++) {
      if(gameArr[i][j] == 0) freeC++;
    }
  }

  return freeC;
}

char checkWinner(char sign) {
  for(char i = 0; i < 3; i++) {
    if(gameArr[i][0] == sign && 
    gameArr[i][1] == sign && 
    gameArr[i][2] == sign) {
      return plays;
    }
  }
  for(char i = 0; i < 3; i++) {
    if(gameArr[0][i] == sign && 
    gameArr[1][i] == sign && 
    gameArr[2][i] == sign) {
      return plays;
    }
  }
  if(gameArr[0][0] == sign && 
  gameArr[1][1] == sign && 
  gameArr[2][2] == sign) {
    return plays;
  }
  if(gameArr[0][2] == sign && 
  gameArr[1][1] == sign && 
  gameArr[2][0] == sign) {
    return plays;
  }

  return 55;
}

char checkForBot(char sign) {
  for(char i = 0; i < 3; i++) {
    if(gameArr[i][0] == sign && 
    gameArr[i][1] == sign && 
    gameArr[i][2] == 0) {
      return 3 + (i * 3);
    } else if(gameArr[i][1] == sign && 
    gameArr[i][2] == sign && 
    gameArr[i][0] == 0) {
      return 1 + (i * 3);
    } else if(gameArr[i][0] == sign && 
    gameArr[i][2] == sign && 
    gameArr[i][1] == 0) {
      return 2 + (i * 3);
    }
  }
  for(char i = 0; i < 3; i++) {
    if(gameArr[0][i] == sign && 
    gameArr[1][i] == sign && 
    gameArr[2][i] == 0) {
      return 7 + i;
    } else if(gameArr[1][i] == sign && 
    gameArr[2][i] == sign && 
    gameArr[0][i] == 0) {
      return 1 + i;
    } else if(gameArr[0][i] == sign && 
    gameArr[2][i] == sign && 
    gameArr[1][i] == 0) {
      return 4 + i;
    }
  }
  if(gameArr[0][0] == sign && 
  gameArr[1][1] == sign && 
  gameArr[2][2] == 0) {
    return 9;
  }
  if(gameArr[1][1] == sign && 
  gameArr[2][2] == sign && 
  gameArr[0][0] == 0) {
    return 1;
  }
  if(gameArr[0][0] == sign && 
  gameArr[2][2] == sign && 
  gameArr[1][1] == 0) {
    return 5;
  }
  if(gameArr[0][2] == sign && 
  gameArr[1][1] == sign && 
  gameArr[2][0] == 0) {
    return 7;
  }
  if(gameArr[1][1] == sign && 
  gameArr[2][0] == sign && 
  gameArr[0][2] == 0) {
    return 3;
  }
  if(gameArr[0][2] == sign && 
  gameArr[2][0] == sign && 
  gameArr[1][1] == 0) {
    return 5;
  }

  return 55;
}

void blinkingWin(char winner) {
  Serial.print("{winner");
  Serial.print(",");
  for(char a = 0; a < 3; a++) {
    Serial.print(gameArr[a][0] > 0 ? gameArr[a][0] : '-');
    Serial.print(gameArr[a][1] > 0 ? gameArr[a][1] : '-');
    Serial.print(gameArr[a][2] > 0 ? gameArr[a][2] : '-');
    Serial.print(",");
  }
  Serial.print(gameMode == 0 ? "Bot" : "Player");
  Serial.print(",");
  Serial.print(Lsign);
  Serial.print(",");
  Serial.print(Rsign);
  Serial.print(",");
  if(winner == 0) {
    Serial.print("Player1");
    Serial.print("}");
  } else if(winner == 1) {
    if(gameMode) {
      Serial.print("Player2");
      Serial.print("}");
    } else {
      Serial.print("Bot");
      Serial.print("}");
    }
  }

  for(char i = 0; i < 5; i++) {
    delay(400);
    lcd.setCursor(0, 3);
    lcd.print("                  ");
    delay(250);
    lcd.setCursor(0, 3);
    if(winner == 0) {
      lcd.print("Winner: Player1");
    } else if(winner == 1) {
      if(gameMode) {
        lcd.print("Winner: Player2");
      } else {
        lcd.print("Winner: Bot    ");
      }
    }
  }
}

void blinkingDraw() {
  Serial.print("{winner");
  Serial.print(",");
  for(char a = 0; a < 3; a++) {
    Serial.print(gameArr[a][0] > 0 ? gameArr[a][0] : '-');
    Serial.print(gameArr[a][1] > 0 ? gameArr[a][1] : '-');
    Serial.print(gameArr[a][2] > 0 ? gameArr[a][2] : '-');
    Serial.print(",");
  }
  Serial.print(gameMode == 0 ? "Bot" : "Player");
  Serial.print(",");
  Serial.print(Lsign);
  Serial.print(",");
  Serial.print(Rsign);
  Serial.print(",");
  Serial.print("Draw");
  Serial.print("}");

  for(char i = 0; i < 5; i++) {
    delay(400);
    lcd.setCursor(0, 3);
    lcd.print("                  ");
    delay(250);
    lcd.setCursor(0, 3);
    lcd.print("Winner: Draw");
  }
}

void setup() {
  Serial.begin(57600);
  lcd.begin(20, 4);
  DDRF |= (1 << 2);
}

void loop() {
  char inputL = keypadL.getKey();
  char inputR = keypadR.getKey();
  switch(inputL) {
    case '*':
      if(start == 2) {
        lcd.clear();
        delay(250);
        startGame('S');
        start = 1;
      } else if(start == 1) {
        char temp = Lsign;
        Lsign = Rsign;
        Rsign = temp;
        lcd.setCursor(0, 2);
        lcd.print("Player1:");
        lcd.print(Lsign);
        if(gameMode) {
          lcd.setCursor(11, 2);
          lcd.print("Player2:");
          lcd.print(Rsign);
        } else {
          lcd.setCursor(11, 2);
          lcd.print("    Bot:");
          lcd.print(Rsign);
        }
      } else {
        useBuzzer();
      }
      break;
    case '0':
      if(start == 0) {
        startGame('S');
        start = 1;
      } else if(start == 1) {
        startGame('G');
        start = 2;
      } else if(start == 2) {
        Serial.print("{winner");
        Serial.print(",");
        for(char a = 0; a < 3; a++) {
          Serial.print(gameArr[a][0] > 0 ? gameArr[a][0] : '-');
          Serial.print(gameArr[a][1] > 0 ? gameArr[a][1] : '-');
          Serial.print(gameArr[a][2] > 0 ? gameArr[a][2] : '-');
          Serial.print(",");
        }
        Serial.print(gameMode == 0 ? "Bot" : "Player");
        Serial.print(",");
        Serial.print(Lsign);
        Serial.print(",");
        Serial.print(Rsign);
        Serial.print(",");
        Serial.print("None");
        Serial.print("}");

        lcd.clear();
        start = 0;
      }
      break;
    case '#':
      if(start == 1) {
        gameMode ^= 1;
        if(gameMode) {
          lcd.setCursor(0, 1);
          lcd.print("Mode: Player");

          lcd.setCursor(11, 2);
          lcd.print("Player2:");
          lcd.print(Rsign);

          lcd.setCursor(0, 3);
          lcd.print("Now plays: ");
          if(plays == 0) {
            lcd.print("Player1");
          } else if(plays == 1) {
            lcd.print("Player2");
          }
        } else {
          lcd.setCursor(0, 1);
          lcd.print("Mode: Bot   ");

          lcd.setCursor(11, 2);
          lcd.print("    Bot:");
          lcd.print(Rsign);

          lcd.setCursor(0, 3);
          lcd.print("Now plays: ");
          if(plays == 0) {
            lcd.print("Player1");
          } else if(plays == 1) {
            lcd.print("Bot    ");
          }
        }
      } else {
        useBuzzer();
      }
      break;
    case 0:
      break;
    default:
      if(start == 2) {
        if(plays == 0) {
          placeSign(inputL - 49, Lsign);
        } else {
          useBuzzer();
        }
      } else if(start == 1) {
        if(inputL == '8') {
          plays ^= 1;
          lcd.setCursor(0, 3);
          lcd.print("Now plays: ");
          if(plays == 0) {
            lcd.print("Player1");
          } else if(plays == 1) {
            if(gameMode) {
              lcd.print("Player2");
            } else {
              lcd.print("Bot    ");
            }
          }
          break;
        }
        useBuzzer();
      } else {
        useBuzzer();
      }
      break;
  }

  if(gameMode == 1 && start == 2) {
    switch(inputR) {
      case '*':
        useBuzzer();
        break;
      case '0':
        useBuzzer();
        break;
      case '#':
        useBuzzer();
        break;
      case 0:
        break;
      default:
        if(plays == 1) {
          placeSign(inputR - 49, Rsign);
        } else {
          useBuzzer();
        }
        break;
    }
  }

  if(gameMode == 0 && start == 2 && plays == 1) {
    delay(800);
    char mind = random(101);
    char randRow = random(3);
    char randCol = random(3);
    char resP = checkForBot(Lsign);
    char resB = checkForBot(Rsign);
    if(resP != 55 && resB != 55) {
      if(mind > 90) {
        placeSign(resP - 1, Rsign);
      } else {
        placeSign(resB - 1, Rsign);
      }
    } else if(resB != 55) {
      placeSign(resB - 1, Rsign);
    } else if(resP != 55) {
      placeSign(resP - 1, Rsign);
    } else {
      while(gameArr[randRow][randCol] != 0) {
        randRow = random(3);
        randCol = random(3);
      }
      placeSign((randRow * 3) + randCol, Rsign);
    }
  }
}