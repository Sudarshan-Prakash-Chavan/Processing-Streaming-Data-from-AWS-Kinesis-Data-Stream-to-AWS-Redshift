# Processing-Streaming-Data-from-AWS-Kinesis-Data-Stream-to-AWS-Redshift
This project demonstrates how to ingest real-time crime data into Amazon Redshift from an AWS Kinesis Data Stream, enabling analytics on streaming data.

## Prerequisites

  *  AWS account with access to Kinesis, Redshift, IAM, and S3 services.
  *  Basic understanding of AWS services and SQL.

**Architectural Diagram**

![Streaming-Data-Ingestion-Kinesis-Redshift](https://github.com/user-attachments/assets/cb342798-8d29-4130-ad4c-d5fca4ae1d3d)

The architectural diagram should illustrate the following components:

  *  **S3 Bucket:** The starting point where the CSV file is stored.
  *  **Kinesis Data Stream:** Captures streaming data.
  *  **AWS Lambda:** Processes and formats incoming data (optional).
  *  **Amazon Redshift:** Data warehouse where data is stored and queried.
  *  **IAM Role:** Provides necessary permissions for Kinesis and Redshift.

### Step-by-Step Instructions

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

**Step 3: Create IAM Role for Lambda**

**1. Create IAM Role:**

 * Go to the IAM console.

 * Create a new role with the following permissions:

   * AmazonS3ReadOnlyAccess

   * AWSLambdaKinesisExecutionRole

   * CloudWatchLogsFullAccess

**Step 4: Create Lambda Function**

**1. Create the Lambda Function:**

 * Go to the Lambda console.

   * Create a new function:

   * Runtime: Python 3.x

 * Execution role: Use the IAM role created in Step 3.

**2. Add S3 Trigger:**

Configure the function to be triggered when a new object is created in your S3 bucket.

**3. Update Lambda Function Code:**

 * Use the following code for your Lambda function:

       import json
       import csv
       import boto3
       import uuid
       
       def lambda_handler(event, context):
           region = 'us-east-1'
           record_list = []
       	
           try:
               s3=boto3.client('s3')
               dynamodb=boto3.client('dynamodb',region_name=region)
               bucket=event['Records'][0]['s3']['bucket']['name']
               key=event['Records'][0]['s3']['object']['key']
       		
               print('Bucket:', bucket,'Key:', key)
               csv_file=s3.get_object(Bucket=bucket,Key=key)
               record_list=csv_file['Body'].read().decode('utf-8').split('\n')
               csv_reader=csv.reader(record_list,delimiter=',',quotechar='"')
               firstrecord=True
       		
               for row in csv_reader:
                  if(firstrecord):
                      firstrecord=False
                      continue
                  id=row[0]
                  case_number=row[1]
                  date=row[2]
                  block=row[3]
                  iucr_code=row[4]
                  location_desc=row[5]
                  arrest=row[6]
                  domestic=row[7]
                  beat_num=row[8]
                  district_code=row[9]
                  ward_no=row[10]
                  community_code=row[11]
                  fbi_code=row[12]
                  x_coordinate=row[13]
                  y_coordinate=row[14]
                  year=row[15]
                  date_of_update=row[16]
                  latitude=row[17]
                  longitude=row[18]
                  location=row[19]
       
       			  
                  print('id:',id)
       			  
                  data={'id':{'N':str(id)},'case_number':{'S':str(case_number)},'date':{'S':str(date)},'block':{'S':str(block)},'iucr_code':{'S':str(iucr_code)},'location_desc':{'S':str(location_desc)},'arrest':{'S':str(arrest)},'domestic':{'S':str(domestic)},'beat_num':{'N':str(beat_num)},'district_code':{'N':str(district_code)},'ward_no':{'N':str(ward_no)},'community_code':{'N':str(community_code)},'fbi_code':{'S':str(fbi_code)},'x_coordinate':{'S':str(x_coordinate)},'y_coordinate':{'S':str(y_coordinate)},'year':{'N':str(year)},'date_of_update':{'S':str(date_of_update)},'latitude':{'S':str(latitude)},'longitude':{'S':str(longitude)},'location':{'S':str(location)}})
              
           response=kinesis.put_record(StreamName='Criminaldatastream' ,Data=json.dumps(data),PartitionKey=str(uuid.uuid4()))
       
           except Exception as e:
       	       print(str(e))
       
           return {
               'statusCode': 200,
               'body': json.dumps('csv to Kinesis Data Stream success')
           }


**Step 5: Provisioning a Redshift Cluster**

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

**Step 6: Connect to Redshift Query Editor**

**1.  Open Query Editor:**

  *  In the Redshift console, click on the dropdown menu labeled Query Data and select Query Editor.

**2.  Connect to Database:**

  *  Use the credentials you saved earlier to connect to the default database.

**Step 7: Create External Schema**

  *  Run the following SQL command to create an external schema for Kinesis:

    CREATE EXTERNAL SCHEMA Realtime_CrimeData_Schema
    FROM KINESIS
    IAM_ROLE 'arn:aws:iam::YOUR_ACCOUNT_ID:role/YOUR_ROLE_NAME';

**Step 8: Create Materialized View**

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

**Step 9: Refresh the Materialized View**

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
