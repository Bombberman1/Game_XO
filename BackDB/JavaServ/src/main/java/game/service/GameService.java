package game.service;

import com.fazecast.jSerialComm.SerialPort;
import game.configs.MysqlConfig;
import game.models.Game;
import jakarta.annotation.PostConstruct;
import org.springframework.stereotype.Service;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.LinkedList;
import java.util.Objects;

@Service
public class GameService {

    private static final String PORT_NAME = "COM3";
    private static final int BAUD_RATE = 57600;

    private Game currentGame;

    @PostConstruct
    public void init() {
        SerialPort comPort = SerialPort.getCommPort(PORT_NAME);
        comPort.setBaudRate(BAUD_RATE);

        if (comPort.openPort()) {
            System.out.println("Port opened successfully.");

            new Thread(() -> {
                StringBuilder buffer = new StringBuilder();
                while (true) {
                    if (comPort.bytesAvailable() > 0) {
                        byte[] readBuffer = new byte[comPort.bytesAvailable()];
                        int numRead = comPort.readBytes(readBuffer, readBuffer.length);
                        String receivedData = new String(readBuffer);
                        buffer.append(receivedData);
                        processBuffer(buffer);
                    }

                    try {
                        Thread.sleep(10);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
            }).start();

        } else {
            System.out.println("Failed to open port.");
        }
    }

    private void processBuffer(StringBuilder buffer) {
        int startIndex;
        while ((startIndex = buffer.indexOf("{")) != -1 && buffer.indexOf("}", startIndex) != -1) {
            int endIndex = buffer.indexOf("}", startIndex);
            String completeMessage = buffer.substring(startIndex, endIndex + 1);
            buffer.delete(0, endIndex + 1);
            processReceivedData(completeMessage);
        }
    }

    public void processReceivedData(String data) {
        System.out.println("Data: " + data);
        if (data.startsWith("{winner")) {
            String cleanedData = data.replace("{winner", "").trim();
            String[] parts = cleanedData.substring(1, cleanedData.length() - 1).split(",");

            if (parts.length == 7) {
                String row0 = parts[0];
                String row1 = parts[1];
                String row2 = parts[2];
                String mode = parts[3];
                String p1Sign = parts[4];
                String p2Sign = parts[5];
                String winner = parts[6];
                Game game = new Game(row0, row1, row2, mode, p1Sign, p2Sign, LocalDateTime.now(), winner);

                addGame(game);

                if(currentGame != null) {
                    currentGame.setRow0(row0);
                    currentGame.setRow1(row1);
                    currentGame.setRow2(row2);
                    currentGame.setWinner(winner);
                }
            } else {
                System.out.println("Invalid data format.");
            }
        } else if (data.startsWith("{start")) {
            String cleanedData = data.replace("{start", "").trim();
            String[] parts = cleanedData.substring(1, cleanedData.length() - 1).split(",");

            if (parts.length == 8) {
                String row0 = parts[0];
                String row1 = parts[1];
                String row2 = parts[2];
                String mode = parts[3];
                String p1Sign = parts[4];
                String p2Sign = parts[5];
                String winner = parts[6];
                String plays = parts[7];
                if(Objects.equals(row0, "---") && Objects.equals(row1, "---") && Objects.equals(row2, "---")) {
                    currentGame = new Game(row0, row1, row2, mode, p1Sign, p2Sign, LocalDateTime.now(), winner);
                }
                currentGame.setRow0(row0);
                currentGame.setRow1(row1);
                currentGame.setRow2(row2);
                currentGame.setPlays(plays);
            } else {
                System.out.println("Invalid data format.");
            }
        }
    }

    public Game getCurrentGame() {
        return currentGame;
    }

    public LinkedList<Game> getGames() {
        String query = "SELECT * FROM mydb.gamehistory";
        LinkedList<Game> games = new LinkedList<>();

        try (Statement statement = MysqlConfig.connection.createStatement();
             ResultSet resultSet = statement.executeQuery(query)) {

            while (resultSet.next()) {
                Game game = new Game(
                        resultSet.getString("0row"),
                        resultSet.getString("1row"),
                        resultSet.getString("2row"),
                        resultSet.getString("mode"),
                        resultSet.getString("p1Sign"),
                        resultSet.getString("p2Sign"),
                        resultSet.getTimestamp("time").toLocalDateTime(),
                        resultSet.getString("winner")
                );
                games.add(game);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error fetching game history", e);
        }

        return games;
    }

    public void addGame(Game game) {
        String query = "INSERT into gamehistory(0row,1row,2row,mode,p1Sign,p2Sign,time,winner) values(?,?,?,?,?,?,?,?)";

        try (PreparedStatement preparedStatement = MysqlConfig.connection.prepareStatement(query)) {

            preparedStatement.setString(1, game.getRow0());
            preparedStatement.setString(2, game.getRow1());
            preparedStatement.setString(3, game.getRow2());
            preparedStatement.setString(4, game.getMode());
            preparedStatement.setString(5, game.getLSign());
            preparedStatement.setString(6, game.getRSign());
            preparedStatement.setTimestamp(7, Timestamp.valueOf(game.getGameDate()));
            preparedStatement.setString(8, game.getWinner());

            preparedStatement.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("Error adding game", e);
        }
    }
}
