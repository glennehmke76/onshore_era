-- export
  -- any sp_rep or sp_endem values of 0 are due to rounding but are real just <0.01%
  -- there are a few representativeness values of > 100%.
-- ABI regions
  SELECT
    range_in_region.region_id,
    tmp_region_continental.region_name,
    wlab.taxon_sort,
    wlab.taxon_level,
    COALESCE(wlab.is_ultrataxon,0) AS is_ultrataxon,
    range_in_region.taxon_id,
    wlab.taxon_name,
    wlab.taxon_scientific_name,
    wlab.bird_group,
    range_in_region.range_type,
    COALESCE(ROUND(range_in_region.sp_rep_1 :: numeric, 2), 0) AS sp_rep_1,
    COALESCE(ROUND(range_in_region.sp_endem_1 :: numeric, 2), 0) AS sp_endem_1,
    COALESCE(ROUND(range_in_region.sp_rep_1br :: numeric, 2), 0) AS sp_rep_1br,
    COALESCE(ROUND(range_in_region.sp_endem_1br :: numeric, 2), 0) AS sp_endem_1br,
    COALESCE(ROUND(range_in_region.sp_rep_1nb :: numeric, 2), 0) AS sp_rep_1nb,
    COALESCE(ROUND(range_in_region.sp_endem_1nb :: numeric, 2), 0) AS sp_endem_1nb,
    COALESCE(range_in_region.qualifies_perm1_rep5_or_endem75,0) AS qualifies_perm1_rep5_or_endem75,
    COALESCE(range_in_region.qualifies_perm1_endem75_only, 0) AS qualifies_perm1_endem75_only,
    COALESCE(range_in_region.qualifies_perm1_rep5_only, 0) AS qualifies_perm1_rep5_only,
    COALESCE(ROUND(range_in_region.sp_rep_2 :: numeric, 2), 0) AS sp_rep_2,
    COALESCE(ROUND(range_in_region.sp_endem_2 :: numeric, 2), 0) AS sp_endem_2,
    COALESCE(ROUND(range_in_region.sp_rep_2br :: numeric, 2), 0) AS sp_rep_2br,
    COALESCE(ROUND(range_in_region.sp_endem_2br :: numeric, 2), 0) AS sp_endem_2br,
    COALESCE(ROUND(range_in_region.sp_rep_2nb :: numeric, 2), 0) AS sp_rep_2nb,
    COALESCE(ROUND(range_in_region.sp_endem_2nb :: numeric, 2), 0) AS sp_endem_2nb,
    COALESCE(range_in_region.qualifies_perm2_rep5_or_endem75,0) AS qualifies_perm2_rep5_or_endem75,
    COALESCE(range_in_region.qualifies_perm2_endem75_only, 0) AS qualifies_perm2_endem75_only,
    COALESCE(range_in_region.qualifies_perm2_rep5_only, 0) AS qualifies_perm2_rep5_only
  FROM range_in_region
  JOIN wlab ON range_in_region.taxon_id = wlab.taxon_id
  JOIN tmp_region_continental ON range_in_region.region_id = tmp_region_continental.region_id
  WHERE 
    (ROUND(range_in_region.sp_rep_2 :: numeric, 2) > 0.1
    AND ROUND(range_in_region.sp_endem_2 :: numeric, 2) > 0.1)
    OR
    (range_in_region.sp_rep_2 IS NOT NULL
    AND range_in_region.sp_endem_2 IS NOT NULL)
  ;

