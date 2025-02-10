package de.jf.karlsruhe.controller;//package de.jf.karlsruhe.controller;

import de.jf.karlsruhe.model.base.*;
import de.jf.karlsruhe.model.game.GameSettings;
import de.jf.karlsruhe.model.repos.*;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.*;

@RestController
@RequestMapping("/turniersetup/general")
@RequiredArgsConstructor
public class TournamentController {

    private final TournamentRepository tournamentRepository;
    private final TeamRepository teamRepository;
    private final PitchRepository pitchRepository;
    private final AgeGroupRepository ageGroupRepository;
    private final LeagueRepository leagueRepository;
    private final RoundRepository roundRepository;
    private final GameRepository gameRepository;
    private final PitchScheduler pitchScheduler;


    @PostMapping("/create")
    public Tournament createTournament(@RequestParam String name,
                                       @RequestParam LocalDateTime startTime,
                                       @RequestParam int playTime,
                                       @RequestParam int breakTime) {

        GameSettings gameSettings = GameSettings.builder()
                .startTime(startTime)
                .playTime(playTime)
                .breakTime(breakTime)
                .build();

        Tournament tournament = Tournament.builder()
                .name(name)
                .gameSettings(gameSettings)
                .build();

        List<Pitch> pitches = pitchRepository.findAll();
        pitchScheduler.initialize(pitches, gameSettings);
        tournamentRepository.save(tournament);
        return tournament;
    }


    @PostMapping("/create/qualification")
    public Tournament createQualificationTournament(@RequestParam UUID tournamentId) {
        // Altersgruppen laden und Ligen erstellen
        Tournament tournament = tournamentRepository.findById(tournamentId).orElseThrow();
        List<AgeGroup> ageGroups = ageGroupRepository.findAll();
        //qualification rounds
        for (AgeGroup ageGroup : ageGroups) {
            League league = League.builder()
                    .name("Qualifikation " + ageGroup.getName())
                    .tournament(tournament)
                    .isQualification(true)
                    .ageGroup(ageGroup)
                    .teams(teamRepository.findByAgeGroupId(ageGroup.getId()))
                    .build();
            Round round = Round.builder().leagues(List.of(league)).name("Qualifikationsrunde").build();
            league.setRound(round);
            tournament.getRounds().add(round);
            roundRepository.save(round);
            leagueRepository.save(league);
        }
        List<League> all = leagueRepository.findAll();
        for (League league : all) {
            List<Game> games = generateReducedGamesForLeague(league);
            List<Game> scheduled = pitchScheduler.scheduleGames(games);
            gameRepository.saveAll(scheduled);
        }
        return tournament;
    }

    @PostMapping("/create/round")
    public Tournament createQualificationTournament(@RequestParam UUID tournamentId, @RequestParam String roundName) {
        Tournament tournament = tournamentRepository.findById(tournamentId).orElseThrow();
        List<AgeGroup> ageGroups = ageGroupRepository.findAll();
        for (AgeGroup ageGroup : ageGroups) {
            List<Team> teams = teamRepository.findByAgeGroupId(ageGroup.getId());
            Map<League, List<Team>> balancedLeaguesForAgeGroup = createBalancedLeaguesForAgeGroup(teams, 6, roundName, tournament);
            balancedLeaguesForAgeGroup.forEach((league, teamsInLeague) -> {
                league.setAgeGroup(ageGroup);
                league.setTournament(tournament);
                league.setTeams(teamsInLeague);
                leagueRepository.save(league);
            });
        }
        return tournament;
    }


    @DeleteMapping("/reset")
    public Tournament resetTournament() {
        leagueRepository.deleteAll();
        teamRepository.deleteAll();
        ageGroupRepository.deleteAll();
        tournamentRepository.deleteAll();
        return null;
    }


