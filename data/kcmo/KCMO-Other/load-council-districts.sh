#!/bin/sh
#
# Move the data from KCMO Other.zip's layer neighborhoodcensus to our spatial database.
#
# Some extra code in here for debuging, and extra calls to psql for debuging
#  CouncilDistricts_2010  councildistricts_2010
(
cd /tmp
#
# Unpack Other.zip into Other.gdb

#
# Clean up from last run
#
#
sudo -u postgres psql -d code4kc -c "DROP TABLE councildistricts_2010;"
#
# Load the one layer councildistricts_2010
#
sudo -u postgres ogr2ogr -f "PostgreSQL" PG:"dbname=code4kc user=postgres" Other.gdb councildistricts_2010
#
# Do the conversion to 4326  INPUT may be EPSG 102698
#
sudo -u postgres psql -d code4kc -c "ALTER TABLE councildistricts_2010 ALTER COLUMN wkb_geometry  TYPE geometry(MultiPolygon, 4326) USING ST_Transform(wkb_geometry, 4326);"

#
# Now change ownership
#
sudo -u postgres psql -d code4kc -c "ALTER TABLE councildistricts_2010 OWNER TO c4kc;"
sudo -u postgres psql -d code4kc -c "ALTER TABLE councildistricts_2010_pkey OWNER TO c4kc;"
sudo -u postgres psql -d code4kc -c "ALTER TABLE councildistricts_2010_wkb_geometry_geom_idx OWNER TO c4kc;"

)


#################################################
# Now load the data in to the perment tables
#################################################

/usr/bin/php ./load-council-districts.php -U -f=/tmp/Other.gdb

# sudo -u postgres psql -d code4kc -c "DROP TABLE councildistricts_2010;"
