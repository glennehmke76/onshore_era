-- perm 2
  -- core + iurruptive + introduced + vagrant x all breeding ranges
  -- FRs _1 > _2, rnge = 1 > rnge = 1 OR range_id = 3 OR rnge = 6, range_id = 1 > range_id = 1 OR range_id = 3 OR range_id = 6 [whole word]
  
  -- add perm fields
    ALTER TABLE IF EXISTS range_in_region DROP COLUMN IF EXISTS sp_rep_2;
    ALTER TABLE IF EXISTS range_in_region DROP COLUMN IF EXISTS sp_endem_2;
    ALTER TABLE IF EXISTS range_in_region DROP COLUMN IF EXISTS sp_rep_2br;
    ALTER TABLE IF EXISTS range_in_region DROP COLUMN IF EXISTS sp_endem_2br;
    ALTER TABLE IF EXISTS range_in_region DROP COLUMN IF EXISTS sp_rep_2nb;
    ALTER TABLE IF EXISTS range_in_region DROP COLUMN IF EXISTS sp_endem_2nb;

    ALTER TABLE IF EXISTS range_in_region
      ADD COLUMN sp_rep_2 numeric,
      ADD COLUMN sp_endem_2 numeric,
      ADD COLUMN sp_rep_2br numeric,
      ADD COLUMN sp_endem_2br numeric,
      ADD COLUMN sp_rep_2nb numeric,
      ADD COLUMN sp_endem_2nb numeric
    ;