-- xtab perm1 rep or endem for ABIs
  SELECT
    wlab.taxon_sort,
    wlab.taxon_level,
    COALESCE(wlab.is_ultrataxon,0) AS is_ultrataxon,
    range_in_region.taxon_id,
    wlab.taxon_name,
    wlab.taxon_scientific_name,
    wlab.bird_group,
    range_in_region.range_type,
    MIN(range_in_region.qualifies_perm1_rep5_or_endem75) FILTER (WHERE range_in_region.region_id = 1) AS "South West",
    MIN(range_in_region.qualifies_perm1_rep5_or_endem75) FILTER (WHERE range_in_region.region_id = 2) AS "Arid zone",
    MIN(range_in_region.qualifies_perm1_rep5_or_endem75) FILTER (WHERE range_in_region.region_id = 3) AS "Eastern Mallee",
    MIN(range_in_region.qualifies_perm1_rep5_or_endem75) FILTER (WHERE range_in_region.region_id = 4) AS "South-east Mainland",
    MIN(range_in_region.qualifies_perm1_rep5_or_endem75) FILTER (WHERE range_in_region.region_id = 5) AS "Tasmania",
    MIN(range_in_region.qualifies_perm1_rep5_or_endem75) FILTER (WHERE range_in_region.region_id = 6) AS "Brigalow Belt",
    MIN(range_in_region.qualifies_perm1_rep5_or_endem75) FILTER (WHERE range_in_region.region_id = 7) AS "East Coast",
    MIN(range_in_region.qualifies_perm1_rep5_or_endem75) FILTER (WHERE range_in_region.region_id = 8) AS "Tropical savanna",
    MIN(range_in_region.qualifies_perm1_rep5_or_endem75) FILTER (WHERE range_in_region.region_id = 9) AS "North-east Coast"
  FROM range_in_region
  JOIN wlab ON range_in_region.taxon_id = wlab.taxon_id
  JOIN tmp_region_continental ON range_in_region.region_id = tmp_region_continental.region_id
  WHERE
    (ROUND(range_in_region.sp_rep_2 :: numeric, 2) > 0.1
    AND ROUND(range_in_region.sp_endem_2 :: numeric, 2) > 0.1)
    OR
    (range_in_region.sp_rep_2 IS NOT NULL
    AND range_in_region.sp_endem_2 IS NOT NULL)
            AND (is_ultrataxon = 1
            AND sp_id <> 188
              OR sp_id <> 193
              OR sp_id <> 273
              OR sp_id <> 239
              OR sp_id <> 280
              OR sp_id <> 501
              OR sp_id <> 5124
              OR sp_id <> 524
              )
  GROUP BY
    wlab.taxon_sort,
    wlab.taxon_level,
    wlab.is_ultrataxon,
    range_in_region.taxon_id,
    wlab.taxon_name,
    wlab.taxon_scientific_name,
    range_in_region.range_type
  ;

-- States/territories
  SELECT
    range_in_region_states.region_id,
    tmp_region_continental.region_name,
    wlab.taxon_sort,
    wlab.taxon_level,
    COALESCE(wlab.is_ultrataxon,0) AS is_ultrataxon,
    range_in_region_states.taxon_id,
    wlab.taxon_name,
    wlab.taxon_scientific_name,
    range_in_region_states.range_type,
    COALESCE(ROUND(range_in_region_states.sp_rep_1 :: numeric, 2), 0) AS sp_rep_1,
    COALESCE(ROUND(range_in_region_states.sp_endem_1 :: numeric, 2), 0) AS sp_endem_1,
    COALESCE(ROUND(range_in_region_states.sp_rep_1br :: numeric, 2), 0) AS sp_rep_1br,
    COALESCE(ROUND(range_in_region_states.sp_endem_1br :: numeric, 2), 0) AS sp_endem_1br,
    COALESCE(ROUND(range_in_region_states.sp_rep_1nb :: numeric, 2), 0) AS sp_rep_1nb,
    COALESCE(ROUND(range_in_region_states.sp_endem_1nb :: numeric, 2), 0) AS sp_endem_1nb,
    COALESCE(range_in_region_states.qualifies_perm1_rep5_or_endem75,0) AS qualifies_perm1_rep5_or_endem75,
    COALESCE(range_in_region_states.qualifies_perm1_endem75_only, 0) AS qualifies_perm1_endem75_only,
    COALESCE(range_in_region_states.qualifies_perm1_rep5_only, 0) AS qualifies_perm1_rep5_only,
    COALESCE(ROUND(range_in_region_states.sp_rep_2 :: numeric, 2), 0) AS sp_rep_2,
    COALESCE(ROUND(range_in_region_states.sp_endem_2 :: numeric, 2), 0) AS sp_endem_2,
    COALESCE(ROUND(range_in_region_states.sp_rep_2br :: numeric, 2), 0) AS sp_rep_2br,
    COALESCE(ROUND(range_in_region_states.sp_endem_2br :: numeric, 2), 0) AS sp_endem_2br,
    COALESCE(ROUND(range_in_region_states.sp_rep_2nb :: numeric, 2), 0) AS sp_rep_2nb,
    COALESCE(ROUND(range_in_region_states.sp_endem_2nb :: numeric, 2), 0) AS sp_endem_2nb,
    COALESCE(range_in_region_states.qualifies_perm2_rep5_or_endem75,0) AS qualifies_perm2_rep5_or_endem75,
    COALESCE(range_in_region_states.qualifies_perm2_endem75_only, 0) AS qualifies_perm2_endem75_only,
    COALESCE(range_in_region_states.qualifies_perm2_rep5_only, 0) AS qualifies_perm2_rep5_only
  FROM range_in_region_states
  JOIN wlab ON range_in_region_states.taxon_id = wlab.taxon_id
  JOIN tmp_region_continental ON range_in_region_states.region_id = tmp_region_continental.region_id
  WHERE
    (ROUND(range_in_region_states.sp_rep_2 :: numeric, 2) > 0.1
    AND ROUND(range_in_region_states.sp_endem_2 :: numeric, 2) > 0.1)
    OR
    (range_in_region_states.sp_rep_2 IS NOT NULL
    AND range_in_region_states.sp_endem_2 IS NOT NULL)
  ;

