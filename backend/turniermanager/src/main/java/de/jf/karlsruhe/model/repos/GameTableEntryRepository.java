package de.jf.karlsruhe.model.repos;

import org.springframework.data.jpa.repository.JpaRepository;

import de.jf.karlsruhe.model.game.TableEntry;

public interface GameTableEntryRepository extends JpaRepository<TableEntry, Long>{

}
