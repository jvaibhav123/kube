#!/usr/bin/env groovy
pipeline {
  

agent any 


  stages {
 
	
    stage('checkout') {
		steps{
		script {
		git credentialsId: 'e0c038d8-5106-4d22-87e5-16b018816ef7', url: 'https://github.com/jvaibhav123/pythonapp.git'
		def BUILD_TAG=sh(script:"git tag -l --points-at HEAD", returnStdout:true).trim()
		env.BUILD_TAG=BUILD_TAG
		}
	   }	
	}
	
	
	stage('Build Plus Push')
	{
	  steps{
	  container('docker'){ 
	  script {
		withCredentials([usernamePassword(credentialsId: 'dockkerhub', passwordVariable: 'DOCKERPWD', usernameVariable: 'DOCKERUSER')]) {
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
	
		 stage('Test the image with Kubernetes'){
		   container('kubectl'){
		   def test_pod
                   sh """
			sed -i "s/<version>/${BUILD_TAG}/g' deployment.yaml > /tmp/deployment.yaml
			kubectl apply -f /tmp/deployment.yaml -f kube_files/service.yaml -n test
			test_pod=`kubectl get pods -n test --no-header=true | wc -l`
			if [ \$test_pod -eq 1 ]
			then
				echo "deployment created successfully"
			else
				echo "Something is wrong"
			fi	
			echo "Test the image"
			if [ `curl -s -o /dev/null -w "%{http_code}\n" http://192.168.99.100:32592` -eq 200 ]
		   	then
					echo "Docker image successfully running"
		   	else
					echo "Something wrong"
					
		   	fi	
			kubectl delete -f /tmp/deployment.yaml -f kube_files/service.yaml -n test

		      """
                 }
	
		}
		 stage('Push to docker hub'){
		  container('docker'){
		 sh """
		docker login --username $DOCKERUSER --password $DOCKERPWD
		echo "Docker login successful"
		 echo "Push docker image"
		 docker push $DOCKERUSER/demoapp:${BUILD_TAG}
		 echo "Push completed successfully"
		 """
		 }
		 
		} 
		 stage('Deploy the image'){
		 container('kubectl'){ 
		 sh """
			sed -i "s/<version>/${BUILD_TAG}/g' deployment.yaml > /tmp/deployment.yaml
			kubectl apply -f /tmp/deployment.yaml -f kube_files/service.yaml -n test
			sleep 10
			if [ \$test_pod -eq 1 ]
			then
				echo "deployment created successfully"
			else
				echo "Something is wrong"
			fi	
		 
		 """
		 }
		 } 
			
		}
		}

	}
	
	}
	
	}
	
}



}




