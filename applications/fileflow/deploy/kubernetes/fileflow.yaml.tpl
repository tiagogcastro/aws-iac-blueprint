apiVersion: v1
kind: Namespace
metadata:
  name: fileflow
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: fileflow-api
  namespace: fileflow
  annotations:
    eks.amazonaws.com/role-arn: __API_ROLE_ARN__
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: fileflow-worker
  namespace: fileflow
  annotations:
    eks.amazonaws.com/role-arn: __WORKER_ROLE_ARN__
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: fileflow
  namespace: fileflow
data:
  AWS_REGION: us-east-1
  AWS_ENDPOINT_URL: __AWS_ENDPOINT__
  S3_BUCKET: __S3_BUCKET__
  DYNAMODB_FILES_TABLE: __FILES_TABLE__
  DYNAMODB_EVENTS_TABLE: __EVENTS_TABLE__
  SQS_QUEUE_URL: __QUEUE_URL__
  FILEFLOW_OWNER_ID: public
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: fileflow-api
  namespace: fileflow
spec:
  replicas: 2
  selector:
    matchLabels:
      app: fileflow-api
  template:
    metadata:
      labels:
        app: fileflow-api
    spec:
      serviceAccountName: fileflow-api
      containers:
        - name: api
          image: __IMAGE__
          imagePullPolicy: Never
          args: ["api"]
          ports:
            - name: http
              containerPort: 8080
          envFrom:
            - configMapRef:
                name: fileflow
          env:
            - name: AWS_ACCESS_KEY_ID
              value: test
            - name: AWS_SECRET_ACCESS_KEY
              value: test
          readinessProbe:
            httpGet:
              path: /healthz
              port: http
          livenessProbe:
            httpGet:
              path: /healthz
              port: http
          resources:
            requests:
              cpu: 25m
              memory: 32Mi
            limits:
              cpu: 250m
              memory: 128Mi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: fileflow-worker
  namespace: fileflow
spec:
  replicas: 1
  selector:
    matchLabels:
      app: fileflow-worker
  template:
    metadata:
      labels:
        app: fileflow-worker
    spec:
      serviceAccountName: fileflow-worker
      containers:
        - name: worker
          image: __IMAGE__
          imagePullPolicy: Never
          args: ["worker"]
          envFrom:
            - configMapRef:
                name: fileflow
          env:
            - name: AWS_ACCESS_KEY_ID
              value: test
            - name: AWS_SECRET_ACCESS_KEY
              value: test
          resources:
            requests:
              cpu: 25m
              memory: 32Mi
            limits:
              cpu: 250m
              memory: 128Mi
---
apiVersion: v1
kind: Service
metadata:
  name: fileflow-api
  namespace: fileflow
spec:
  type: NodePort
  selector:
    app: fileflow-api
  ports:
    - name: http
      port: 80
      targetPort: http
      nodePort: 30080
