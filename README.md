# Création de l'image docker
`docker build -t back .`
# Push de l'image sur ce répertoire GitHub
## Login docker pour GitHub
Dans les paramètre de GitHub j'ai créé un token d'accès personnel que j'ai inséré dans un fichier **pass.txt**  
Pour connecter docker à GitHub voici la commande :  
`cat pass.txt | docker login docker.pkg.github.com -u anthonycouture --password-stdin`
## Push de l'image vers le répertoire GitHub
Création du tag :  
`docker tag ID_IMAGE docker.pkg.github.com/anthonycouture/spring-k8s/back:latest`  
Push de l'image sur le répertoire GitHub :  
`docker push docker.pkg.github.com/anthonycouture/spring-k8s/back:latest`

# Déploiement du l'image sur Kubernetes
## Création du secret dans Kubernetes
Pour pouvoir utiliser l'image il faut pouvoir s'identifier sur GitHub. Comme je suis connecté avec Docker je récupère l'authentification de docker sur Kubernetes :  

```
kubectl create secret generic regcred \
    --from-file=.dockerconfigjson=$HOME/.docker/config.json \
    --type=kubernetes.io/dockerconfigjson
```

## Déploiement du projet sur kubernetes
J'ai créer un fichier back-deploy.yaml qui correspond au déploiement sur kubernetes (nous pouvons voir le secret créer avant à cette endroit **imagePullSecrets** dans le fichier back-deploy.yaml) :  
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: back-deployment
  labels:
    app: back
spec:
  replicas: 1
  selector:
    matchLabels:
      app: back
  template:
    metadata:
      labels:
        app: back
    spec:
      containers:
        - name: back
          image: docker.pkg.github.com/anthonycouture/spring-k8s/back:latest
          imagePullPolicy: Always
          ports:
          - containerPort: 8080
      imagePullSecrets:
        - name: regcred


```
Ensuite nous lançons le déploiement :  
`kubectl apply -f back-deploy.yaml`  
Nous pouvons visualiser les pods avec cette commande :  
`kubectl get pod`  
Nous pouvons visualiser le déploiement avec cette commande :  
`kubectl get deployment`
