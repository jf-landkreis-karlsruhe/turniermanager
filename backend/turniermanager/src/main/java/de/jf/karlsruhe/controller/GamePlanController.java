package de.jf.karlsruhe.controller;

import de.jf.karlsruhe.model.base.AgeGroup;
import de.jf.karlsruhe.model.base.Game;
import de.jf.karlsruhe.model.base.League;
import de.jf.karlsruhe.model.base.Round;
import de.jf.karlsruhe.model.repos.AgeGroupRepository;
import de.jf.karlsruhe.model.repos.RoundRepository;
import lombok.AllArgsConstructor;
import lombok.Data;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@RestController("/gameplan")
public class GamePlanController {

    @Autowired
    private RoundRepository roundRepository;

    @Autowired
    private AgeGroupRepository ageGroupRepository;

    @Transactional
    @GetMapping("/agegroup/{ageGroupId}")
    public ResponseEntity<GamePlan> getGamePlanByAgeGroup(@PathVariable UUID ageGroupId) {
        Optional<AgeGroup> ageGroupOptional = ageGroupRepository.findById(ageGroupId);
        if (ageGroupOptional.isPresent()) {
            AgeGroup ageGroup = ageGroupOptional.get();
            List<Round> roundOptional = roundRepository.findByAgeGroup(ageGroup);
            if (!roundOptional.isEmpty()) {
                List<Round> list = roundOptional.stream().filter(Round::isActive).toList();
                GamePlan gamePlan = createGamePlan(list.getFirst());
                return ResponseEntity.ok(gamePlan);
            } else {
                return ResponseEntity.notFound().build();
            }
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @Transactional
    protected GamePlan createGamePlan(Round round) {
        GamePlan gamePlan = new GamePlan();
        List<LeagueSchedule> leagueSchedules = new ArrayList<>();

        for (League league : round.getLeagues()) {
            LeagueSchedule leagueSchedule = new LeagueSchedule();
            leagueSchedule.setLeagueName(league.getName());

            List<GamePlanEntry> entries = league.getRound().getGames().stream()
                    .filter(game -> league.getTeams().contains(game.getTeamA()) && league.getTeams().contains(game.getTeamB()))
                    .sorted(Comparator.comparing(Game::getStartTime))
                    .map(this::mapGameToGamePlanEntry)
                    .collect(Collectors.toList());

            leagueSchedule.setEntries(entries);
            leagueSchedules.add(leagueSchedule);
        }

        gamePlan.setLeagues(leagueSchedules);
        return gamePlan;
    }

    private GamePlanEntry mapGameToGamePlanEntry(Game game) {
        GamePlanEntry entry = new GamePlanEntry();
        entry.setPitchName(game.getPitch().getName());
        entry.setStartTime(game.getStartTime());
        entry.setTeamAName(game.getTeamA().getName());
        entry.setTeamBName(game.getTeamB().getName());
        return entry;
    }


    @Data
    public static class GamePlan {
        private List<LeagueSchedule> leagues;
    }

    @Data
    static class LeagueSchedule {
        private String leagueName;
        private List<GamePlanEntry> entries;

    }

    @Data
    static class GamePlanEntry {
        private String pitchName;
        private LocalDateTime startTime;
        private String teamAName;
        private String teamBName;
    }

}
