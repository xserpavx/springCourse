package com.example.demo.repositories;

import com.example.demo.entity.Book;
import com.example.demo.entity.Tag;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.PagingAndSortingRepository;

import java.util.List;

public interface TagRepository extends JpaRepository<Tag, Integer> {
    @Query(value="select max(count) from (select count(id_book), tags.tag_name  from book2tag\n" +
            "left outer join tags on tags.id = book2tag.id_tag\n" +
            "group by tags.tag_name) sel", nativeQuery=true)
    int maxTagCount();

    Tag findTagById(Integer id);


}
