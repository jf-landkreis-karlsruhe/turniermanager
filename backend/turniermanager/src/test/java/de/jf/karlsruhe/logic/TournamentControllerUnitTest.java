package de.jf.karlsruhe.logic;

import de.jf.karlsruhe.controller.PitchScheduler;
import de.jf.karlsruhe.controller.TournamentController;
import de.jf.karlsruhe.model.base.*;
import de.jf.karlsruhe.model.repos.*;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.time.LocalDateTime;
import java.util.*;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class TournamentControllerUnitTest {

    @Mock
    private TournamentRepository tournamentRepository;

    @Mock
    private TeamRepository teamRepository;

    @Mock
    private PitchRepository pitchRepository;

    @Mock
    private AgeGroupRepository ageGroupRepository;

    @Mock
    private LeagueRepository leagueRepository;

    @Mock
    private RoundRepository roundRepository;

    @Mock
    private GameRepository gameRepository;

    @Mock
    private PitchScheduler pitchScheduler;

    @InjectMocks
    private TournamentController tournamentController;

    private UUID tournamentId;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);

        tournamentId = UUID.randomUUID(); // Eine eindeutige ID für das Turnier
    }

    @Test
    void testTournamentSimulation() {
        // *** Schritt 1: Turnier erstellen ***
        String tournamentName = "Test Turnier";
        LocalDateTime startTime = LocalDateTime.now();
        int playTime = 25;
        int breakTime = 10;

        Tournament tournament = Tournament.builder()
                .id(tournamentId)
                .name(tournamentName)
                .gameSettings(GameSettings.builder()
                        .startTime(startTime)
                        .playTime(playTime)
                        .breakTime(breakTime)
                        .build())
                .rounds(new ArrayList<>())
                .build();

        when(tournamentRepository.save(any(Tournament.class))).thenReturn(tournament);
        when(pitchRepository.findAll()).thenReturn(new ArrayList<>());

        Tournament createdTournament = tournamentController.createTournament(tournamentName, startTime, playTime, breakTime);

        assertNotNull(createdTournament);
        assertEquals(tournamentName, createdTournament.getName());
        verify(tournamentRepository, times(1)).save(any(Tournament.class));

        // *** Schritt 2: Qualifikationsrunde erstellen ***
        List<AgeGroup> ageGroups = List.of(
                AgeGroup.builder().id(UUID.randomUUID()).name("U10").build(),
                AgeGroup.builder().id(UUID.randomUUID()).name("U12").build()
        );

        when(tournamentRepository.findById(tournamentId)).thenReturn(Optional.of(tournament));
        when(ageGroupRepository.findAll()).thenReturn(ageGroups);

        // Teams für Altersgruppen erstellen
        List<Team> teamsU10 = createTeams("U10-Team", ageGroups.get(0), 8); // 8 Teams für U10
        List<Team> teamsU12 = createTeams("U12-Team", ageGroups.get(1), 6); // 6 Teams für U12

        when(teamRepository.findByAgeGroupId(ageGroups.get(0).getId())).thenReturn(teamsU10);
        when(teamRepository.findByAgeGroupId(ageGroups.get(1).getId())).thenReturn(teamsU12);

        Tournament qualificationTournament = tournamentController.createQualificationTournament(tournamentId);

        assertNotNull(qualificationTournament);
        verify(leagueRepository, atLeast(1)).save(any(League.class));
        verify(roundRepository, atLeast(1)).save(any(Round.class));

        // Überprüfen der Qualifikationsrunden
        // Es gibt nur eine Qualifikationsrunde
        assertEquals(2, qualificationTournament.getRounds().size());
        qualificationTournament.getRounds().get(0).getLeagues().forEach(league -> {
            assertTrue(league.isQualification());
            assertNotNull(league.getTeams(), "Teams in der Qualifikationsliga sollten nicht null sein.");
        });

        // *** Schritt 3: Erste zusätzliche Runde erstellen (z. B. Zwischenrunde) ***
        String firstRoundName = "Qualifikationsrunde";
        Tournament firstRoundTournament = tournamentController.createTournamentRound();

        // Verifizieren, dass die erste neue Runde erfolgreich erstellt wurde
        assertNotNull(firstRoundTournament);
        verify(leagueRepository, atLeast(2)).save(any(League.class)); // Jede Altersgruppe hat ihre eigene Liga
        verify(roundRepository, atLeast(2)).save(any(Round.class)); // Die neue Runde wird gespeichert
        assertEquals(4, firstRoundTournament.getRounds().size(), "Das Turnier sollte nun zwei Runden enthalten.");
        assertEquals(firstRoundName, firstRoundTournament.getRounds().get(1).getName());

        // Überprüfen, dass die neuen Ligen korrekt erstellt wurden
        firstRoundTournament.getRounds().get(2).getLeagues().forEach(league -> {
            assertFalse(league.isQualification()); // Zusätzliche Runden sind keine Qualifikationsrunden
            assertNotNull(league.getTeams(), "Teams in der neuen Liga sollten nicht null sein.");
            assertTrue(league.getTeams().isEmpty(), "Eine Liga sollte Teams enthalten.");
        });

        // *** Schritt 4: Zweite zusätzliche Runde erstellen (Finalrunde) ***
        String finalRoundName = "Finalrunde";
        Tournament finalRoundTournament = tournamentController.createTournamentRound();

        // Verifizieren, dass die finale Runde erfolgreich erstellt wurde
        assertNotNull(finalRoundTournament);
        verify(leagueRepository, atLeast(3)).save(any(League.class)); // Jede Altersgruppe hat ihre eigene Liga
        verify(roundRepository, atLeast(3)).save(any(Round.class)); // Die finale Runde wird gespeichert
        assertEquals(6, finalRoundTournament.getRounds().size(), "Das Turnier sollte nun drei Runden enthalten.");
        assertEquals(finalRoundName, finalRoundTournament.getRounds().get(4).getName());

        // Überprüfen, dass die finale Liga korrekt erstellt wurde
        finalRoundTournament.getRounds().get(2).getLeagues().forEach(league -> {
            assertFalse(league.isQualification());
            assertNotNull(league.getTeams(), "Teams in der finalen Liga sollten nicht null sein.");
            assertTrue(league.getTeams().size() <= 6, "Finale Liga sollte maximal 6 Teams enthalten.");
        });

        // Verifizieren, dass Spiele generiert wurden
        verify(gameRepository, atLeast(3)).saveAll(anyList()); // Spiele für alle Runden sollten gespeichert werden
    }

    // Hilfsmethode: Teams erstellen
    private List<Team> createTeams(String baseName, AgeGroup ageGroup, int count) {
        List<Team> teams = new ArrayList<>();
        for (int i = 1; i <= count; i++) {
            Team team = Team.builder()
                    .id(UUID.randomUUID())
                    .name(baseName + " " + i)
                    .ageGroup(ageGroup)
                    .build();
            teams.add(team);
        }
        return teams;
    }
}