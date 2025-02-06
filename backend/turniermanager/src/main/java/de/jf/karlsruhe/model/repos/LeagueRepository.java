package de.jf.karlsruhe.model.repos;

import org.springframework.data.jpa.repository.JpaRepository;

import de.jf.karlsruhe.model.base.League;

import java.util.List;

public interface LeagueRepository extends JpaRepository<League, Long>{
        List<League> findByAgeGroupIdAndRoundId(Long ageGroupId, Long roundId);
}