-- do sp_rep across breeding range classes for ultrataxa
  -- continental
    -- do ultrataxa
      -- all breeding ranges
      UPDATE range_in_region
      SET sp_rep_2 = sub.area / tmp_region_continental.area * 100
      FROM
          (SELECT
            region_id,
            taxon_id,
            SUM(area) AS area
          FROM range_in_region_by_classes
          WHERE
            range_type = 'continental'
            AND taxon_id LIKE 'u%'
            AND
              (range_id = 1 OR range_id = 3 OR range_id = 6
              OR range_id = 5)
          GROUP BY
            region_id,
            taxon_id
          )sub, tmp_region_continental
      WHERE
        sub.region_id = range_in_region.region_id
        AND sub.taxon_id = range_in_region.taxon_id
        AND tmp_region_continental.region_id = sub.region_id
      ;

      -- breeding range
      UPDATE range_in_region
      SET sp_rep_2br = sub.area / tmp_region_continental.area * 100
      FROM
          (SELECT
            region_id,
            taxon_id,
            SUM(area) AS area
          FROM range_in_region_by_classes
          WHERE
            range_type = 'continental'
            AND taxon_id LIKE 'u%'
            AND
              (range_id = 1 OR range_id = 3 OR range_id = 6
              OR range_id = 5)
            AND
              breeding_range_id = 1
          GROUP BY
            region_id,
            taxon_id
          )sub, tmp_region_continental
      WHERE
        sub.region_id = range_in_region.region_id
        AND sub.taxon_id = range_in_region.taxon_id
        AND tmp_region_continental.region_id = sub.region_id
      ;

      -- non-breeding range
      UPDATE range_in_region
      SET sp_rep_2nb = sub.area / tmp_region_continental.area * 100
      FROM
          (SELECT
            region_id,
            taxon_id,
            SUM(area) AS area
          FROM range_in_region_by_classes
          WHERE
            range_type = 'continental'
            AND taxon_id LIKE 'u%'
            AND
              (range_id = 1 OR range_id = 3 OR range_id = 6
              OR range_id = 5)
            AND
              breeding_range_id = 2
          GROUP BY
            region_id,
            taxon_id
          )sub, tmp_region_continental
      WHERE
        sub.region_id = range_in_region.region_id
        AND sub.taxon_id = range_in_region.taxon_id
        AND tmp_region_continental.region_id = sub.region_id
      ;

    -- do polytypic species
      -- all breeding ranges
      UPDATE range_in_region
      SET sp_rep_2 = sub.area / tmp_region_continental.area * 100
      FROM
          (SELECT
            region_id,
            taxon_id,
            SUM(area) AS area
          FROM range_in_region_by_classes
          WHERE
            range_type = 'continental'
            AND taxon_id NOT LIKE 'u%'
            AND
              (range_id = 1 OR range_id = 3 OR range_id = 6
              OR range_id = 5)
          GROUP BY
            region_id,
            taxon_id
          )sub, tmp_region_continental
      WHERE
        sub.region_id = range_in_region.region_id
        AND sub.taxon_id = range_in_region.taxon_id
        AND tmp_region_continental.region_id = sub.region_id
      ;

      -- breeding range
      UPDATE range_in_region
      SET sp_rep_2br = sub.area / tmp_region_continental.area * 100
      FROM
          (SELECT
            region_id,
            taxon_id,
            SUM(area) AS area
          FROM range_in_region_by_classes
          WHERE
            range_type = 'continental'
            AND taxon_id NOT LIKE 'u%'
            AND
              (range_id = 1 OR range_id = 3 OR range_id = 6
              OR range_id = 5)
            AND
              breeding_range_id = 1
          GROUP BY
            region_id,
            taxon_id
          )sub, tmp_region_continental
      WHERE
        sub.region_id = range_in_region.region_id
        AND sub.taxon_id = range_in_region.taxon_id
        AND tmp_region_continental.region_id = sub.region_id
      ;

      -- non-breeding range
      UPDATE range_in_region
      SET sp_rep_2nb = sub.area / tmp_region_continental.area * 100
      FROM
          (SELECT
            region_id,
            taxon_id,
            SUM(area) AS area
          FROM range_in_region_by_classes
          WHERE
            range_type = 'continental'
            AND taxon_id NOT LIKE 'u%'
            AND
              (range_id = 1 OR range_id = 3 OR range_id = 6
              OR range_id = 5)
            AND
              breeding_range_id = 2
          GROUP BY
            region_id,
            taxon_id
          )sub, tmp_region_continental
      WHERE
        sub.region_id = range_in_region.region_id
        AND sub.taxon_id = range_in_region.taxon_id
        AND tmp_region_continental.region_id = sub.region_id
      ;

  -- coastal
    -- do ultrataxa
      -- all breeding ranges
      UPDATE range_in_region
      SET sp_rep_2 = sub.area / tmp_region_coastal.area * 100
      FROM
          (SELECT
            region_id,
            taxon_id,
            SUM(area) AS area
          FROM range_in_region_by_classes
          WHERE
            range_type = 'coastal'
            AND taxon_id LIKE 'u%'
            AND
              (range_id = 1 OR range_id = 3 OR range_id = 6
              OR range_id = 5)
          GROUP BY
            region_id,
            taxon_id
          )sub, tmp_region_coastal
      WHERE
        sub.region_id = range_in_region.region_id
        AND sub.taxon_id = range_in_region.taxon_id
        AND tmp_region_coastal.region_id = sub.region_id
      ;

      -- breeding range
      UPDATE range_in_region
      SET sp_rep_2br = sub.area / tmp_region_coastal.area * 100
      FROM
          (SELECT
            region_id,
            taxon_id,
            SUM(area) AS area
          FROM range_in_region_by_classes
          WHERE
            range_type = 'coastal'
            AND taxon_id LIKE 'u%'
            AND
              (range_id = 1 OR range_id = 3 OR range_id = 6
              OR range_id = 5)
            AND
              breeding_range_id = 1
          GROUP BY
            region_id,
            taxon_id
          )sub, tmp_region_coastal
      WHERE
        sub.region_id = range_in_region.region_id
        AND sub.taxon_id = range_in_region.taxon_id
        AND tmp_region_coastal.region_id = sub.region_id
      ;

      -- non-breeding range
      UPDATE range_in_region
      SET sp_rep_2nb = sub.area / tmp_region_coastal.area * 100
      FROM
          (SELECT
            region_id,
            taxon_id,
            SUM(area) AS area
          FROM range_in_region_by_classes
          WHERE
            range_type = 'coastal'
            AND taxon_id LIKE 'u%'
            AND
              (range_id = 1 OR range_id = 3 OR range_id = 6
              OR range_id = 5)
            AND
              breeding_range_id = 2
          GROUP BY
            region_id,
            taxon_id
          )sub, tmp_region_coastal
      WHERE
        sub.region_id = range_in_region.region_id
        AND sub.taxon_id = range_in_region.taxon_id
        AND tmp_region_coastal.region_id = sub.region_id
      ;

    -- do polytypic species
      -- all breeding ranges
      UPDATE range_in_region
      SET sp_rep_2 = sub.area / tmp_region_coastal.area * 100
      FROM
          (SELECT
            region_id,
            taxon_id,
            SUM(area) AS area
          FROM range_in_region_by_classes
          WHERE
            range_type = 'coastal'
            AND taxon_id NOT LIKE 'u%'
            AND
              (range_id = 1 OR range_id = 3 OR range_id = 6
              OR range_id = 5)
          GROUP BY
            region_id,
            taxon_id
          )sub, tmp_region_coastal
      WHERE
        sub.region_id = range_in_region.region_id
        AND sub.taxon_id = range_in_region.taxon_id
        AND tmp_region_coastal.region_id = sub.region_id
      ;

      -- breeding range
      UPDATE range_in_region
      SET sp_rep_2br = sub.area / tmp_region_coastal.area * 100
      FROM
          (SELECT
            region_id,
            taxon_id,
            SUM(area) AS area
          FROM range_in_region_by_classes
          WHERE
            range_type = 'coastal'
            AND taxon_id NOT LIKE 'u%'
            AND
              (range_id = 1 OR range_id = 3 OR range_id = 6
              OR range_id = 5)
            AND
              breeding_range_id = 1
          GROUP BY
            region_id,
            taxon_id
          )sub, tmp_region_coastal
      WHERE
        sub.region_id = range_in_region.region_id
        AND sub.taxon_id = range_in_region.taxon_id
        AND tmp_region_coastal.region_id = sub.region_id
      ;

      -- non-breeding range
      UPDATE range_in_region
      SET sp_rep_2nb = sub.area / tmp_region_coastal.area * 100
      FROM
          (SELECT
            region_id,
            taxon_id,
            SUM(area) AS area
          FROM range_in_region_by_classes
          WHERE
            range_type = 'coastal'
            AND taxon_id NOT LIKE 'u%'
            AND
              (range_id = 1 OR range_id = 3 OR range_id = 6
              OR range_id = 5)
            AND
              breeding_range_id = 2
          GROUP BY
            region_id,
            taxon_id
          )sub, tmp_region_coastal
      WHERE
        sub.region_id = range_in_region.region_id
        AND sub.taxon_id = range_in_region.taxon_id
        AND tmp_region_coastal.region_id = sub.region_id
      ;

