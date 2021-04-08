-- SQL Script
-- This script is to compare the number of trees in riparian buffers with the amount of flood-prone land in each ward in Dar es Salaam.
-- Be sure to create a spatial index for each layer.

--Prepare flood data
UPDATE flood
SET geom = st_makevalid(geom);

CREATE TABLE flooddissolve
AS
SELECT st_union(geom)::geometry(multipolygon,32737) as geom
FROM flood;

--Aggregate floods to wards
CREATE TABLE ward_flood AS
SELECT wards.*, st_multi(st_intersection(wards.utmgeom, flooddissolve.geom))::geometry(multipolygon,32737) as geom
FROM wards INNER JOIN flooddissolve
ON st_intersects(wards.utmgeom, flooddissolve.geom);

--Find area of flood zones within wards
ALTER TABLE ward_flood
ADD COLUMN flood_area real;

UPDATE ward_flood
SET flood_area = st_area(geom);

-- Extracting tree point layer
CREATE TABLE trees AS
SELECT osm_id, st_transform(way,32737)::geometry(point,32737) as geom
FROM planet_osm_point
WHERE “natural” ILIKE 'tree';

-- Extracting rivers and streams data
CREATE TABLE riverstream AS
SELECT osm_id, st_transform(way,32737)::geometry(linestring,32737) as geom
FROM planet_osm_line
WHERE waterway ILIKE 'river' OR waterway ILIKE 'stream';

-- Extracting forest polygon layer
CREATE TABLE forest AS
SELECT osm_id, st_transform(way,32737)::geometry(polygon,32737) as geom
FROM planet_osm_polygon
WHERE landuse ILIKE 'forest';

--Tree buffers and river buffers (riparian areas)
CREATE TABLE treebuffer AS
SELECT osm_id, st_buffer(geom, 6)::geometry(polygon,32737) as geom from trees;

CREATE TABLE rip_buffer AS
SELECT osm_id, st_buffer(geom, 15)::geometry(polygon,32737) as geom from riverstream;

--Final trees/forest layer
CREATE TABLE treespolygon AS
SELECT osm_id, geom FROM treebuffer
UNION
SELECT osm_id, geom FROM forest;

--Find tree cover in riparian areas
CREATE TABLE riptrees AS
SELECT st_multi(st_intersection(treespolygon.geom, rip_buffer.geom))::geometry(multipolygon,32737) as geom
FROM treespolygon INNER JOIN rip_buffer
ON st_intersects(treespolygon.geom, rip_buffer.geom);

--Dissolve geometries of trees
CREATE TABLE treedissolve AS
SELECT st_union(geom)::geometry(multipolygon,32737) as geom
FROM riptrees;

CREATE TABLE wardriptrees AS
SELECT wards.ward_name, wards.flood_area, st_multi(st_intersection(treedissolve.geom, wards.utmgeom))::geometry(multipolygon,32737) as geom
FROM wards LEFT JOIN treedissolve
ON st_intersects(treedissolve.geom, wards.utmgeom);

-- Find areas of riparian tree cover in each ward
ALTER TABLE wardriptrees
ADD COLUMN treearea real;

UPDATE wardriptrees
SET treearea = st_area(geom);

--Calculating ward area
ALTER TABLE wardriptrees
ADD COLUMN wardarea_m2 real;

UPDATE wardriptrees
SET wardarea_m2 = st_area(utmgeom);

--Calculating percent riparian trees in a ward
ALTER TABLE wardriptrees
ADD COLUMN pct_riptrees real;

UPDATE wardriptrees
SET pct_riptrees = (treearea_m2 / wardarea_m2) * 100;

--Calculating percent flood area in a ward
ALTER TABLE wardriptrees
ADD COLUMN pct_flood real;

UPDATE wardriptrees
SET pct_flood = (flood_area / wardarea_m2) * 100;
