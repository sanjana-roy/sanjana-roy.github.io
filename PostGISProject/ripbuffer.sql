
-- Riparian Trees and Floodinng in Dar es Salaam

--TREES
CREATE TABLE trees AS
SELECT osm_id, st_transform(way,32737)::geometry(point,32737) as geom
FROM planet_osm_point
WHERE "natural" = 'tree';

-- Select "create spatial index"

--RIVERS AND STREAMS
CREATE TABLE riverstream AS
SELECT osm_id, st_transform(way,32737)::geometry(linestring,32737) as geom
FROM planet_osm_line
WHERE waterway ILIKE 'stream' OR waterway ILIKE 'river';

-- Select "create spatial index"

-- FORESTS
CREATE TABLE forest AS
SELECT osm_id, st_transform(way,32737)::geometry(polygon,32737) as geom
FROM planet_osm_polygon
WHERE landuse ILIKE 'forest';

-- Select "create spatial index"

--CREATING BUFFERS AROUND TREES
CREATE TABLE treebuffer AS
SELECT osm_id, st_buffer(geom, 6)::geometry(polygon,32737) as geom
FROM trees;

-- Select "create spatial index"

-- CREATING RIPARIAN BUFFER
CREATE TABLE ripbuffer AS
SELECT osm_id, st_buffer(geom, 15)::geometry(polygon,32737) as geom
FROM riverstream;

-- Select "create spatial index"

-- JOINING TREES AND FORESTS INTO ONE POLYGON LAYER
CREATE TABLE treespolygon AS
SELECT osm_id, geom FROM treebuffer
UNION
SELECT osm_id, geom FROM forest;

-- Select "create spatial index"

-- CLIPPING GEOMETRIES OF treespolygon to ripbuffer
/*
CREATE TABLE riptrees_test1 AS
SELECT osm_id, geom FROM treespolygon
EXCEPT
SELECT osm_id, geom FROM ripbuffer; */

/*
CREATE TABLE riptrees_test2 AS
SELECT treespolygon.*
FROM treespolygon INNER JOIN ripbuffer
ON st_intersects(treespolygon.geom, ripbuffer.geom); */

CREATE TABLE riptrees AS
SELECT st_multi(st_intersection(treespolygon.geom, ripbuffer.geom))::geometry(multipolygon,32737) as geom
FROM treespolygon INNER JOIN ripbuffer
ON st_intersects(treespolygon.geom, ripbuffer.geom);

-- Select "create spatial index"

-- INTERSECTING WARDS WITH riptrees
-- WE ALREADY HAVE wardflood
/*
CREATE TABLE ward_flood AS
SELECT ward_census.*, st_multi(st_intersection(ward_census.utmgeom, flooddissolve.geom))::geometry(multipolygon,32737) as geom
FROM ward_census INNER JOIN flooddissolve
ON st_intersects(ward_census.utmgeom, flooddissolve.geom);
*/

-- DISSOLVING GEOMTERY
-- DISSOLVING GEOMETRIES
--ward_flood already created with grouped flooddissolve
/*CREATE TABLE flooddissolve AS
SELECT st_union(geom)::geometry(multipolygon,32737) as geom
FROM ward_flood;*/

CREATE TABLE treedissolve AS
SELECT st_union(geom)::geometry(multipolygon,32737) as geom
FROM riptrees;

-- Select "create spatial index"

-- INTERSECTING ward_census WITH riptrees
-- wards changed to utmgeom 32737 from 4326 as ward_census
CREATE TABLE wardriptrees AS
SELECT ward_census.*, st_multi(st_intersection(ward_census.utmgeom, treedissolve.geom))::geometry(multipolygon,32737) as newgeom
FROM ward_census LEFT JOIN treedissolve
ON st_intersects(ward_census.utmgeom, treedissolve.geom);

-- Select "create spatial index"

-- DISSOLVING GEOMETRIES
--ward_flood already created with grouped flooddissolve
/*CREATE TABLE flooddissolve AS
SELECT st_union(geom)::geometry(multipolygon,32737) as geom
FROM ward_flood;*/


-- FIND AREAS
--area of wardriptrees
CREATE TABLE wardriptreesarea AS
SELECT *, st_area(geom) as treearea_m2
FROM wardriptrees;



ALTER TABLE wardriptrees_true
ADD COLUMN treearea_m2 real;

UPDATE wardriptrees_true
SET treearea_m2 = st_area(geom);

--already done in flood_area_m2
-- area of ward_flood
/*
CREATE TABLE ward_floodarea AS
SELECT *, st_area(geom) as floodarea_m2
FROM ward_flood; */

--Dissolving ripbuffer for leaflet map
CREATE TABLE ripbufferdissolve AS
SELECT st_union(geom)::geometry(multipolygon,32737) as geom
FROM ripbuffer;



--JOINING BACK TO ORIGNAL wards
--joining wardriptreesarea
CREATE TABLE join_a AS
SELECT wards.*, treearea_m2
FROM wards INNER JOIN wardriptreesarea
WHERE wards.ward_name = wardriptreesarea.ward_name;


--joining ward_floodarea
CREATE TABLE finaljoin AS
SELECT wards.*, floodarea_m2
FROM join_a INNER JOIN ward_floodarea
WHERE join_a.ward_name = ward_floodarea.ward_name;

--CALCULATING WARD AREA
ALTER TABLE wardriptrees_true
ADD COLUMN wardarea_m2 real;

UPDATE wardriptrees_true
SET wardarea_m2 = st_area(utmgeom);


--CALCULATING percent riparian trees in a ward
ALTER TABLE wardriptrees_true
ADD COLUMN pct_riptrees real;

UPDATE wardriptrees_true
SET pct_riptrees = (treearea_m2 / wardarea_m2) * 100;