-- xtab perm1 rep or endem for States/territories
  SELECT
    wlab.taxon_sort,
    wlab.taxon_level,
    COALESCE(wlab.is_ultrataxon,0) AS is_ultrataxon,
    range_in_region_states.taxon_id,
    wlab.taxon_name,
    wlab.taxon_scientific_name,
    range_in_region_states.range_type,
    MIN(range_in_region_states.qualifies_perm1_rep5_or_endem75) FILTER (WHERE range_in_region_states.region_id = 1) AS "Victoria",
    MIN(range_in_region_states.qualifies_perm1_rep5_or_endem75) FILTER (WHERE range_in_region_states.region_id = 2) AS "Queensland",
    MIN(range_in_region_states.qualifies_perm1_rep5_or_endem75) FILTER (WHERE range_in_region_states.region_id = 3) AS "New South Wales",
    MIN(range_in_region_states.qualifies_perm1_rep5_or_endem75) FILTER (WHERE range_in_region_states.region_id = 4) AS "South Australia",
    MIN(range_in_region_states.qualifies_perm1_rep5_or_endem75) FILTER (WHERE range_in_region_states.region_id = 5) AS "Western Australia",
    MIN(range_in_region_states.qualifies_perm1_rep5_or_endem75) FILTER (WHERE range_in_region_states.region_id = 6) AS "Australian Capital Territory",
    MIN(range_in_region_states.qualifies_perm1_rep5_or_endem75) FILTER (WHERE range_in_region_states.region_id = 7) AS "Northern Territory",
    MIN(range_in_region_states.qualifies_perm1_rep5_or_endem75) FILTER (WHERE range_in_region_states.region_id = 8) AS "Tasmania"
  FROM range_in_region_states
  JOIN wlab ON range_in_region_states.taxon_id = wlab.taxon_id
  JOIN tmp_region_continental ON range_in_region_states.region_id = tmp_region_continental.region_id
  WHERE
    (ROUND(range_in_region_states.sp_rep_2 :: numeric, 2) > 0.1
    AND ROUND(range_in_region_states.sp_endem_2 :: numeric, 2) > 0.1)
    OR
    (range_in_region_states.sp_rep_2 IS NOT NULL
    AND range_in_region_states.sp_endem_2 IS NOT NULL)
  GROUP BY
    wlab.taxon_sort,
    wlab.taxon_level,
    wlab.is_ultrataxon,
    range_in_region_states.taxon_id,
    wlab.taxon_name,
    wlab.taxon_scientific_name,
    range_in_region_states.range_type
  ;

-- check for %s > 100
  SELECT
    range_in_region.region_id,
    range_in_region.taxon_id,
    wlab.taxon_name,
    range_type, 
    sp_rep_1,
    sp_endem_1,
    sp_rep_1br,
    sp_endem_1br,
    sp_rep_1nb,
    sp_endem_1nb,
    sp_rep_2,
    sp_endem_2,
    sp_rep_2br,
    sp_endem_2br,
    sp_rep_2nb,
    sp_endem_2nb
  FROM range_in_region
  JOIN wlab ON range_in_region.taxon_id = wlab.taxon_id
    WHERE
    sp_rep_1 > 101
    OR sp_endem_1 > 101
    OR sp_rep_1br > 101
    OR sp_endem_1br > 101
    OR sp_rep_1nb > 101
    OR sp_endem_1nb > 101
    OR sp_rep_2 > 101
    OR sp_endem_2 > 101
    OR sp_rep_2br > 101
    OR sp_endem_2br > 101
    OR sp_rep_2nb > 101
    OR sp_endem_2nb > 101
  ORDER BY sp_rep_2 DESC
  ;

