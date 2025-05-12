import json
import boto3
import logging
import os
import pandas as pd
from sodapy import Socrata
from datetime import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def get_secret(secret_name):
    logger.info(f"Retrieving secret: {secret_name}")
    client = boto3.client('secretsmanager')
    response = client.get_secret_value(SecretId=secret_name)
    secret = json.loads(response['SecretString'])
    return secret

def load_to_s3(client, bucket, dataset_name, dataset_id):
    logger.info(f"Fetching data: {dataset_name}")
    s3_key_prefix = f"data/cdc/{dataset_name}"
    
    results = client.get(dataset_id, limit=2000)
    logger.info("Data received.")
    
    results_df = pd.DataFrame.from_records(results)
 
    filename = f"{dataset_name}_{datetime.utcnow().strftime('%Y%m%dT%H%M%SZ')}.csv"
    s3_key = f"data/cdc/{dataset_name}/{filename}"

    s3 = boto3.client("s3")
    csv_content = results_df.to_csv(index=False)
    s3.put_object(Bucket=s3_bucket, Key=s3_key, Body=csv_content.encode("utf-8"))
    logger.info(f"Uploaded to S3: s3://{s3_bucket}/{s3_key}")

def lambda_handler(event, context):
    logging.info("Received event:", json.dumps(event))

    domain = "data.cdc.gov"
    secret = get_secret("cdc/api/app_token")
    app_token = secret['CDC_APP_TOKEN']
    logger.info("Successfully retrieved CDC App Token.")
    client = Socrata(domain, app_token)
    
    s3_bucket = "" #data_bucket_name created from terraform 
    
    datasets = [
        {"name": "vsrr_maternal_mortality", "id": "e2d5-ggg7"}, # VSRR Provisional Maternal Death Counts and Rates
        {"name": "rsv_vaccination", "id": "g4jn-64pd"}, # RSV Vaccination 
        {"name": "covid_vaccination", "id": "efqg-e273"}, # COVID Vaccination
        {"name": "breastfeeding", "id": "8hxn-cvik"}, # Breastfeeding
        {"name": "infant_mortality", "id": "nfuu-hu6j"} # Infant Mortality Rates
    ]

    for dataset in datasets:
        load_to_s3(client, s3_bucket, dataset["name"], dataset["id"])
    
    return {
        'statusCode': 200,
        'body': json.dumps(message)
    }
