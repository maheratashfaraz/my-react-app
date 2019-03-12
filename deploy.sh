#!/usr/bin/env bash

# more bash-friendly output for jq
JQ="jq --raw-output --exit-status"

# configure_aws_cli(){
#     aws --version
#     accesskey=${AWS_ACCESS_KEY_ID}
#     secretkey=${AWS_SECRET_ACCESS_KEY}
#     aws configure set aws_access_key_id ${!accesskey} --profile $environment
#     aws configure set aws_secret_access_key ${!secretkey} --profile $environment
#     aws configure set default.output json --profile $environment
#     aws configure set default.region us-east-1 --profile $environment
#     aws configure set default.region us-east-1
#     aws configure set default.output json
# }

configure_aws_cli(){
    accesskey=${AWS_ACCESS_KEY_ID}
    secretkey=${AWS_SECRET_ACCESS_KEY}
    aws configure set aws_access_key_id ${accesskey}
    aws configure set aws_secret_access_key ${secretkey}
    aws --version
    aws configure set default.region us-east-1
    aws configure set default.output json
}

deploy_cluster() {
    family="devops-test-cluster"
    make_task_def
    register_definition
    if [[ $(aws ecs update-service --cluster devops-test-cluster --service devops-test-service --task-definition $revision --profile $environment --region us-east-1 | \
                $JQ '.service.taskDefinition') != $revision ]]; then
        echo "Error updating service."
        return 1
    fi

    echo "Deployed!"
    return 0

    # wait for older revisions to disappear
    # not really necessary, but nice for demos
    for attempt in {1..65}; do
        if stale=$(aws ecs describe-services --cluster devops-test-cluster --services devops-test-service --profile $environment | \
                       $JQ ".services[0].deployments | .[] | select(.taskDefinition != \"$revision\") | .taskDefinition"); then
            echo "Waiting for stale deployments:"
            echo "$stale"
            sleep 5
        else
            echo "Deployed!"
            return 0
        fi
    done
    echo "Service update took too long."
    return 1
}

make_task_def(){
    task_template='[
        {
            "name": "devops-test-web",
            "image": "%s.dkr.ecr.eu-west-1.amazonaws.com/my-react-app:%s",
            "essential": true,
            "memory": 512,
            "cpu": 10,
            "portMappings": [
                {
                    "containerPort": 80,
                    "hostPort": 0
                }
            ],
        }
    ]'
    BUILD_NUMBER=$(($CIRCLE_PREVIOUS_BUILD_NUM))
    task_def=$(printf "$task_template" ${AWS_ACCOUNT_ID} $BUILD_NUMBER)

}

push_ecr_image(){
    aws ecr get-login --region us-east-1
    eval $(aws ecr get-login --region us-east-1 --no-include-email | sed 's|https://||')
    BUILD_NUMBER=$(($CIRCLE_PREVIOUS_BUILD_NUM))
    docker push $AWS_ACCOUNT_ID.dkr.ecr.eu-west-1.amazonaws.com/my-react-app:$BUILD_NUMBER

}

register_definition() {

    if revision=$(aws ecs register-task-definition --container-definitions "$task_def" --family $family --profile ${environment} --region us-east-1 | $JQ '.taskDefinition.taskDefinitionArn'); then
        echo "Revision: $revision"
    else
        echo "Failed to register task definition"
        exit 1
    fi

}

_exit_error() {
    echo "##################################################################"
    echo "uh oh we had an oppppsie"
    echo ""
    echo "see above for the error"
    echo "##################################################################"
    exit 1
}

echo "Configuring CLI ..."
configure_aws_cli || _exit_error

echo "Pushing image ..."
push_ecr_image || _exit_error

echo "Deploying image ..."
deploy_cluster || _exit_error