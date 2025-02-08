package de.jf.karlsruhe.model.repos;

import org.springframework.data.jpa.repository.JpaRepository;

import de.jf.karlsruhe.model.base.League;

import java.util.List;
import java.util.UUID;

public interface LeagueRepository extends JpaRepository<League, UUID> {
}
