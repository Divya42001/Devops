import boto3
import json
import redis

# ElastiCache Redis endpoint
redis_host = 'YOUR_REDIS_HOST'
redis_port = 'YOUR_REDIS_PORT'
redis_password = 'YOUR_REDIS_PASSWORD'

# S3 bucket details
s3_bucket_name = 'YOUR_S3_BUCKET_NAME'
s3_key = 'redis_data.json'

def export_redis_data_to_s3():
    # Connect to Redis
    r = redis.StrictRedis(host=redis_host, port=redis_port, password=redis_password, decode_responses=True)

    # Get all keys from Redis
    keys = r.keys()

    # Retrieve data for each key
    data = {}
    for key in keys:
        data[key] = r.get(key)

    # Upload data to S3 as JSON
    s3 = boto3.client('s3')
    s3.put_object(Bucket=s3_bucket_name, Key=s3_key, Body=json.dumps(data))


if __name__ == "__main__":
    export_redis_data_to_s3()


# I am running this script from aws instance ,IAM role attached which has access on s3 to put objects