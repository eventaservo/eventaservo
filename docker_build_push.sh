echo "Build e Upload do docker EventaServo"
echo "-----"
echo "Escolha o ambiente:"
echo "1) Produção"
echo "2) Staging"

read ambiente 

case $ambiente in
    "1")
      AMBIENTE=production
      TAG=latest
      echo "----------------------------"
      echo "Preparando PRODUÇÃO (backend)"
      echo "----------------------------"
        ;;
    "2")
      AMBIENTE=staging
      TAG=staging
      echo "----------------------------"
      echo "Preparando STAGING (staging)"
      echo "----------------------------"
        ;;
    *) echo "Opção inválida";;
esac

RAILS_MASTER_KEY=87c1f6ae491db326d4187fed3ba77c11 \
docker buildx build . \
  -f Dockerfile \
  --build-arg AMBIENTE=$AMBIENTE \
  --tag eventaservo/backend:$TAG

if [ $? -eq 0 ]; then
  echo "PUSH desativado"
  # docker push eventaservo/backend:$TAG
fi
