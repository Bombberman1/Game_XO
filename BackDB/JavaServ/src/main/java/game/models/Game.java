package game.models;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
public class Game {
    private String row0;
    private String row1;
    private String row2;
    private String mode;
    private String lSign;
    private String rSign;
    private LocalDateTime gameDate;
    private String winner;
    private String plays;
    public Game(String row0, String row1, String row2, String mode, String lSign, String rSign, LocalDateTime gameDate, String winner) {
        this.row0 = row0;
        this.row1 = row1;
        this.row2 = row2;
        this.mode = mode;
        this.lSign = lSign;
        this.rSign = rSign;
        this.gameDate = gameDate;
        this.winner = winner;
    }
}
