package com.example.repository;

import com.example.model.Product;
import com.google.cloud.spring.data.spanner.repository.SpannerRepository;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;

@RepositoryRestResource(collectionResourceRel = "products", path = "products")
public interface ProductRepository extends SpannerRepository<Product, String> {
}
