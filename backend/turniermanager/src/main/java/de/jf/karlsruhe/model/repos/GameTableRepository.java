package de.jf.karlsruhe.model.repos;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import de.jf.karlsruhe.model.game.GameTable;

@Repository
public interface GameTableRepository extends JpaRepository<GameTable, Long>{
	
}
