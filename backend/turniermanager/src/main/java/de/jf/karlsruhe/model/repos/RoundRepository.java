package de.jf.karlsruhe.model.repos;

import de.jf.karlsruhe.model.base.Round;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.UUID;

public interface RoundRepository extends JpaRepository<Round, UUID> {
    @Query("SELECT r FROM Round r JOIN FETCH r.leagues WHERE r.tournament.id = :tournamentId")
    List<Round> findAllRoundsByTournamentId(UUID tournamentId);
}
