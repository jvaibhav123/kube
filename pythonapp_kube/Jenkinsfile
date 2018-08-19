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
	
		 stage('Test the image'){
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
                   if [ `curl -s -o /dev/null -w "%{http_code}\n" http://0.0.0.0:6000/` -eq 200 ]
                   then
                                        echo "Docker image successfully running"
                   else
                                        echo "Something wrong"

                   fi

                   docker stop \$(docker ps --filter "name=test_image" -q )
                   docker rm \$(docker ps -a --filter "name=test_image" -q )
                   """


                 }
	

		 stage('Push to docker hub'){
		 sh """
		docker login --username $DOCKERUSER --password $DOCKERPWD
		echo "Docker login successful"
		 echo "Push docker image"
		 docker push $DOCKERUSER/demoapp:${BUILD_TAG}
		 echo "Push completed successfully"
		 """
		 }
		 
		 
		 stage('Deploy the image'){
		 
		 sh """
		 echo "Stop existing "
		 docker stop \$(docker ps --filter "label=app=demoapp" -q | grep -v ${BUILD_TAG} )
		 docker rm \$(docker ps -a --filter "label=app=demoapp" -q | grep -v ${BUILD_TAG} )
		 sleep 2
		 echo "Deploy Image on server"
		 docker run -itd --name pythonapp -p 5000:5000 -l app=demoapp -l version=${BUILD_TAG} $DOCKERUSER/demoapp:${BUILD_TAG}
		 
		 
		 
		 """
		 }
		  
			
		}
		}

	}
	
	}
	
	}
	
}



}




