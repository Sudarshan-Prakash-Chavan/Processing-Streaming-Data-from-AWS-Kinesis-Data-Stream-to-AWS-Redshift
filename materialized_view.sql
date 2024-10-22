CREATE MATERIALIZED VIEW ChicagoCrimeData AS
SELECT
    json_extract_path_text(from_varbyte(kinesis_data, 'utf-8'),'id')::VARCHAR as ID,
    json_extract_path_text(from_varbyte(kinesis_data, 'utf-8'),'case_number')::VARCHAR as Case_Number,
    json_extract_path_text(from_varbyte(kinesis_data, 'utf-8'),'date')::VARCHAR as Date_of_Crime,
    json_extract_path_text(from_varbyte(kinesis_data, 'utf-8'),'block')::VARCHAR as Block,
    json_extract_path_text(from_varbyte(kinesis_data, 'utf-8'),'iucr_code')::VARCHAR as Iucr_Code,
    json_extract_path_text(from_varbyte(kinesis_data, 'utf-8'),'location_desc')::VARCHAR as Location_Desc,
    json_extract_path_text(from_varbyte(kinesis_data, 'utf-8'),'arrest')::VARCHAR as Arrest,
    json_extract_path_text(from_varbyte(kinesis_data, 'utf-8'),'domestic')::VARCHAR as Domestic,
    json_extract_path_text(from_varbyte(kinesis_data, 'utf-8'),'beat_num')::VARCHAR as Beat_Num,
    json_extract_path_text(from_varbyte(kinesis_data, 'utf-8'),'district_code')::VARCHAR as District_Code,
    json_extract_path_text(from_varbyte(kinesis_data, 'utf-8'),'ward_no')::VARCHAR as Ward_No,
    json_extract_path_text(from_varbyte(kinesis_data, 'utf-8'),'community_code')::VARCHAR as Community_Code,
    json_extract_path_text(from_varbyte(kinesis_data, 'utf-8'),'fbi_code')::VARCHAR as FBI_Code,
    json_extract_path_text(from_varbyte(kinesis_data, 'utf-8'),'x_coordinate')::VARCHAR as X_Coordinate,
    json_extract_path_text(from_varbyte(kinesis_data, 'utf-8'),'y_coordinate')::VARCHAR as Y_Coordinate,
    json_extract_path_text(from_varbyte(kinesis_data, 'utf-8'),'year')::VARCHAR as Year,
    json_extract_path_text(from_varbyte(kinesis_data, 'utf-8'),'date_of_update')::VARCHAR as Date_of_Update,
    json_extract_path_text(from_varbyte(kinesis_data, 'utf-8'),'latitude')::VARCHAR as Latitude,
    json_extract_path_text(from_varbyte(kinesis_data, 'utf-8'),'longitude')::VARCHAR as Longitude,
    json_extract_path_text(from_varbyte(kinesis_data, 'utf-8'),'location')::VARCHAR as Location
FROM Realtime_CrimeData_Schema."crimedatastream";
