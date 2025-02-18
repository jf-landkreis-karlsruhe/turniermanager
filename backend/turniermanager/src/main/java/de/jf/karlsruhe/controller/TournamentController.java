package de.jf.karlsruhe.controller;//package de.jf.karlsruhe.controller;

import de.jf.karlsruhe.model.base.*;
import de.jf.karlsruhe.model.game.GameSettings;
import de.jf.karlsruhe.model.repos.*;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/turniersetup")
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
        if (ageGroupRepository.count() == 0 && pitchRepository.count() == 0 && teamRepository.count() == 0)
            return tournamentRepository.findById(tournamentId).orElseThrow();
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
            tournament.addRound(round);
            roundRepository.save(round);
            leagueRepository.save(league);
        }
        List<League> all = leagueRepository.findAll();
        for (League league : all) {
            List<Game> games = generateLeagueGames(league);
            List<Game> scheduled = pitchScheduler.scheduleGames(games);

            league.getRound().addGames(scheduled);
            leagueRepository.save(league);
            gameRepository.saveAll(scheduled);
        }
        roundRepository.flush();
        gameRepository.flush();
        return tournament;
    }


    /**
     *
     */
    @PostMapping("/create/round")
    public Tournament createTournamentRound(@RequestParam UUID tournamentId, @RequestParam String roundName) {
        if (ageGroupRepository.count() == 0 && pitchRepository.count() == 0 && teamRepository.count() == 0)
            return tournamentRepository.findById(tournamentId).orElseThrow();

        Tournament tournament = tournamentRepository.findById(tournamentId).orElseThrow();
        List<AgeGroup> ageGroups = ageGroupRepository.findAll();
        for (AgeGroup ageGroup : ageGroups) {
            List<Team> teams = teamRepository.findByAgeGroupId(ageGroup.getId());
            List<Game> allGames = gameRepository.findAll();
            List<Team> teamsSortedByPerformance;
            if (!allGames.isEmpty()) {
                teamsSortedByPerformance = getTeamsSortedByPerformance(allGames, teams);
            } else {
                teamsSortedByPerformance = teams;
            }
            Map<League, List<Team>> balancedLeaguesForAgeGroup = createBalancedLeaguesForAgeGroup(teamsSortedByPerformance, 6, roundName, tournament);
            balancedLeaguesForAgeGroup.forEach((league, teamsInLeague) -> {
                league.setAgeGroup(ageGroup);
                league.setTournament(tournament);
                league.setTeams(teamsInLeague);

                List<Game> games = generateLeagueGames(league);
                List<Game> scheduled = pitchScheduler.scheduleGames(games);
                league.getRound().addGames(scheduled);
                roundRepository.save(league.getRound());
                leagueRepository.save(league);
                gameRepository.saveAll(scheduled);
            });
        }
        return tournament;
    }

    @PostMapping("/addBreak")
    public void addBreakViaApi(@RequestParam LocalDateTime breakTime, @RequestParam int duration) {
        pitchScheduler.delayGamesAfter(breakTime, duration);
    }

    @DeleteMapping("/reset")
    public Tournament resetTournament() {
        leagueRepository.deleteAll();
        teamRepository.deleteAll();
        ageGroupRepository.deleteAll();
        tournamentRepository.deleteAll();
        return null;
    }

    public List<Game> generateLeagueGames(League league) {
        List<Game> games = new ArrayList<>();
        List<Team> teams = league.getTeams();

        if (teams == null || teams.size() < 2) {
            return games; // Kein Spiel möglich, wenn weniger als 2 Teams vorhanden sind
        }

        int numberOfTeams = teams.size();

        // Durchlaufen aller möglichen Paarungen (Kombinationen)
        long count = gameRepository.count();
        for (int i = 0; i < numberOfTeams - 1; i++) {
            for (int j = i + 1; j < numberOfTeams; j++) {
                count++;
                Team teamA = teams.get(i);
                Team teamB = teams.get(j);

                // Spiel erstellen und zur Liste hinzufügen
                Game game = Game.builder()
                        .teamA(teamA)
                        .teamB(teamB)
                        .round(league.getRound())
                        .gameNumber(count)
                        .build();

                games.add(game);
            }
        }
        return games;
    }

    public List<Team> getTeamsSortedByPerformance(List<Game> games, List<Team> teams) {
        if (games == null || games.isEmpty() || teams == null || teams.isEmpty()) {
            return new ArrayList<>(); // Keine Spiele oder Teams vorhanden
        }

        Map<Team, Integer> teamPointsMap = new HashMap<>();

        // Punkte für jedes Team berechnen
        for (Team team : teams) {
            int totalPoints = 0;

            for (Game g : games) {
                int teamAScore = g.getTeamAScore();
                int teamBScore = g.getTeamBScore();
                boolean isTeamA = Objects.equals(g.getTeamA(), team);
                boolean isTeamB = Objects.equals(g.getTeamB(), team);

                if (isTeamA || isTeamB) {
                    int eigeneTore = isTeamA ? teamAScore : teamBScore;
                    int gegnerischeTore = isTeamA ? teamBScore : teamAScore;

                    if (eigeneTore > gegnerischeTore) {
                        totalPoints += 3;
                    } else if (eigeneTore == gegnerischeTore) {
                        totalPoints += 1;
                    }
                }
            }
            teamPointsMap.put(team, totalPoints);
        }

        // Teams nach Punkten absteigend sortieren
        return teams.stream()
                .sorted((t1, t2) -> Integer.compare(teamPointsMap.get(t2), teamPointsMap.get(t1)))
                .collect(Collectors.toList());
    }

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
        HashMap<League, Integer> numberOfTeamsPerLeague = new HashMap<>();
        for (Team team : teams) {
            League currentLeague = leagues.get(leagueIndex);
            Integer value = numberOfTeamsPerLeague.get(currentLeague);
            if (value == null) {
                numberOfTeamsPerLeague.put(currentLeague, 1);
            } else {
                value += 1;
                numberOfTeamsPerLeague.put(currentLeague, value);
            }
            leagueIndex = (leagueIndex + 1) % leagues.size(); // Wechsel per Round-Robin
        }

        Queue<Team> teamsQueue = new LinkedList<>(teams);
        for (League league : numberOfTeamsPerLeague.keySet()) {
            int i = numberOfTeamsPerLeague.get(league);
            for (int j = 0; j < i; j++) {
                Team poll = teamsQueue.poll();
                league.addTeam(poll);
            }
        }

        round.setLeagues(leagues);
        tournament.addRound(round);
        return leagueMap;
    }
}