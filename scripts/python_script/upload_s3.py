#! /usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os
from boto.s3.connection import S3Connection
from boto.s3.connection import Location as S3Location
from boto.s3.key import Key

aws_key_id = os.environ.get("AWS_KEY_ID")
aws_secret_key = os.environ.get("AWS_SECRET_KEY")
aws_host = os.environ.get("AWS_HOST")
bucket_name = os.environ.get("BUCKET_NAME")

def main():
    bucket = S3Connection(
        str(aws_key_id),
        str(aws_secret_key),
        host = str(aws_host)
    ).get_bucket(bucket_name)

    path = raw_input().strip()
    key = Key(bucket)
    key.key = path.split('/')[-1]

    key.set_contents_from_filename(path)
    key.make_public()

    print(key.generate_url(86400).split('?')[0])


if __name__ == '__main__':
    main()
