package de.jf.karlsruhe.model.repos;

import org.springframework.data.jpa.repository.JpaRepository;

import de.jf.karlsruhe.model.base.Pitch;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface PitchRepository extends JpaRepository<Pitch, Long>{
    @Query("SELECT p FROM Pitch p JOIN p.ageGroups g WHERE g.id = :ageGroupId")
    List<Pitch> findByAgeGroupId(@Param("ageGroupId") Long ageGroupId);

    @Query("SELECT p FROM Pitch p JOIN FETCH p.ageGroups WHERE p.id = :id")
    Optional<Pitch> findWithAgeGroupsById(@Param("id") Long id);

    @Query("SELECT DISTINCT p FROM Pitch p JOIN FETCH p.ageGroups")
    List<Pitch> findAllWithAgeGroups();

}
