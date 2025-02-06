package de.jf.karlsruhe.model.repos;

import org.springframework.data.jpa.repository.JpaRepository;

import de.jf.karlsruhe.model.base.Pitch;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface PitchRepository extends JpaRepository<Pitch, Long>{
    @Query("SELECT p FROM Pitch p JOIN p.ageGroups g WHERE g.id = :ageGroupId")
    List<Pitch> findByAgeGroupId(@Param("ageGroupId") Long ageGroupId);

}
