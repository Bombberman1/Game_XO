package game.controller;

import game.models.Game;
import game.service.GameService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.LinkedList;

@RestController
@RequestMapping("/api/game")
public class GameController {
    @Autowired
    private GameService gameService;

    @GetMapping
    public LinkedList<Game> get() {
        return gameService.getGames();
    }

    @GetMapping("/current-game")
    public Game getCurrentGame() {
        return gameService.getCurrentGame();
    }
}
