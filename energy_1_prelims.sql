-- prelims, specify factors here
  -- run with 20K ABIs ...
  -- run with 99K states/territories (region_states_simple) ...
  -- specify regionalisation here
    DROP TABLE IF EXISTS tmp_region_continental;
    -- CREATE TEMPORARY TABLE tmp_region_continental AS
    CREATE TABLE tmp_region_continental AS
      SELECT
        id AS region_id,
        name AS region_name,
        geom,
        ST_Area(ST_Transform(geom, 3112)) / 10000 AS area
      FROM region_abi_simple
    ;
    CREATE INDEX IF NOT EXISTS idx_tmp_region_continental_region_id
    ON tmp_region_continental (region_id);
    CREATE INDEX IF NOT EXISTS idx_tmp_region_continental_geom
      ON tmp_region_continental USING gist
      (geom)
      TABLESPACE pg_default;

    DROP TABLE IF EXISTS tmp_region_coastal;
    -- CREATE TEMPORARY TABLE tmp_region_coastal AS
    CREATE TABLE tmp_region_coastal AS
      SELECT
        clipped.region_id,
        clipped.region_name,
        clipped.geom AS geom,
        ST_Area(ST_Transform(clipped.geom, 3112)) / 10000 AS area
      FROM
          (SELECT
            tmp_region_continental.region_id,
            tmp_region_continental.region_name,
            ST_Intersection(ST_Transform(buffered.geom, 4283), tmp_region_continental.geom) AS geom
          FROM
              (SELECT
                ST_Union(buffered_sub.geom) AS geom
              FROM
                  (SELECT
                    ST_Buffer(
                      ST_Simplify(
                        ST_Transform(
                          region_continental_coast.geom, 3112), 200), 3000, 'quad_segs=2') AS geom
                  FROM region_continental_coast
                  )buffered_sub
              )buffered
          JOIN tmp_region_continental ON ST_Intersects(ST_Transform(buffered.geom, 4283), tmp_region_continental.geom)
          )clipped
    ;
    CREATE INDEX IF NOT EXISTS idx_tmp_region_coastal_region_id
    ON tmp_region_coastal (region_id);
    CREATE INDEX IF NOT EXISTS idx_tmp_region_coastal_geom
      ON tmp_region_coastal USING gist
      (geom)
      TABLESPACE pg_default;

  -- specify taxa here (default is all)
    -- xxK bains - 12 min 57 secs
    -- 960K vertex ABIs - Query returned successfully in 52 min 23 secs.
    -- 20K vertex simplified ABIs - Query returned successfully in 3 min 20 secs.
    -- 100K vertex States/Territories - 5m 3s
    DROP TABLE IF EXISTS tmp_ranges_continental;
    -- CREATE TEMPORARY TABLE tmp_ranges_continental AS
    CREATE TABLE tmp_ranges_continental AS
    SELECT
      dissolved.geom AS geom,
      dissolved.taxon_id,
      dissolved.rnge,
      dissolved.br_rnge,
      ST_Area(ST_Transform(dissolved.geom, 3112)) / 10000 AS area
    FROM
        -- dissolve geometries by taxon_id with snap to grid parameter to avoid topo errors
        (SELECT
          ST_Union(ST_Intersection(range.geom, tmp_region_continental.geom)) AS geom,
          wlab_range.taxon_id,
          range.rnge,
          range.br_rnge
        FROM range
        JOIN wlab_range ON range.taxon_id_r = wlab_range.taxon_id_r
        JOIN wlab_all ON wlab_range.taxon_id = wlab_all.taxon_id
        JOIN tmp_region_continental ON ST_Intersects(range.geom, tmp_region_continental.geom)
        WHERE
          wlab_all.coastal_range IS NULL
          AND wlab_all.population <> 'Vagrant'
--           AND wlab_all.t_order <> 'Procellariiformes'
--           AND wlab_all.bird_group <> 'Marine'
        GROUP BY
          wlab_range.taxon_id,
          range.rnge,
          range.br_rnge
        )dissolved
    ;
    CREATE INDEX IF NOT EXISTS idx_tmp_ranges_continental_taxon_id
    ON tmp_ranges_continental (taxon_id);
    CREATE INDEX IF NOT EXISTS idx_tmp_ranges_continental_range_id
    ON tmp_ranges_continental (rnge);
    CREATE INDEX IF NOT EXISTS idx_tmp_ranges_continental_breeding_range_id
    ON tmp_ranges_continental (br_rnge);
    ALTER TABLE IF EXISTS tmp_ranges_continental
    ADD CONSTRAINT tmp_ranges_continental_pkey
    PRIMARY KEY (taxon_id, rnge, br_rnge);

    -- 100K vertex States/Territories - 5m 21s
    DROP TABLE IF EXISTS tmp_ranges_continental_sp;
    -- CREATE TEMPORARY TABLE tmp_ranges_continental_sp AS
    CREATE TABLE tmp_ranges_continental_sp AS
      SELECT
        dissolved.geom AS geom,
        dissolved.sp_id :: varchar AS taxon_id,
        dissolved.rnge,
        dissolved.br_rnge,
        ST_Area(ST_Transform(dissolved.geom, 3112)) / 10000 AS area
      FROM
          -- dissolve geometries by sp_id with snap to grid parameter to avoid topo errors
          (SELECT
            ST_Union(ST_Intersection(range.geom, tmp_region_continental.geom)) AS geom,
            range.sp_id,
            range.rnge,
            range.br_rnge
          FROM range
          JOIN wlab_sp_all ON range.sp_id = wlab_sp_all.sp_id
          JOIN tmp_region_continental ON ST_Intersects(range.geom, tmp_region_continental.geom)
          WHERE
            wlab_sp_all.coastal_range IS NULL
            AND wlab_sp_all.population <> 'Vagrant'
--          AND wlab_all.t_order <> 'Procellariiformes'
--          AND wlab_all.bird_group <> 'Marine'
          GROUP BY
            range.sp_id,
            range.rnge,
            range.br_rnge
          )dissolved
    ;
    CREATE INDEX IF NOT EXISTS idx_tmp_ranges_continental_sp_taxon_id
    ON tmp_ranges_continental_sp (taxon_id);
    CREATE INDEX IF NOT EXISTS idx_tmp_ranges_continental_sp_range_id
    ON tmp_ranges_continental_sp (rnge);
    CREATE INDEX IF NOT EXISTS idx_tmp_ranges_continental_sp_breeding_range_id
    ON tmp_ranges_continental_sp (br_rnge);
    ALTER TABLE IF EXISTS tmp_ranges_continental_sp
    ADD CONSTRAINT tmp_ranges_continental_sp_pkey
    PRIMARY KEY (taxon_id, rnge, br_rnge);

    -- removed wlab_covariates join and predicate wlab_covariates.coastal_range IS NOT NULL because of some taxa not coming through - for now listed directly in predicate
    -- 100K vertex States/Territories 52 s 564 ms
    DROP TABLE IF EXISTS tmp_ranges_coastal;
    -- CREATE TEMPORARY TABLE tmp_ranges_coastal AS
    CREATE TABLE tmp_ranges_coastal AS
      SELECT
        dissolved.geom AS geom,
        dissolved.taxon_id,
        dissolved.rnge,
        dissolved.br_rnge,
        ST_Area(ST_Transform(dissolved.geom, 3112)) / 10000 AS area
      FROM
          -- dissolve geometries by taxon_id with snap to grid parameter to avoid topo errors
          (SELECT
            ST_Union(ST_Intersection(range.geom, tmp_region_coastal.geom)) AS geom,
            wlab_range.taxon_id,
            range.rnge,
            range.br_rnge
          FROM range
          JOIN wlab_range ON range.taxon_id_r = wlab_range.taxon_id_r
          JOIN wlab_all ON wlab_range.taxon_id = wlab_all.taxon_id
          JOIN tmp_region_coastal ON ST_Intersects(range.geom, tmp_region_coastal.geom)
          WHERE
            wlab_all.coastal_range IS NOT NULL
            AND wlab_all.population <> 'Vagrant'
--          AND wlab_all.t_order <> 'Procellariiformes'
--          AND wlab_all.bird_group <> 'Marine'
          GROUP BY
            wlab_range.taxon_id,
            range.rnge,
            range.br_rnge
          )dissolved
      ;
      CREATE INDEX IF NOT EXISTS idx_ranges_coastal_taxon_id
      ON tmp_ranges_coastal (taxon_id);
      CREATE INDEX IF NOT EXISTS idx_ranges_coastal_range_id
      ON tmp_ranges_coastal (rnge);
      CREATE INDEX IF NOT EXISTS idx_ranges_coastal_breeding_range_id
      ON tmp_ranges_coastal (br_rnge);
      ALTER TABLE IF EXISTS tmp_ranges_coastal
      ADD CONSTRAINT ranges_coastal_pkey
      PRIMARY KEY (taxon_id, rnge, br_rnge);

    -- 100K vertex States/Territories 53 s 751 ms
    DROP TABLE IF EXISTS tmp_ranges_coastal_sp;
    -- CREATE TEMPORARY TABLE tmp_ranges_coastal_sp AS
    CREATE TABLE tmp_ranges_coastal_sp AS
      SELECT
        dissolved.geom AS geom,
        dissolved.sp_id :: varchar AS taxon_id,
        dissolved.rnge,
        dissolved.br_rnge,
        ST_Area(ST_Transform(dissolved.geom, 3112)) / 10000 AS area
      FROM
          -- dissolve geometries by sp_id with snap to grid parameter to avoid topo errors
          (SELECT
            ST_Union(ST_Intersection(range.geom, tmp_region_coastal.geom)) AS geom,
            range.sp_id,
            range.rnge,
            range.br_rnge
          FROM range
          JOIN wlab_sp_all ON range.sp_id = wlab_sp_all.sp_id
          JOIN tmp_region_coastal ON ST_Intersects(range.geom, tmp_region_coastal.geom)
          WHERE
            wlab_sp_all.coastal_range IS NOT NULL
            AND wlab_sp_all.population <> 'Vagrant'
--          AND wlab_all.t_order <> 'Procellariiformes'
--          AND wlab_all.bird_group <> 'Marine'
          GROUP BY
            range.sp_id,
            range.rnge,
            range.br_rnge
          )dissolved
    ;
    CREATE INDEX IF NOT EXISTS idx_ranges_coastal_sp_taxon_id
    ON tmp_ranges_coastal_sp (taxon_id);
    CREATE INDEX IF NOT EXISTS idx_ranges_coastal_sp_range_id
    ON tmp_ranges_coastal_sp (rnge);
    CREATE INDEX IF NOT EXISTS idx_ranges_coastal_sp_breeding_range_id
    ON tmp_ranges_coastal_sp (br_rnge);
    ALTER TABLE IF EXISTS tmp_ranges_coastal_sp
    ADD CONSTRAINT ranges_coastal_sp_pkey
    PRIMARY KEY (taxon_id, rnge, br_rnge);