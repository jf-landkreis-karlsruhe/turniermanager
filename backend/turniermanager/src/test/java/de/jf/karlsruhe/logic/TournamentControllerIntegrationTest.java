package de.jf.karlsruhe.logic;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import de.jf.karlsruhe.model.base.*;
import de.jf.karlsruhe.model.repos.*;
import jakarta.transaction.Transactional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@Transactional
public class TournamentControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private TournamentRepository tournamentRepository;

    @Autowired
    private AgeGroupRepository ageGroupRepository;

    @Autowired
    private TeamRepository teamRepository;

    @Autowired
    private PitchRepository pitchRepository;

    @Autowired
    private LeagueRepository leagueRepository;

    @Autowired
    private RoundRepository roundRepository;

    @Autowired
    private GameRepository gameRepository;

    @BeforeEach
    public void setUp() {
        createTestData();
    }

    private void createTestData() {
        // Erstellen von Altersgruppen
        AgeGroup u16 = ageGroupRepository.save(AgeGroup.builder().name("U16").build());
        AgeGroup u18 = ageGroupRepository.save(AgeGroup.builder().name("U18").build());

        // Erstellen von Pitches
        Pitch pitch1 = Pitch.builder().name("Pitch 1").ageGroups(List.of(u16, u18)).build();
        Pitch pitch2 = Pitch.builder().name("Pitch 2").ageGroups(List.of(u16)).build();
        pitchRepository.saveAll(List.of(pitch1, pitch2));

        // Erstellen von Teams für verschiedene Altersgruppen
        Team team1 = Team.builder().name("Team A").ageGroup(u16).build();
        Team team2 = Team.builder().name("Team B").ageGroup(u16).build();
        Team team3 = Team.builder().name("Team C").ageGroup(u18).build();
        Team team4 = Team.builder().name("Team D").ageGroup(u18).build();
        teamRepository.saveAll(List.of(team1, team2, team3, team4));
    }

    @Test
    public void testCreateTournament() throws Exception {
        // Turnier-Erstellungs-Request an den Controller senden
        String tournamentName = "Indiaca Cup";
        LocalDateTime startTime = LocalDateTime.now();
        int playTime = 30;  // 30 Minuten pro Spiel
        int breakTime = 10; // 10 Minuten Pause zwischen Spielen

        mockMvc.perform(post("/api/tournament/create")
                        .param("name", tournamentName)
                        .param("startTime", startTime.toString())
                        .param("playTime", String.valueOf(playTime))
                        .param("breakTime", String.valueOf(breakTime)))
                .andExpect(status().isOk());

        // Überprüfen, ob das Turnier angelegt wurde
        List<Tournament> tournaments = tournamentRepository.findAll();
        assertThat(tournaments).hasSize(1);

        Tournament tournament = tournaments.get(0);
        assertThat(tournament.getName()).isEqualTo(tournamentName);

        // Überprüfen, ob die Ligen korrekt angelegt wurden
        List<League> leagues = leagueRepository.findAll();
        assertThat(leagues).hasSize(2); // Zwei Altersgruppen = Zwei Ligen

        for (League league : leagues) {
            assertThat(league.getTournament()).isEqualTo(tournament);
        }

        // Überprüfen, ob Runden und Spiele erstellt wurden
        List<Round> allRounds = roundRepository.findAll();
        assertThat(allRounds).isNotEmpty();

        List<Game> allGames = gameRepository.findAll();
        assertThat(allGames).isNotEmpty();

        allGames.forEach(t -> Logger.getGlobal().log(Level.INFO, t.toString()));


        // Verifizieren, ob die Spiele korrekt Teams und Pitches zugeordnet wurden
        for (Game game : allGames) {
            assertThat(game.getTeamA()).isNotNull();
            assertThat(game.getTeamB()).isNotNull();
            assertThat(game.getPitch()).isNotNull();
        }

        // JSON-Ausgabe des gesamten Turniers
        printTournamentAsJson(tournament);

        // Tabellarische Darstellung unter Berücksichtigung der Runden
        printTournamentAsTable(tournament, leagues);
    }

    private void printTournamentAsJson(Tournament tournament) throws Exception {
        ObjectMapper mapper = new ObjectMapper();
        // Modul für Java-Zeittypen registrieren
        mapper.registerModule(new com.fasterxml.jackson.datatype.jsr310.JavaTimeModule());
        mapper.enable(SerializationFeature.INDENT_OUTPUT);

        String json = mapper.writeValueAsString(tournament);
        System.out.println("\n--- Tournament JSON Output ---");
        System.out.println(json);
    }

    private void printTournamentAsTable(Tournament tournament, List<League> leagues) {
        System.out.println("\n--- Tournament Table Output ---");
        System.out.println("TOURNAMENT: " + tournament.getName());
        System.out.println("--------------------------------");

        for (League league : leagues) {
            System.out.println("LEAGUE: " + league.getName());

            // Runden für diese Liga finden
            List<Round> rounds = roundRepository.findByLeague(league);
            for (Round round : rounds) {
                System.out.println("  ROUND: " + round.getName());

                // Spiele für diese Runde finden
                List<Game> games = gameRepository.findByRound(round);

                for (Game game : games) {
                    System.out.printf(
                            "    GAME: %s vs %s on %s at %s\n",
                            game.getTeamA().getName(),
                            game.getTeamB().getName(),
                            game.getPitch().getName(),
                            game.getStartTime()
                    );
                }
            }
            System.out.println("--------------------------------");
        }
    }
}