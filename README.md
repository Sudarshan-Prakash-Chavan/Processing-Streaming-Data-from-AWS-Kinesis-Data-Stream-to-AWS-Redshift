# Processing-Streaming-Data-from-AWS-Kinesis-Data-Stream-to-AWS-Redshift
This project demonstrates how to ingest real-time crime data into Amazon Redshift from an AWS Kinesis Data Stream, enabling analytics on streaming data.

**Prerequisites**

  *  AWS account with access to Kinesis, Redshift, IAM, and S3 services.
  *  Basic understanding of AWS services and SQL.

**Architectural Diagram**
The architectural diagram should illustrate the following components:

  *  **S3 Bucket:** The starting point where the CSV file is stored.
  *  **Kinesis Data Stream:** Captures streaming data.
  *  **AWS Lambda:** Processes and formats incoming data (optional).
  *  **Amazon Redshift:** Data warehouse where data is stored and queried.
  *  **IAM Role:** Provides necessary permissions for Kinesis and Redshift.

![Streaming-Data-Ingestion-Kinesis-Redshift](https://github.com/user-attachments/assets/cb342798-8d29-4130-ad4c-d5fca4ae1d3d)

**Step-by-Step Instructions**

**Step 1: Set Up S3 Bucket**

**1. Create an S3 Bucket:**

  *  Go to the S3 console.

  *  Create a new bucket (e.g., my-crimes-data-bucket).

**2. Upload CSV File:**

  *  Upload the crime data CSV file to your S3 bucket.

**Step 2: Create Kinesis Data Stream**

**1.  Navigate to Kinesis:**

  *  From the AWS Console, search for and select "Kinesis".

**2.  Create Data Stream:**

  *  Click on Create Data Stream.

  *  Fill in the required fields:

      *  Stream Name: Use a lowercase name for consistency with Redshift queries.
  
  *  Click Create.

**3.  Success Message:**

  *  Once the stream is created, you should see a success message.

**Step 3: Provisioning a Redshift Cluster**

**1.  Navigate to Redshift:**

  *  From the AWS Console, search for and select "Redshift".

**2.  Create Cluster:**

  *  Click on Create Cluster.

  *  Fill in the following details:

  *  Cluster Identifier: Give it a unique name.

  *  Cluster Type: Choose Free Trial.

  *  Database Name: Leave as default or specify.

  *  Master Username/Password: Write down these credentials for later use.

  *  Click Create Cluster. This will take several minutes.

**3.  Cluster Creation:**

  *  Monitor the progress of cluster creation in the console. It may take up to 10 minutes.

**4.  Associate IAM Role:**

  *  Once the cluster is created, go to the Properties tab.

  *  Associate the IAM role that has permissions for Kinesis and other required services.

**Step 4: Connect to Redshift Query Editor**

**1.  Open Query Editor:**

  *  In the Redshift console, click on the dropdown menu labeled Query Data and select Query Editor.

**2.  Connect to Database:**

  *  Use the credentials you saved earlier to connect to the default database.

**Step 5: Create External Schema**

  *  Run the following SQL command to create an external schema for Kinesis:

    CREATE EXTERNAL SCHEMA Realtime_CrimeData_Schema
    FROM KINESIS
    IAM_ROLE 'arn:aws:iam::YOUR_ACCOUNT_ID:role/YOUR_ROLE_NAME';

**Step 6: Create Materialized View**

  *  Create a materialized view to capture data from the Kinesis stream:

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

**Step 7: Refresh the Materialized View**

  *  Run the following command to refresh the materialized view:

    REFRESH MATERIALIZED VIEW ChicagoCrimeData;

**Analytical Queries**

You can now run analytical queries on the materialized view:

**1.  Total Number of Crime Cases on Each Day:**

    SELECT date_of_crime, COUNT(case_number) 
    FROM ChicagoCrimeData 
    GROUP BY date_of_crime 
    ORDER BY date_of_crime 
    LIMIT 20;

**2.  Total Number of Crime Cases on Each Day for Each District:**

    SELECT date_of_crime, district_code, COUNT(case_number) 
    FROM ChicagoCrimeData 
    GROUP BY date_of_crime, district_code 
    ORDER BY date_of_crime, district_code;

**Notes:**

  *  Replace YOUR_ACCOUNT_ID and YOUR_ROLE_NAME with your specific AWS account ID and role name.

  *  Customize the S3 bucket names and paths as needed for your implementation.
