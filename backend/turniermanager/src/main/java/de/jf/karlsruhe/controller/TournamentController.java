package de.jf.karlsruhe.controller;//package de.jf.karlsruhe.controller;

import de.jf.karlsruhe.model.base.*;
import de.jf.karlsruhe.model.repos.*;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Transactional;
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

    @Transactional
    @PostMapping("/create/qualification")
    public Tournament createQualificationTournament(@RequestParam UUID tournamentId) {
        if (ageGroupRepository.count() == 0 && pitchRepository.count() == 0 && teamRepository.count() == 0)
            return tournamentRepository.findById(tournamentId).orElseThrow();

        Tournament tournament = tournamentRepository.findById(tournamentId).orElseThrow();
        List<AgeGroup> ageGroups = ageGroupRepository.findAll();

        for (AgeGroup ageGroup : ageGroups) {
            League league = League.builder()
                    .name("Qualifikation " + ageGroup.getName())
                    .tournament(tournament)
                    .isQualification(true)
                    .ageGroup(ageGroup)
                    .teams(teamRepository.findByAgeGroupId(ageGroup.getId()))
                    .build();

            Round round = Round.builder().leagues(List.of(league)).name("Qualifikationsrunde").active(true).tournament(tournament).build();
            league.setRound(round);
            tournament.addRound(round);
            roundRepository.save(round);  // save round
            leagueRepository.save(league);  // save league
        }

        List<League> allLeagues = leagueRepository.findAll();
        for (League league : allLeagues) {
            List<Game> games = generateLeagueGames(league);
            List<Game> scheduledGames = setGameTags(pitchScheduler.scheduleGames(games));

            league.getRound().addGames(scheduledGames);
            leagueRepository.save(league);  // save updated league
            gameRepository.saveAll(scheduledGames); // save all scheduled games
        }

        roundRepository.flush();  // ensure all changes are flushed to DB
        gameRepository.flush();  // ensure all game updates are flushed to DB
        return tournament;
    }

    @Transactional
    @PostMapping("/create/round")
    public Tournament createTournamentRound() {
        if (ageGroupRepository.count() == 0 && pitchRepository.count() == 0 && teamRepository.count() == 0)
            return tournamentRepository.findAll().getFirst();
        List<Round> all = roundRepository.findAll();
        all.forEach(round -> {round.setActive(false);});

        Tournament tournament = tournamentRepository.findAll().getFirst();
        List<AgeGroup> ageGroups = ageGroupRepository.findAll();

        for (AgeGroup ageGroup : ageGroups) {
            List<Team> teams = teamRepository.findByAgeGroupId(ageGroup.getId());
            List<Game> allGames = gameRepository.findAll();
            List<Team> sortedTeams = !allGames.isEmpty() ? getTeamsSortedByPerformance(allGames, teams) : teams;

            List<League> leagues = createBalancedLeaguesForAgeGroup(sortedTeams, 6, "Turnier", tournament);

            // Erstelle eine Kopie der League-Liste
            List<League> leaguesCopy = new ArrayList<>(leagues);

            leaguesCopy.forEach(league -> {
                league.setAgeGroup(ageGroup);
                //league.setTournament(tournament); // Sicherstellen, dass das Tournament gesetzt ist

                List<Game> games = generateLeagueGames(league);
                List<Game> scheduledGames = setGameTags(pitchScheduler.scheduleGames(games));


                // Hier vermeiden wir das Hinzufügen von Games zur Liste während der Iteration
                league.getRound().addGames(scheduledGames);

                roundRepository.save(league.getRound());  // save round
                leagueRepository.save(league);  // save league
            });
        }

        return tournament;
    }
    @PostMapping("/set-active-rounds")
    @Transactional
    public void setActiveRounds(@RequestBody List<UUID> activeRoundIds) {
        // Alle Runden auf nicht aktiv setzen
        List<Round> allRounds = roundRepository.findAll();
        allRounds.forEach(round -> round.setActive(false));
        roundRepository.saveAll(allRounds);

        // Gegebene Runden auf aktiv setzen
        if (activeRoundIds != null && !activeRoundIds.isEmpty()) {
            List<Round> roundsToActivate = roundRepository.findAllById(activeRoundIds);
            roundsToActivate.forEach(round -> round.setActive(true));
            roundRepository.saveAll(roundsToActivate);
        }
    }

    @PostMapping("/addBreak")
    public void addBreakViaApi(@RequestParam LocalDateTime breakTime, @RequestParam int duration) {
        pitchScheduler.delayGamesAfter(breakTime, duration);
    }

    @PostMapping("/advanceAfter")
    public void advanceGamesAfterViaApi(@RequestParam LocalDateTime afterTime, @RequestParam int minutes) {
        pitchScheduler.advanceGamesAfter(afterTime, minutes);
    }

    @PostMapping("/shiftBetweenForward")
    public void shiftGamesBetweenForwardViaApi(@RequestParam LocalDateTime startTime, @RequestParam LocalDateTime endTime, @RequestParam int minutes) {
        pitchScheduler.shiftGamesBetweenForward(startTime, endTime, minutes);
    }

    @PostMapping("/shiftBetweenBackward")
    public void shiftGamesBetweenBackwardViaApi(@RequestParam LocalDateTime startTime, @RequestParam LocalDateTime endTime, @RequestParam int minutes) {
        pitchScheduler.shiftGamesBetweenBackward(startTime, endTime, minutes);
    }

    @DeleteMapping("/reset")
    public Tournament resetTournament() {
        leagueRepository.deleteAll();
        teamRepository.deleteAll();
        ageGroupRepository.deleteAll();
        tournamentRepository.deleteAll();
        return null;
    }


    // <------------------- Helper Methods --------------------->


    @Transactional
    public synchronized List<Game> setGameTags(List<Game> games) {
        gameRepository.flush();
        long maxGameNumber = gameRepository.count();

        // Sortiere die Spiele nach startTime
        Collections.sort(games, Comparator.comparing(Game::getStartTime));

        for (Game game : games) {
            maxGameNumber += 1;
            game.setGameNumber(maxGameNumber);
        }
        return games;
    }

    @Transactional
    public List<Game> generateLeagueGames(League league) {
        List<Game> games = new ArrayList<>();
        List<Team> teams = league.getTeams();

        if (teams == null || teams.size() < 2) {
            return games;  // No games if less than 2 teams
        }

        int numberOfTeams = teams.size();

        for (int i = 0; i < numberOfTeams - 1; i++) {
            for (int j = i + 1; j < numberOfTeams; j++) {
                Team teamA = teams.get(i);
                Team teamB = teams.get(j);

                Game game = Game.builder()
                        .teamA(teamA)
                        .teamB(teamB)
                        .round(league.getRound())
                        .build();

                games.add(game);
            }
        }
        return games;
    }

    @Transactional
    public List<Team> getTeamsSortedByPerformance(List<Game> games, List<Team> teams) {
        if (games == null || games.isEmpty() || teams == null || teams.isEmpty()) {
            return new ArrayList<>();  // No games or teams available
        }

        Map<Team, Integer> teamPointsMap = new HashMap<>();

        for (Team team : teams) {
            int totalPoints = 0;

            for (Game g : games) {
                int teamAScore = g.getTeamAScore();
                int teamBScore = g.getTeamBScore();
                boolean isTeamA = Objects.equals(g.getTeamA(), team);
                boolean isTeamB = Objects.equals(g.getTeamB(), team);

                if (isTeamA || isTeamB) {
                    int ownGoals = isTeamA ? teamAScore : teamBScore;
                    int opponentGoals = isTeamA ? teamBScore : teamAScore;

                    if (ownGoals > opponentGoals) {
                        totalPoints += 3;
                    } else if (ownGoals == opponentGoals) {
                        totalPoints += 1;
                    }
                }
            }
            teamPointsMap.put(team, totalPoints);
        }

        return teams.stream()
                .sorted((t1, t2) -> Integer.compare(teamPointsMap.get(t2), teamPointsMap.get(t1)))
                .collect(Collectors.toList());
    }

    @Transactional
    public List<League> createBalancedLeaguesForAgeGroup(
            List<Team> teams, int maxTeamsPerLeague, String roundName, Tournament tournament) {

        int totalTeams = teams.size();
        int numberOfLeagues = (int) Math.ceil((double) totalTeams / maxTeamsPerLeague);

        List<League> leagues = new ArrayList<>();
        Round round = Round.builder().name(roundName).tournament(tournament).active(true).build();

        for (int i = 0; i < numberOfLeagues; i++) {
            League league = League.builder().tournament(tournament).isQualification(false).build();
            league.setRound(round);
            league.setTournament(tournament);
            league.setName("League " + (i + 1));
            leagues.add(league);
        }


        for (League league : leagues) {
            league.setTeams(new ArrayList<>());
        }

        int leagueIndex = 0;
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
            leagueIndex = (leagueIndex + 1) % leagues.size();
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
        return leagues;
    }
}