-- do sp_endem across breeding range classes for ultrataxa
  -- continental
    -- do ultrataxa
      -- all breeding ranges
      with sub AS
        (SELECT
            region_id,
            taxon_id,
            SUM(area) AS area
          FROM range_in_region_by_classes
          WHERE
            range_type = 'continental'
            AND taxon_id LIKE 'u%'
            AND
              (range_id = 1 OR range_id = 3 OR range_id = 6
              OR range_id = 5)
          GROUP BY
            region_id,
            taxon_id
        )
      UPDATE range_in_region
      SET sp_endem_2 = sub.area / tmp_ranges_continental.area * 100
      FROM
          (SELECT
            taxon_id,
            SUM(area) AS area
          FROM tmp_ranges_continental
          WHERE
              (rnge = 1 OR rnge = 3 OR rnge = 6
              OR rnge = 5)
          GROUP BY
            taxon_id
          )tmp_ranges_continental, sub
      WHERE
        sub.region_id = range_in_region.region_id
        AND sub.taxon_id = range_in_region.taxon_id
        AND tmp_ranges_continental.taxon_id = range_in_region.taxon_id
      ;

      -- breeding only range
      with sub AS
        (SELECT
            region_id,
            taxon_id,
            SUM(area) AS area
          FROM range_in_region_by_classes
          WHERE
            range_type = 'continental'
            AND taxon_id LIKE 'u%'
            AND
              (range_id = 1 OR range_id = 3 OR range_id = 6
              OR range_id = 5)
            AND
              breeding_range_id = 1
          GROUP BY
            region_id,
            taxon_id
        )
      UPDATE range_in_region
      SET sp_endem_2br = sub.area / tmp_ranges_continental.area * 100
      FROM
          (SELECT
            taxon_id,
            SUM(area) AS area
          FROM tmp_ranges_continental
          WHERE
              (rnge = 1 OR rnge = 3 OR rnge = 6
              OR rnge = 5)
            AND
              br_rnge = 1
          GROUP BY
            taxon_id
          )tmp_ranges_continental, sub
      WHERE
        sub.region_id = range_in_region.region_id
        AND sub.taxon_id = range_in_region.taxon_id
        AND tmp_ranges_continental.taxon_id = range_in_region.taxon_id
      ;

      -- non-breeding only range
      with sub AS
        (SELECT
            region_id,
            taxon_id,
            SUM(area) AS area
          FROM range_in_region_by_classes
          WHERE
            range_type = 'continental'
            AND taxon_id LIKE 'u%'
            AND
              (range_id = 1 OR range_id = 3 OR range_id = 6
              OR range_id = 5)
            AND
              breeding_range_id = 2
          GROUP BY
            region_id,
            taxon_id
        )
      UPDATE range_in_region
      SET sp_endem_2nb = sub.area / tmp_ranges_continental.area * 100
      FROM
          (SELECT
            taxon_id,
            SUM(area) AS area
          FROM tmp_ranges_continental
          WHERE
              (rnge = 1 OR rnge = 3 OR rnge = 6
              OR rnge = 5)
            AND
              br_rnge = 2
          GROUP BY
            taxon_id
          )tmp_ranges_continental, sub
      WHERE
        sub.region_id = range_in_region.region_id
        AND sub.taxon_id = range_in_region.taxon_id
        AND tmp_ranges_continental.taxon_id = range_in_region.taxon_id
      ;

    -- do polytypic species
      -- all breeding ranges
      with sub AS
        (SELECT
            region_id,
            taxon_id,
            SUM(area) AS area
          FROM range_in_region_by_classes
          WHERE
            range_type = 'continental'
            AND taxon_id NOT LIKE 'u%'
            AND
              (range_id = 1 OR range_id = 3 OR range_id = 6
              OR range_id = 5)
          GROUP BY
            region_id,
            taxon_id
        )
      UPDATE range_in_region
      SET sp_endem_2 = sub.area / tmp_ranges_continental_sp.area * 100
      FROM
          (SELECT
            taxon_id,
            SUM(area) AS area
          FROM tmp_ranges_continental_sp
          WHERE
              (rnge = 1 OR rnge = 3 OR rnge = 6
              OR rnge = 5)
          GROUP BY
            taxon_id
          )tmp_ranges_continental_sp, sub
      WHERE
        sub.region_id = range_in_region.region_id
        AND sub.taxon_id = range_in_region.taxon_id
        AND tmp_ranges_continental_sp.taxon_id = range_in_region.taxon_id
      ;

      -- breeding only range
      with sub AS
        (SELECT
            region_id,
            taxon_id,
            SUM(area) AS area
          FROM range_in_region_by_classes
          WHERE
            range_type = 'continental'
            AND taxon_id NOT LIKE 'u%'
            AND
              (range_id = 1 OR range_id = 3 OR range_id = 6
              OR range_id = 5)
            AND
              breeding_range_id = 1
          GROUP BY
            region_id,
            taxon_id
        )
      UPDATE range_in_region
      SET sp_endem_2br = sub.area / tmp_ranges_continental_sp.area * 100
      FROM
          (SELECT
            taxon_id,
            SUM(area) AS area
          FROM tmp_ranges_continental_sp
          WHERE
              (rnge = 1 OR rnge = 3 OR rnge = 6
              OR rnge = 5)
            AND
              br_rnge = 1
          GROUP BY
            taxon_id
          )tmp_ranges_continental_sp, sub
      WHERE
        sub.region_id = range_in_region.region_id
        AND sub.taxon_id = range_in_region.taxon_id
        AND tmp_ranges_continental_sp.taxon_id = range_in_region.taxon_id
      ;

      -- non-breeding only range
      with sub AS
        (SELECT
            region_id,
            taxon_id,
            SUM(area) AS area
          FROM range_in_region_by_classes
          WHERE
            range_type = 'continental'
            AND taxon_id NOT LIKE 'u%'
            AND
              (range_id = 1 OR range_id = 3 OR range_id = 6
              OR range_id = 5)
            AND
              breeding_range_id = 2
          GROUP BY
            region_id,
            taxon_id
        )
      UPDATE range_in_region
      SET sp_endem_2nb = sub.area / tmp_ranges_continental_sp.area * 100
      FROM
          (SELECT
            taxon_id,
            SUM(area) AS area
          FROM tmp_ranges_continental_sp
          WHERE
              (rnge = 1 OR rnge = 3 OR rnge = 6
              OR rnge = 5)
            AND
              br_rnge = 2
          GROUP BY
            taxon_id
          )tmp_ranges_continental_sp, sub
      WHERE
        sub.region_id = range_in_region.region_id
        AND sub.taxon_id = range_in_region.taxon_id
        AND tmp_ranges_continental_sp.taxon_id = range_in_region.taxon_id
      ;

  -- coastal
    -- do ultrataxa
      -- all breeding ranges
        with sub AS
          (SELECT
              region_id,
              taxon_id,
              SUM(area) AS area
            FROM range_in_region_by_classes
            WHERE
              range_type = 'coastal'
              AND taxon_id LIKE 'u%'
              AND
                (range_id = 1 OR range_id = 3 OR range_id = 6
                OR range_id = 5)
            GROUP BY
              region_id,
              taxon_id
          )
        UPDATE range_in_region
        SET sp_endem_2 = sub.area / tmp_ranges_coastal.area * 100
        FROM
            (SELECT
              taxon_id,
              SUM(area) AS area
            FROM tmp_ranges_coastal
            WHERE
                (rnge = 1 OR rnge = 3 OR rnge = 6
                OR rnge = 5)
            GROUP BY
              taxon_id
            )tmp_ranges_coastal, sub
        WHERE
          sub.region_id = range_in_region.region_id
          AND sub.taxon_id = range_in_region.taxon_id
          AND tmp_ranges_coastal.taxon_id = range_in_region.taxon_id
        ;

      -- breeding only range
        with sub AS
          (SELECT
              region_id,
              taxon_id,
              SUM(area) AS area
            FROM range_in_region_by_classes
            WHERE
              range_type = 'coastal'
              AND taxon_id LIKE 'u%'
              AND
                (range_id = 1 OR range_id = 3 OR range_id = 6
                OR range_id = 5)
              AND
                breeding_range_id = 1
            GROUP BY
              region_id,
              taxon_id
          )
        UPDATE range_in_region
        SET sp_endem_2br = sub.area / tmp_ranges_coastal.area * 100
        FROM
            (SELECT
              taxon_id,
              SUM(area) AS area
            FROM tmp_ranges_coastal
            WHERE
                (rnge = 1 OR rnge = 3 OR rnge = 6
                OR rnge = 5)
              AND
                br_rnge = 1
            GROUP BY
              taxon_id
            )tmp_ranges_coastal, sub
        WHERE
          sub.region_id = range_in_region.region_id
          AND sub.taxon_id = range_in_region.taxon_id
          AND tmp_ranges_coastal.taxon_id = range_in_region.taxon_id
        ;

      -- non-breeding only range
        with sub AS
          (SELECT
              region_id,
              taxon_id,
              SUM(area) AS area
            FROM range_in_region_by_classes
            WHERE
              range_type = 'coastal'
              AND taxon_id LIKE 'u%'
              AND
                (range_id = 1 OR range_id = 3 OR range_id = 6
                OR range_id = 5)
              AND
                breeding_range_id = 2
            GROUP BY
              region_id,
              taxon_id
          )
        UPDATE range_in_region
        SET sp_endem_2nb = sub.area / tmp_ranges_coastal.area * 100
        FROM
            (SELECT
              taxon_id,
              SUM(area) AS area
            FROM tmp_ranges_coastal
            WHERE
                (rnge = 1 OR rnge = 3 OR rnge = 6
                OR rnge = 5)
              AND
                br_rnge = 2
            GROUP BY
              taxon_id
            )tmp_ranges_coastal, sub
        WHERE
          sub.region_id = range_in_region.region_id
          AND sub.taxon_id = range_in_region.taxon_id
          AND tmp_ranges_coastal.taxon_id = range_in_region.taxon_id
        ;

    -- do polytypic species
      -- all breeding ranges
        with sub AS
          (SELECT
              region_id,
              taxon_id,
              SUM(area) AS area
            FROM range_in_region_by_classes
            WHERE
              range_type = 'coastal'
              AND taxon_id NOT LIKE 'u%'
              AND
                (range_id = 1 OR range_id = 3 OR range_id = 6
                OR range_id = 5)
            GROUP BY
              region_id,
              taxon_id
          )
        UPDATE range_in_region
        SET sp_endem_2 = sub.area / tmp_ranges_coastal_sp.area * 100
        FROM
            (SELECT
              taxon_id,
              SUM(area) AS area
            FROM tmp_ranges_coastal_sp
            WHERE
                (rnge = 1 OR rnge = 3 OR rnge = 6
                OR rnge = 5)
            GROUP BY
              taxon_id
            )tmp_ranges_coastal_sp, sub
        WHERE
          sub.region_id = range_in_region.region_id
          AND sub.taxon_id = range_in_region.taxon_id
          AND tmp_ranges_coastal_sp.taxon_id = range_in_region.taxon_id
        ;

      -- breeding only range
        with sub AS
          (SELECT
              region_id,
              taxon_id,
              SUM(area) AS area
            FROM range_in_region_by_classes
            WHERE
              range_type = 'coastal'
              AND taxon_id NOT LIKE 'u%'
              AND
                (range_id = 1 OR range_id = 3 OR range_id = 6
                OR range_id = 5)
              AND
                breeding_range_id = 1
            GROUP BY
              region_id,
              taxon_id
          )
        UPDATE range_in_region
        SET sp_endem_2br = sub.area / tmp_ranges_coastal_sp.area * 100
        FROM
            (SELECT
              taxon_id,
              SUM(area) AS area
            FROM tmp_ranges_coastal_sp
            WHERE
                (rnge = 1 OR rnge = 3 OR rnge = 6
                OR rnge = 5)
              AND
                br_rnge = 1
            GROUP BY
              taxon_id
            )tmp_ranges_coastal_sp, sub
        WHERE
          sub.region_id = range_in_region.region_id
          AND sub.taxon_id = range_in_region.taxon_id
          AND tmp_ranges_coastal_sp.taxon_id = range_in_region.taxon_id
        ;

      -- non-breeding only range
        with sub AS
          (SELECT
              region_id,
              taxon_id,
              SUM(area) AS area
            FROM range_in_region_by_classes
            WHERE
              range_type = 'coastal'
              AND taxon_id NOT LIKE 'u%'
              AND
                (range_id = 1 OR range_id = 3 OR range_id = 6
                OR range_id = 5)
              AND
                breeding_range_id = 2
            GROUP BY
              region_id,
              taxon_id
          )
        UPDATE range_in_region
        SET sp_endem_2nb = sub.area / tmp_ranges_coastal_sp.area * 100
        FROM
            (SELECT
              taxon_id,
              SUM(area) AS area
            FROM tmp_ranges_coastal_sp
            WHERE
                (rnge = 1 OR rnge = 3 OR rnge = 6
                OR rnge = 5)
              AND
                br_rnge = 2
            GROUP BY
              taxon_id
            )tmp_ranges_coastal_sp, sub
        WHERE
          sub.region_id = range_in_region.region_id
          AND sub.taxon_id = range_in_region.taxon_id
          AND tmp_ranges_coastal_sp.taxon_id = range_in_region.taxon_id
        ;

