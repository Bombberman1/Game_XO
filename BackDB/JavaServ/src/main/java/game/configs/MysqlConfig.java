package game.configs;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

@Configuration
public class MysqlConfig {
    public static Connection connection;
    @Bean
    void addDB() {
        String url = "jdbc:mysql://localhost:3306/mydb";
        String user = "root";
        String password = "Oleg200525";
        try {
            connection = DriverManager.getConnection(url, user, password);
            System.out.println("Successful connection: " + url);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
}