-- check max value
  SELECT
    range_in_region.region_id,
    range_in_region.taxon_id,
    wlab.taxon_name,
    range_type, 
    sp_rep_1,
    sp_endem_1,
    sp_rep_1br,
    sp_endem_1br,
    sp_rep_1nb,
    sp_endem_1nb,
    sp_rep_2,
    sp_endem_2,
    sp_rep_2br,
    sp_endem_2br,
    sp_rep_2nb,
    sp_endem_2nb
  FROM
      (SELECT
      MAX(
        COALESCE(
          sp_rep_1,
          sp_endem_1,
          sp_rep_1br,
          sp_endem_1br,
          sp_rep_1nb,
          sp_endem_1nb,
          sp_rep_2,
          sp_endem_2,
          sp_rep_2br,
          sp_endem_2br,
          sp_rep_2nb,
          sp_endem_2nb)
        ) AS max
      FROM range_in_region
      )max_val, range_in_region
  JOIN wlab ON range_in_region.taxon_id = wlab.taxon_id
  WHERE
    range_in_region.sp_rep_1 = max_val.max
    OR range_in_region.sp_endem_1 = max_val.max
    OR range_in_region.sp_rep_1br = max_val.max
    OR range_in_region.sp_endem_1br = max_val.max
    OR range_in_region.sp_rep_1nb = max_val.max
    OR range_in_region.sp_endem_1nb = max_val.max
    OR range_in_region.sp_rep_2 = max_val.max
    OR range_in_region.sp_endem_2 = max_val.max
    OR range_in_region.sp_rep_2br = max_val.max
    OR range_in_region.sp_endem_2br = max_val.max
    OR range_in_region.sp_rep_2nb = max_val.max
    OR range_in_region.sp_endem_2nb = max_val.max
  ;

-- missing taxa
--   no/incorrect range layer
CREATE TEMPORARY TABLE no_range AS
  WITH has_range AS
    (SELECT
       wlab_range.taxon_id AS wlab_range_taxon_id,
       range.taxon_id_r
    FROM range
    LEFT JOIN wlab_range ON range.taxon_id_r = wlab_range.taxon_id_r
    WHERE
      wlab_range.taxon_id is not null
      OR range.taxon_id_r is not null
    GROUP BY
      wlab_range.taxon_id,
      range.taxon_id_r
    )
  SELECT DISTINCT
    wlab_all.taxon_id,
    wlab_all.taxon_name,
    wlab_all.population,
    wlab_all.coastal_range
  FROM has_range
  RIGHT JOIN wlab_all ON has_range.wlab_range_taxon_id = wlab_all.taxon_id
  WHERE
    has_range.wlab_range_taxon_id IS NULL
    AND wlab_all.is_ultrataxon = 1
    AND (wlab_all.population NOT LIKE '%Vagrant%'
        AND wlab_all.population <> 'Failed introduction'
        AND wlab_all.population NOT LIKE '%Extinct%'
        AND wlab_all.population <> 'No confirmed record'
        AND wlab_all.population <> 'Domestic'
      )
  ;

-- taxa not in prem 2 + no range
  SELECT DISTINCT
    wlab_all.taxon_id,
    wlab_all.taxon_name,
    wlab_all.family_name,
    wlab_all.bird_group,
    wlab_all.bird_sub_group,
    wlab_all.population,
    wlab_all.rli_2020,
    wlab_all.coastal_range,
    wlab_all.v4_change_required,
    wlab_all.v4_change_not_implimented,
    wlab_all.range_notes
  FROM range_in_region
  RIGHT JOIN wlab_all ON range_in_region.taxon_id = wlab_all.taxon_id
  WHERE
    range_in_region.taxon_id IS NULL
    AND wlab_all.is_ultrataxon = 1
    AND (wlab_all.population NOT LIKE '%Vagrant%'
        AND wlab_all.population <> 'Failed introduction'
        AND wlab_all.population NOT LIKE '%Extinct%'
        AND wlab_all.population <> 'No confirmed record'
        AND wlab_all.population <> 'Domestic'
        )
  ;