-- add qualifier fields
    ALTER TABLE IF EXISTS range_in_region
        DROP COLUMN IF EXISTS qualifies_perm2_rep5_or_endem75;
    ALTER TABLE IF EXISTS range_in_region
        DROP COLUMN IF EXISTS qualifies_perm2_endem75_only;
    ALTER TABLE IF EXISTS range_in_region
        DROP COLUMN IF EXISTS qualifies_perm2_rep5_only;

    ALTER TABLE IF EXISTS range_in_region
        ADD COLUMN qualifies_perm2_rep5_or_endem75 numeric,
        ADD COLUMN qualifies_perm2_endem75_only numeric,
        ADD COLUMN qualifies_perm2_rep5_only numeric
    ;
    COMMENT ON COLUMN range_in_region.qualifies_perm2_rep5_or_endem75
        IS '>25% represented or >75% endemic from all classes';
    COMMENT ON COLUMN range_in_region.qualifies_perm2_endem75_only
        IS '<25% represented but >75% endemic from all classes';
    COMMENT ON COLUMN range_in_region.qualifies_perm2_rep5_only
        IS '>25% represented but <75% endemic from all classes';

    -- qualifies rep and endem
    UPDATE range_in_region
    SET qualifies_perm2_rep5_or_endem75 = 1
    WHERE
        sp_rep_1 >= 5
        OR sp_endem_1 >= 75
    ;
    -- qualifies endem only
    UPDATE range_in_region
    SET qualifies_perm2_endem75_only = 1
    WHERE
        sp_rep_1 <= 5
        AND sp_endem_1 >= 75
    ;
    -- qualifies rep only
    UPDATE range_in_region
    SET qualifies_perm2_rep5_only = 1
    WHERE
        sp_rep_1 >= 5
        AND sp_endem_1 <= 75
    ;
