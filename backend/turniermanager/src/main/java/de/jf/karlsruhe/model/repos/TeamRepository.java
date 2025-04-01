package de.jf.karlsruhe.model.repos;

import de.jf.karlsruhe.model.base.Team;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.UUID;

@Repository
public interface TeamRepository extends JpaRepository<Team, UUID> {
    List<Team> findByAgeGroupId(UUID ageGroupId);
}
