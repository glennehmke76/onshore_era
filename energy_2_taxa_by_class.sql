-- rename existing runs according to regionalisation and other factors where relevant - eg
-- archive existing range_in_region_by_classes as regional table...
  DROP TABLE IF EXISTS range_in_region_abi;
  DROP TABLE IF EXISTS range_in_region_by_classes_abi;

  ALTER TABLE IF EXISTS range_in_region_by_classes
      RENAME TO "range_in_region_by_classes_abi";
  ALTER TABLE "range_in_region_by_classes_abi"
      RENAME CONSTRAINT range_in_region_by_classes_pkey TO range_in_region_by_classes_abi_pkey;
  ALTER INDEX IF EXISTS idx_range_in_region_by_classes_taxon_id
      RENAME TO idx_range_in_region_by_classes_abi_taxon_id;
  ALTER INDEX IF EXISTS idx_range_in_region_by_classes_id
    RENAME TO idx_range_in_region_by_classes_abi_id;
  ALTER INDEX IF EXISTS idx_range_in_region_by_classes_range_id
      RENAME TO idx_range_in_region_by_classes_abi_range_id;
  ALTER INDEX IF EXISTS idx_range_in_region_by_classes_breeding_range_id
      RENAME TO idx_range_in_region_by_classes_abi_breeding_range_id;

-- archive existing range_in_region as regional table...
  ALTER TABLE IF EXISTS range_in_region
      RENAME TO "range_in_region_abi";
  ALTER TABLE "range_in_region_abi"
      RENAME CONSTRAINT range_in_region_pkey TO range_in_region_abi_pkey;
  ALTER INDEX IF EXISTS idx_range_in_region_taxon_id
      RENAME TO idx_range_in_region_abi_taxon_id;
  ALTER INDEX IF EXISTS idx_range_in_region_region_id
    RENAME TO idx_range_in_region_abi_region_id;

-- run times
  -- full run with simplified ABI regions; Query returned successfully in 4 min 24 secs.
  -- full run with simplified basins; Query returned successfully in 6 min 57 secs.
  -- full run with full basins; Query returned successfully in 27 min 48 secs.
  -- full run with full 100K states/territories; 1h 10min

