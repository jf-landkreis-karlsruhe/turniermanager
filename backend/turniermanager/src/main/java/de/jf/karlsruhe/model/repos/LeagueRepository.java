package de.jf.karlsruhe.model.repos;

import org.springframework.data.jpa.repository.JpaRepository;

import de.jf.karlsruhe.model.base.League;

public interface LeagueRepository extends JpaRepository<League, Long>{

}
