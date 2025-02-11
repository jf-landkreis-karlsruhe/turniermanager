package de.jf.karlsruhe.logic;

import de.jf.karlsruhe.controller.TournamentController;
import de.jf.karlsruhe.model.base.*;
import de.jf.karlsruhe.model.repos.*;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.util.*;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class TournamentControllerNewIntegrationTest {

    @Mock
    private TournamentRepository tournamentRepository;

    @Mock
    private TeamRepository teamRepository;

    @Mock
    private LeagueRepository leagueRepository;

    @Mock
    private AgeGroupRepository ageGroupRepository;

    @Mock
    private RoundRepository roundRepository;

    @InjectMocks
    private TournamentController tournamentController;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this); // Initialisiert Mocks
    }

    @Test
    void testCreateQualificationTournamentRound() {
        // Arrange
        UUID tournamentId = UUID.randomUUID();
        String roundName = "Test Round";

        // Erstelle ein echtes Tournament-Objekt
        Tournament tournament = Tournament.builder()
                .id(tournamentId)
                .name("Test Tournament")
                .rounds(new ArrayList<>()) // Initial leer
                .build();

        // Mock Tournament Repository
        when(tournamentRepository.findById(tournamentId)).thenReturn(Optional.of(tournament));
        when(tournamentRepository.save(any(Tournament.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // Setze AgeGroups
        AgeGroup ageGroupU10 = AgeGroup.builder().id(UUID.randomUUID()).name("U10").build();
        AgeGroup ageGroupU12 = AgeGroup.builder().id(UUID.randomUUID()).name("U12").build();
        List<AgeGroup> ageGroups = Arrays.asList(ageGroupU10, ageGroupU12);

        // Mock AgeGroup Repository
        when(ageGroupRepository.findAll()).thenReturn(ageGroups);

        // Setze Teams für jede AgeGroup
        List<Team> teamsForU10 = Arrays.asList(
                Team.builder().id(UUID.randomUUID()).name("Team 1").build(),
                Team.builder().id(UUID.randomUUID()).name("Team 2").build(),
                Team.builder().id(UUID.randomUUID()).name("Team 3").build()
        );

        List<Team> teamsForU12 = Arrays.asList(
                Team.builder().id(UUID.randomUUID()).name("Team A").build(),
                Team.builder().id(UUID.randomUUID()).name("Team B").build()
        );

        when(teamRepository.findByAgeGroupId(ageGroupU10.getId())).thenReturn(teamsForU10);
        when(teamRepository.findByAgeGroupId(ageGroupU12.getId())).thenReturn(teamsForU12);

        // Mock League und Round Speicherung
        when(leagueRepository.save(any(League.class))).thenAnswer(invocation -> invocation.getArgument(0));
        when(roundRepository.save(any(Round.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // Act
        Tournament result = tournamentController.createTournamentRound(tournamentId, roundName);

        // Assert
        assertNotNull(result, "Das Ergebnis-Objekt darf nicht null sein");
        assertEquals(tournamentId, result.getId(), "Die Turnier-ID sollte gleich bleiben");
        assertNotNull(result.getRounds(), "Es sollten Runden zum Turnier hinzugefügt werden");
        assertEquals(2, result.getRounds().size(), "Nur zwei Runden sollten erstellt werden");

        // Verifiziere die Runde
        Round round1 = getRound(result);
        Round round2 = result.getRounds().get(1);
        assertEquals(1, round1.getLeagues().size(), "Es sollten zwei Ligen erstellt werden (eine pro Altersgruppe)");
        assertEquals(1, round2.getLeagues().size(), "Es sollten zwei Ligen erstellt werden (eine pro Altersgruppe)");

        // Verifiziere Ligen und Teams
        round1.getLeagues().forEach(league -> {
            assertNotNull(league.getTeams(), "Jede Liga sollte mit Teams befüllt werden");
            assertFalse(league.getTeams().isEmpty(), "Jede Liga sollte mindestens ein Team enthalten");
        });

        // Verify interactions
        verify(tournamentRepository, times(1)).findById(tournamentId);
        verify(ageGroupRepository, times(1)).findAll();
        verify(teamRepository, atLeastOnce()).findByAgeGroupId(any(UUID.class));
        verify(leagueRepository, times(2)).save(any(League.class)); // Zwei Ligen
        verify(roundRepository, times(2)).save(any(Round.class)); // Eine Runde
    }

    private static Round getRound(Tournament result) {
        return result.getRounds().get(0);
    }
}