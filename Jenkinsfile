#!/usr/bin/env groovy


podTemplate(label: 'mypod', containers: [
    containerTemplate(name: 'docker', image: 'docker', ttyEnabled: true, command: 'cat'),
    containerTemplate(name: 'kubectl', image: 'lachlanevenson/k8s-kubectl:v1.8.0', command: 'cat', ttyEnabled: true),
    containerTemplate(name: 'helm', image: 'lachlanevenson/k8s-helm:latest', command: 'cat', ttyEnabled: true)
  ],
  volumes: [
    hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock'),
  ]) {
      
    node('mypod') {

     
 
    stage('checkout') {
	
		script {
		git credentialsId: 'e0c038d8-5106-4d22-87e5-16b018816ef7', url: 'https://github.com/jvaibhav123/kube.git'
		def BUILD_TAG=sh(script:"git tag -l --points-at HEAD", returnStdout:true).trim()
		env.BUILD_TAG=BUILD_TAG
		}
	   	
	}
	
	
	stage('Build Plus Push')
	{
	
	  container('docker'){ 
	  script {
		withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'DOCKERPWD', usernameVariable: 'DOCKERUSER')]) {
		echo "Build tag ${BUILD_TAG}"
		if ("${BUILD_TAG}" != ""){
		stage('Build Docker image')
		{
			sh """
		
			echo "Docker build image"
			docker build -t $DOCKERUSER/demoapp:${BUILD_TAG} .
			"""
			
		}
		}
		}
		}
		}
		}

		
	
		 stage('Test the image with Kubernetes'){
		   container('docker'){
		       withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'DOCKERPWD', usernameVariable: 'DOCKERUSER')]) {
		   def testImageExist
                   sh """
		   testImageExist=`docker ps --filter "name=test_image" -q | wc -l`
		   if [ \$testImageExist -ge 1 ]
		   then
			docker stop \$(docker ps --filter "name=test_image" -q )
			docker rm \$(docker ps -a --filter "name=test_image" -q )
		   fi

		   testImageExist=`docker ps -a --filter "name=test_image" -q | wc -l`
		   if [ \$testImageExist -ge 1 ]
                   then
                        docker rm \$(docker ps -a --filter "name=test_image" -q )
                   fi

                   echo "Run container with latest image"
                   docker run -itd --name test_image -p 6000:5000 -l app=testimage $DOCKERUSER/demoapp:${BUILD_TAG}
                   echo "docker container successfully  started"
                   sleep 5
				   apk add --no-cache curl
				   sleep 5
                   if [ `curl -s -o /dev/null -w "%{http_code}\n" http://192.168.99.100:6000` -eq 200 ]
                   then
                                        echo "Docker image successfully running"
                   else
                                        echo "Something wrong"
										currentBuild.result = 'FAILED'

                   fi

                   docker stop \$(docker ps --filter "name=test_image" -q )
                   docker rm \$(docker ps -a --filter "name=test_image" -q )
                   """

                 }
		   }
		}
		 stage('Push to docker hub'){
		  container('docker'){
		      withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'DOCKERPWD', usernameVariable: 'DOCKERUSER')]) {
		 sh """
		docker login --username $DOCKERUSER --password $DOCKERPWD
		echo "Docker login successful"
		 echo "Push docker image"
		 docker push $DOCKERUSER/demoapp:${BUILD_TAG}
		 echo "Push completed successfully"
		 """
		 }
		  }
		} 
		 stage('Deploy the image'){
		 container('kubectl'){ 
		     def test_pods
		     
		 sh """
			kubectl set image deployment/pythonapp app=docker200037/demoapp:${BUILD_TAG}
			sleep 10
			test_pods=`kubectl get pods -l app=python | wc -l`  
			if [ \$test_pods -ge 1 ]
			then
				echo "deployment created successfully"
			else
				echo "Something is wrong"
				currentBuild.result = 'FAILED'
			fi	
		 
		 """
		 }
		 } 
			
		}
		}



