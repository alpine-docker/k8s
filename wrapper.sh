#!/bin/bash

print_usage() {
    echo "Connect to remote EKS kubernetes:"
    echo "  -h          |--help                      - Show usage information"
    echo "  -c=         |--cluster-name=             - Cluster Name (e.g my-eks-dev)"
    echo "  -key_id=    |--aws_access_key_id=        - AWS access key"
    echo "  -access_key=|--aws_secret_access_key=    - AWS secret key"
    echo "  -f          |--force                     - Force the operation (don't wait for user input)"
    echo ""
    echo "If AWS credentials already added to the environment (cat ~/.aws/credentials) we can leave blank  the [-key_id=] and [-access_key=] parameters"
    echo "To enable aws-cli autocompletion: (complete -C '/usr/bin/aws_completer' aws)"
    echo "TIP: To get avaliable cluster: [docker run --rm -e AWS_ACCESS_KEY_ID= -e AWS_SECRET_ACCESS_KEY= -it  aws-tools -c "aws eks list-clusters --region us-east-1"]"
    echo "Example usage: ./$(basename $0) -c=my-eks-dev  -key_id= -access_key="
}
# Prepare env and path solve the docker copy on windows when using bash
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        MYPATH=$PWD
elif [[ "$OSTYPE" == "darwin"* ]]; then
        # Mac OSX
        MYPATH=$PWD
elif [[ "$OSTYPE" == "cygwin" ]]; then
        # POSIX compatibility layer and Linux environment emulation for Windows
        MYPATH=$(cygpath -w $PWD)
        HOME=$(cygpath -w $HOME)
elif [[ "$OSTYPE" == "msys" ]]; then
        # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
        MYPATH=$(cygpath -w $PWD)
        HOME=$(cygpath -w $HOME)
elif [[ "$OSTYPE" == "win32" ]]; then
        # I'm not sure this can happen.
        MYPATH=$(cygpath -w $PWD)
        HOME=$(cygpath -w $HOME)
elif [[ "$OSTYPE" == "freebsd"* ]]; then
        MYPATH=$PWD
fi

# Parse command line arguments
for i in "$@"
do
case $i in
    -h|--help)
    print_usage
    exit 0
    ;;
    -c=*|--cluster-name=*)
    EKS_CLUSTER_NAME="${i#*=}"
    shift # past argument=value
    ;;
    -key_id=*|--aws_access_key_id=*)
    AWS_ACCESS_KEY_ID="${i#*=}"
    shift # past argument=value
    ;;
    -access_key=*|--aws_secret_access_key=*)
    AWS_SECRET_ACCESS_KEY="${i#*=}"
    shift # past argument=value
    ;;
    -f|--force)
    FORCE=1
    ;;
    *)
    echoerr "ERROR: Unknown argument"
    print_usage
    exit 1
    # unknown option
    ;;
esac
done

# Build the image
docker build  -t aws-tools -f Dockerfile .


CONTAINER_ID=$(docker run \
    -v "$HOME/.aws/credentials":/root/.aws/credentials:ro \
    -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}  \
    -it -d aws-tools) && echo "Container running with id: ${CONTAINER_ID}"

# Here is stange additional charachter in file .bashrc when using edited in Linux and used in Windows
# Be sure to edit while VS Code mode is CRLF
docker exec -u root -it $CONTAINER_ID bash -l -c "\
rm -f ~/.kube/config \
&& echo Updating K8S Environment... \
&& aws eks update-kubeconfig --name $EKS_CLUSTER_NAME --region us-east-1 \
&& kubectl get nodes
"

docker attach  $CONTAINER_ID #  If we use attach we can use only one instance of the shell.

# We are done - Removing container 
docker rm -f $CONTAINER_ID &>/dev/null && echo "We are done - container removed"
