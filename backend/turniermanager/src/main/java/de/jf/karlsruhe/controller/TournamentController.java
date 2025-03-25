package de.jf.karlsruhe.controller;

import de.jf.karlsruhe.model.base.*;
import de.jf.karlsruhe.model.repos.*;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@CrossOrigin(origins = "*")
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
    private final GameSettingsRepository gameSettingsRepository;


    @PostMapping("/create")
    public Tournament createTournament(@RequestParam String name,
                                       @RequestParam LocalDateTime startTime,
                                       @RequestParam int playTime,
                                       @RequestParam int breakTime) {
        Tournament tournament;
        if (tournamentRepository.count() == 0) {

            GameSettings gameSettings = GameSettings.builder()
                    .startTime(startTime)
                    .playTime(playTime)
                    .breakTime(breakTime)
                    .build();

            tournament = Tournament.builder()
                    .name(name)
                    .gameSettings(gameSettings)
                    .build();

            List<Pitch> pitches = pitchRepository.findAll();
            pitchScheduler.initialize(pitches, gameSettings);
            tournamentRepository.save(tournament);
        } else {
            GameSettings gameSettings = gameSettingsRepository.findAll().getFirst();
            tournament = tournamentRepository.findAll().getFirst();
            List<Pitch> pitches = pitchRepository.findAll();
            pitchScheduler.initialize(pitches, gameSettings);
            tournamentRepository.save(tournament);
        }
        return tournament;
    }

    @Transactional
    @PostMapping("/create/qualification")
    public Tournament createQualificationTournament() {
        if (ageGroupRepository.count() == 0 && pitchRepository.count() == 0 && teamRepository.count() == 0)
            return tournamentRepository.findAll().getFirst();

        Tournament tournament = tournamentRepository.findAll().getFirst();
        List<AgeGroup> ageGroups = ageGroupRepository.findAll();
        List<Game> allGamesToSchedule = new ArrayList<>(); // Zwischenspeicher für alle Spiele

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

            List<Game> games = generateLeagueGames(league);
            allGamesToSchedule.addAll(games); // Spiele zum Zwischenspeicher hinzufügen
            league.getRound().addGames(games);
        }
        //Collections.shuffle(allGamesToSchedule);
        List<Game> scheduledGames = setGameTags(pitchScheduler.scheduleGames(allGamesToSchedule));
        gameRepository.saveAll(scheduledGames);

        // Hier werden alle Spiele, Ligen und Runden in einem einzigen Transaktionsblock gespeichert
        roundRepository.flush();
        gameRepository.flush();

        return tournament;
    }

    @Transactional
    @PostMapping("/create/round")
    public Tournament createTournamentRound(@RequestParam int maxTeamsPerLeague) {
        clearScheduledPitches();
        if (ageGroupRepository.count() == 0 && pitchRepository.count() == 0 && teamRepository.count() == 0)
            return tournamentRepository.findAll().getFirst();
        List<Round> all = roundRepository.findAll();
        all.forEach(round -> {
            round.setActive(false);
        });

        Tournament tournament = tournamentRepository.findAll().getFirst();
        List<AgeGroup> ageGroups = new ArrayList<>(ageGroupRepository.findAll()); // Erstelle eine Kopie, um die Originaldaten nicht zu verändern
        Collections.shuffle(ageGroups); // Zufällige Reihenfolge der Altersgruppen

        List<Game> allGamesToSchedule = new ArrayList<>(); // Zwischenspeicher für alle Spiele
        List<League> allLeagues = new ArrayList<>();
        List<Round> allRounds = new ArrayList<>();

        for (AgeGroup ageGroup : ageGroups) {
            List<Team> teams = teamRepository.findByAgeGroupId(ageGroup.getId());
            List<Game> allGames = gameRepository.findAll();
            List<Team> sortedTeams = !allGames.isEmpty() ? getTeamsSortedByPerformance(allGames, teams) : teams;

            List<League> leagues = createBalancedLeaguesForAgeGroup(sortedTeams, maxTeamsPerLeague, "Turnier", tournament);

            // Erstelle eine Kopie der League-Liste
            List<League> leaguesCopy = new ArrayList<>(leagues);

            leaguesCopy.forEach(league -> {
                league.setAgeGroup(ageGroup);

                List<Game> games = generateLeagueGames(league);
                Collections.shuffle(games); // Zufällige Reihenfolge der Spiele innerhalb der Altersgruppe
                allGamesToSchedule.addAll(games); // Spiele zum Zwischenspeicher hinzufügen
                league.getRound().addGames(games);
                allLeagues.add(league);
                allRounds.add(league.getRound());
            });
        }

        Map<League, Integer> gameCountPerLeague = getGameCountPerLeague(allGamesToSchedule);
        int maxGamesPlayed = gameCountPerLeague.values().stream().max(Integer::compareTo).orElse(0);

        for (Round round : allRounds) {
            if (round.getGames().size() < maxGamesPlayed) {
                int difference = maxGamesPlayed - round.getGames().size();
                allGamesToSchedule.addAll(distributeGamesEvenly(round, gameCountPerLeague, difference));

            }
        }


        Collections.shuffle(allGamesToSchedule); // Zufällige Reihenfolge aller Spiele.
        List<Game> scheduledGames = setGameTags(pitchScheduler.scheduleGames(allGamesToSchedule));
        gameRepository.saveAll(scheduledGames);

        roundRepository.saveAll(allRounds);
        leagueRepository.saveAll(allLeagues);

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
    public void addBreakViaApi(@RequestBody BreakRequest breakRequest) {
        pitchScheduler.delayGamesAfter(breakRequest.getBreakTime(), breakRequest.getDuration());

    }

    @PostMapping("/advanceAfter")
    public void advanceGamesAfterViaApi(@RequestBody BreakRequest breakRequest) {
        pitchScheduler.advanceGamesAfter(breakRequest.getBreakTime(), breakRequest.getDuration());
    }

    @PostMapping("/shiftBetweenForward")
    public void shiftGamesBetweenForwardViaApi(@RequestBody ShiftRequest shiftrequest) {
        pitchScheduler.shiftGamesBetweenForward(shiftrequest.getBreakTime(), shiftrequest.getEndTime(), shiftrequest.getDuration());
    }

    @PostMapping("/shiftBetweenBackward")
    public void shiftGamesBetweenBackwardViaApi(@RequestBody ShiftRequest shiftrequest) {
        pitchScheduler.shiftGamesBetweenBackward(shiftrequest.getBreakTime(), shiftrequest.getEndTime(), shiftrequest.getDuration());
    }

    @DeleteMapping("/reset")
    public Tournament resetTournament() {
        leagueRepository.deleteAll();
        teamRepository.deleteAll();
        ageGroupRepository.deleteAll();
        tournamentRepository.deleteAll();
        return null;
    }

    @DeleteMapping("clear-scheduled-pitches")
    public void clearScheduledPitches() {
        this.pitchScheduler.reset();
    }

    @Transactional
    @PostMapping("/add/{leagueId}/{additionalGamesNeeded}")
    public ResponseEntity<String> addGamesManually(
            @PathVariable("leagueId") UUID leagueId,
            @PathVariable("additionalGamesNeeded") int additionalGamesNeeded) {

        Optional<League> optionalLeague = leagueRepository.findById(leagueId);

        if (optionalLeague.isPresent()) {
            League league = optionalLeague.get();
            List<Game> additionalGames = generateAdditionalGames(league, additionalGamesNeeded);
            List<Game> scheduledAdditionalGames = setGameTags(pitchScheduler.scheduleGames(additionalGames));
            gameRepository.saveAll(scheduledAdditionalGames);
            return ResponseEntity.ok().body("Added games manually");
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    // <------------------- Helper Methods --------------------->


    @Transactional
    public synchronized List<Game> setGameTags(List<Game> games) {
        long maxGameNumber = gameRepository.findAll().stream().map(Game::getGameNumber).max(Long::compareTo).orElse(0L);

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
                        .league(league)
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

        Map<Team, Float> teamPointsMap = new HashMap<>();

        for (Team team : teams) {
            int totalPoints = 0;
            int gamesPlayed = 0;
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
                    gamesPlayed++;
                }
            }
            float avgPoints = (float) totalPoints / (float) gamesPlayed;
            teamPointsMap.put(team, avgPoints);
        }

        return teams.stream()
                .sorted((t1, t2) -> Float.compare(teamPointsMap.get(t2), teamPointsMap.get(t1)))
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

    public Map<League, Integer> getGameCountPerLeague(List<Game> games) {
        Map<League, Integer> gameCountPerLeague = new HashMap<>();

        if (games != null) {
            for (Game game : games) {
                League league = game.getLeague();
                if (league != null) {
                    gameCountPerLeague.merge(league, 1, Integer::sum);
                }
            }
        }

        return gameCountPerLeague;
    }

    public static List<Game> distributeGamesEvenly(Round round, Map<League, Integer> gameCountPerLeague, int difference) {
        List<Game> gamesToSchedule = new ArrayList<>();
        List<League> leagues = round.getLeagues();

        if (leagues == null || leagues.isEmpty() || difference <= 0) {
            return gamesToSchedule;
        }

        // Sortiere Ligen nach Anzahl der bereits gespielten Spiele (aufsteigend)
        List<League> sortedLeagues = leagues.stream()
                .sorted(Comparator.comparingInt(league -> gameCountPerLeague.getOrDefault(league, 0)))
                .collect(Collectors.toList());

        int leagueIndex = 0;
        int gamesDistributed = 0; // Zähler für verteilte Spiele

        while (gamesDistributed < difference) {
            League currentLeague = sortedLeagues.get(leagueIndex);
            int gamesNeededForCurrentLeague = 1; // Füge 1 Spiel pro Liga hinzu

            // Wenn noch mehr Spiele benötigt werden, berechne die Anzahl
            if (difference - gamesDistributed > sortedLeagues.size() - leagueIndex) {
                gamesNeededForCurrentLeague = Math.min(difference - gamesDistributed, (difference - gamesDistributed) / (sortedLeagues.size() - leagueIndex));
            }

            List<Game> additionalGames = generateAdditionalGames(currentLeague, gamesNeededForCurrentLeague);
            gamesToSchedule.addAll(additionalGames);

            gameCountPerLeague.merge(currentLeague, additionalGames.size(), Integer::sum); // Aktualisiere die Spielanzahl
            gamesDistributed += additionalGames.size(); // Aktualisiere den Zähler

            leagueIndex = (leagueIndex + 1) % sortedLeagues.size(); // Wechsle zur nächsten Liga
        }

        return gamesToSchedule;
    }

    private static List<Game> generateAdditionalGames(League league, int additionalGamesNeeded) {
        List<Game> additionalGames = new ArrayList<>();
        List<Team> teams = league.getTeams();
        java.util.Random random = new java.util.Random();

        for (int i = 0; i < additionalGamesNeeded; i++) {
            de.jf.karlsruhe.model.base.Team teamA = teams.get(random.nextInt(teams.size()));
            de.jf.karlsruhe.model.base.Team teamB = teams.get(random.nextInt(teams.size()));

            // Stelle sicher, dass teamA und teamB nicht dasselbe Team sind
            while (teamA.equals(teamB)) {
                teamB = teams.get(random.nextInt(teams.size()));
            }

            Game game = new Game();
            game.setLeague(league);
            game.setTeamA(teamA);
            game.setTeamB(teamB);
            game.setRound(league.getRound());
            game.setGameNumber(0); // Setze die Spielnummer auf 0 oder einen anderen Wert, um anzuzeigen, dass es sich um ein zusätzliches Spiel handelt
            additionalGames.add(game);
        }

        return additionalGames;
    }


    @Data
    public static class BreakRequest {
        private LocalDateTime breakTime;
        private int duration;
    }

    @Data
    public static class ShiftRequest {
        private LocalDateTime breakTime;
        private LocalDateTime endTime;
        private int duration;
    }


}