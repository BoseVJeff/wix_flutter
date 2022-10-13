docker build --pull --rm -f "Dockerfile" -t wixflutter:latest "."
docker run --rm -v ${PWD}:/app --name wixflutterbuild wixflutter:latest bash ./app/build-linux.sh