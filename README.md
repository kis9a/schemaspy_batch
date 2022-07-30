# Schemaspy batch (example)

schemaspy-batch takes the message body (target name) in sqs, deduplicates it, runs schemaspy and updates the document with the S3 sync command.

## Initialization

```
# build Dockerfile
make build

## or build Dockerfile without cache
make build-no-cache

# pre commit hook
cp -f .pre-commit .git/hooks/pre-commit
```

(example)
First, edit the xxxxxx... in the run file according to your environment, modify the targets and items in the run_scheme function, and modify the target name in views/targets.json

## Developments

### Run script

```
# send target to queue example
aws sqs send-message --queue-url ${QUEUE_URL} --message-body "target-name" --profile aws-profile

# run_app example
make run_app env=stag option='-e EXAMPLE_STG_DATABASE_MYSQL_PASSWORD="xxxxxx"' p='-p aws-profile scheme'
```

### Exec container

```
# run container
make tail

# exec to container
make exec

# stop container
make stop

# or kill container
make kill
```

## Not explained here

- .github/workflows/deploy_views

If the views/ directory is updated, update the files in the root path with the s3 sync command.

- .github/workflows/deploy_schemaspy_batch.yml

How to deploy this batch and its details

- infrastructure

Infrastructure configuration and its details when actually using this service
