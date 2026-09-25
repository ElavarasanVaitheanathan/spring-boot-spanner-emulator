package com.example.repository;

import com.example.model.User;
import com.google.cloud.spring.data.spanner.repository.SpannerRepository;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;

@RepositoryRestResource(collectionResourceRel = "users", path = "users")
public interface UserRepository extends SpannerRepository<User, String> {
}