-- make table of ranges in region by range and breeding range class
  -- simplified ABIs (~20K vertices) - Query returned successfully in 2 min 10 secs.
  DROP TABLE IF EXISTS range_in_region_by_classes;
  CREATE TABLE range_in_region_by_classes (
    region_id int NOT NULL,
    taxon_id varchar NOT NULL,
    range_id int NOT NULL,
    breeding_range_id int NOT NULL,
    range_type varchar NOT NULL,
    area int DEFAULT NULL
  );
  ALTER TABLE IF EXISTS range_in_region_by_classes
    ADD CONSTRAINT range_in_region_by_classes_pkey
    PRIMARY KEY (region_id, taxon_id, range_id, breeding_range_id);
  CREATE INDEX IF NOT EXISTS idx_range_in_region_by_classes_id
  ON range_in_region_by_classes (region_id);
  CREATE INDEX IF NOT EXISTS idx_range_in_region_by_classes_taxon_id
  ON range_in_region_by_classes (taxon_id);
  CREATE INDEX IF NOT EXISTS idx_range_in_region_by_classes_range_id
  ON range_in_region_by_classes (range_id);
  CREATE INDEX IF NOT EXISTS idx_range_in_region_by_classes_breeding_range_id
  ON range_in_region_by_classes (breeding_range_id);

  -- calculate and populate area in region across range classes for
    -- continental ultrataxa xxK ABIs - 6,057 rows affected in 6 m 2 s 613 ms
    -- 100K vertex States/Territories ultrataxa 5,192 rows affected in 32 m 21 s 979 ms
    INSERT INTO range_in_region_by_classes (region_id, taxon_id, range_id, breeding_range_id, range_type, area)
    SELECT
      intersected.region_id,
      intersected.taxon_id,
      intersected.rnge,
      intersected.br_rnge,
      'continental' AS range_type,
      ST_Area(
        ST_Transform(
          ST_Union(intersected.geom), 3112)) / 10000 AS area
    FROM
        (SELECT
          tmp_region_continental.region_id,
          tmp_ranges_continental.taxon_id,
          tmp_ranges_continental.rnge,
          tmp_ranges_continental.br_rnge,
          ST_Intersection(tmp_ranges_continental.geom, tmp_region_continental.geom) AS geom
        FROM tmp_ranges_continental
        JOIN tmp_region_continental ON ST_Intersects(tmp_ranges_continental.geom, tmp_region_continental.geom)
        )intersected
    GROUP BY
      intersected.region_id,
      intersected.taxon_id,
      intersected.rnge,
      intersected.br_rnge
    ;

  -- calculate and populate area in region across range classes for
    -- coastal ultrataxa 597 rows affected in 2 m 2 s 152 ms
    -- 100K vertex States/Territories 555 rows affected in 1 m 55 s 193 ms
    INSERT INTO range_in_region_by_classes (region_id, taxon_id, range_id, breeding_range_id, range_type, area)
    SELECT
      intersected.region_id,
      intersected.taxon_id,
      intersected.rnge,
      intersected.br_rnge,
      'coastal' AS range_type,
      ST_Area(
        ST_Transform(
          ST_Union(intersected.geom), 3112)) / 10000 AS area
    FROM
        (SELECT
          tmp_region_coastal.region_id,
          tmp_ranges_coastal.taxon_id,
          tmp_ranges_coastal.rnge,
          tmp_ranges_coastal.br_rnge,
          ST_Intersection(tmp_ranges_coastal.geom, tmp_region_coastal.geom) AS geom
        FROM tmp_ranges_coastal
        JOIN tmp_region_coastal ON ST_Intersects(tmp_ranges_coastal.geom, tmp_region_coastal.geom)
        )intersected
    GROUP BY
      intersected.region_id,
      intersected.taxon_id,
      intersected.rnge,
      intersected.br_rnge
    ;

  -- calculate and populate area in region across range classes for
    -- continental polytypic species 7 m 35 s 479 ms
    -- 100K vertex States/Territories 4,577 rows affected in 34 m 39 s 625 ms
    INSERT INTO range_in_region_by_classes (region_id, taxon_id, range_id, breeding_range_id, range_type, area)
    SELECT
      intersected.region_id,
      intersected.taxon_id,
      intersected.rnge,
      intersected.br_rnge,
      'continental' AS range_type,
      ST_Area(
        ST_Transform(
          ST_Union(intersected.geom), 3112)) / 10000 AS area
    FROM
        (SELECT
          tmp_region_continental.region_id,
          tmp_ranges_continental_sp.taxon_id,
          tmp_ranges_continental_sp.rnge,
          tmp_ranges_continental_sp.br_rnge,
          ST_Intersection(tmp_ranges_continental_sp.geom, tmp_region_continental.geom) AS geom
        FROM tmp_ranges_continental_sp
        JOIN tmp_region_continental ON ST_Intersects(tmp_ranges_continental_sp.geom, tmp_region_continental.geom)
        )intersected
    GROUP BY
      intersected.region_id,
      intersected.taxon_id,
      intersected.rnge,
      intersected.br_rnge
    ;

  -- calculate and populate area in region across range classes for
    -- coastal polytypic species 584 rows affected in 1 m 47 s 985 ms
    -- 100K vertex States/Territories 527 rows affected in 1 m 52 s 408 ms
    INSERT INTO range_in_region_by_classes (region_id, taxon_id, range_id, breeding_range_id, range_type, area)
    SELECT
      intersected.region_id,
      intersected.taxon_id,
      intersected.rnge,
      intersected.br_rnge,
      'coastal' AS range_type,
      ST_Area(
        ST_Transform(
          ST_Union(intersected.geom), 3112)) / 10000 AS area
    FROM
        (SELECT
          tmp_region_coastal.region_id,
          tmp_ranges_coastal_sp.taxon_id,
          tmp_ranges_coastal_sp.rnge,
          tmp_ranges_coastal_sp.br_rnge,
          ST_Intersection(tmp_ranges_coastal_sp.geom, tmp_region_coastal.geom) AS geom
        FROM tmp_ranges_coastal_sp
        JOIN tmp_region_coastal ON ST_Intersects(tmp_ranges_coastal_sp.geom, tmp_region_coastal.geom)
        WHERE
          tmp_ranges_coastal_sp.taxon_id NOT LIKE 'u138%' -- to exclude species that have different range types across subspcecies
        )intersected
    GROUP BY
      intersected.region_id,
      intersected.taxon_id,
      intersected.rnge,
      intersected.br_rnge
    ;