    public List<Game> generateReducedGamesForLeague(League league) {
        List<Game> games = new ArrayList<>();
        List<Team> teams = league.getTeams();

        if (teams == null || teams.isEmpty()) {
            return new ArrayList<>();
        }

        int numberOfTeams = teams.size();
        int maxGamesPerTeam = Math.min(4, numberOfTeams - 1); // Begrenzung auf maximal 4 Spiele pro Team

        // Verwendetes Set, um sicherzustellen, dass sich keine Teams häufiger als einmal paaren
        Set<String> alreadyScheduledPairs = new HashSet<>();

        Random random = new Random();

        for (Team teamA : teams) {
            int gameCount = 0;

            while (gameCount < maxGamesPerTeam) {
                // Wähle zufällig ein anderes Team
                Team teamB = teams.get(random.nextInt(numberOfTeams));

                // TeamA darf nicht gegen sich selbst spielen
                if (teamA.equals(teamB)) {
                    continue;
                }

                // Paarung darf nicht bereits geplant sein
                String pairKey = createPairKey(teamA, teamB);
                if (alreadyScheduledPairs.contains(pairKey)) {
                    continue;
                }

                // Neues Spiel erstellen
                Game game = Game.builder()
                        .teamA(teamA)
                        .teamB(teamB)
                        .round(league.getRound())
                        .build();

                games.add(game);
                alreadyScheduledPairs.add(pairKey); // Speichere geplante Paarung
                gameCount++;
            }
        }

        return games;
    }

    /**
     * Hilfsmethode, um eine Paarung eindeutig zu identifizieren.
     * Beispiel: Paarung von Team A und Team B ergibt einen konsistenten Schlüssel.
     */
    private String createPairKey(Team teamA, Team teamB) {
        return teamA.getId().toString() + "-" + teamB.getId().toString();
    }
//    public List<Game> generateGamesForLeague(League league) {
//        List<Game> games = new ArrayList<>();
//        List<Team> teams = league.getTeams();
//
//        if (teams == null || teams.isEmpty()) {
//            return new ArrayList<>();
//        }
//
//        int numberOfTeams = teams.size();
//
//        // Round-Robin-Algorithmus: Jedes Team spielt gegen jedes andere
//        for (int i = 0; i < numberOfTeams - 1; i++) {
//            for (int j = i + 1; j < numberOfTeams; j++) {
//                // Erstelle ein neues Spiel
//                Game game = Game.builder()
//                        .teamA(teams.get(i))
//                        .teamB(teams.get(j))
//                        .round(null) // Kann mit einer spezifischen Runde verknüpft werden
//                        .build();
//
//                games.add(game);
//            }
//        }
//
//        return games;
//    }

    public Map<League, List<Team>> createBalancedLeaguesForAgeGroup(
            List<Team> teams, int maxTeamsPerLeague, String roundName, Tournament tournament) {

        // Gesamtanzahl Teams und notwendige Anzahl Ligen berechnen
        int totalTeams = teams.size();
        int numberOfLeagues = (int) Math.ceil((double) totalTeams / maxTeamsPerLeague);

        // Ligen erstellen
        List<League> leagues = new ArrayList<>();
        Round round = Round.builder().name(roundName).build();
        for (int i = 0; i < numberOfLeagues; i++) {
            League league = League.builder().isQualification(false).build();
            league.setRound(round);
            league.setName("League " + (i + 1));
            leagues.add(league);
        }
        // Teams gleichmäßig verteilen (Round-Robin-Verteilung)
        Map<League, List<Team>> leagueMap = new HashMap<>();
        for (League league : leagues) {
            leagueMap.put(league, new ArrayList<>()); // Initialisierung der Ligen mit leeren Listen
        }

        int leagueIndex = 0; // Zum Wechseln zwischen den Ligen
        for (Team team : teams) {
            League currentLeague = leagues.get(leagueIndex);
            leagueMap.get(currentLeague).add(team);
            leagueIndex = (leagueIndex + 1) % leagues.size(); // Wechsel per Round-Robin
        }
        round.setLeagues(leagues);
        tournament.getRounds().add(round);
        tournamentRepository.save(tournament);
        roundRepository.save(round);
        return leagueMap;
    }
}