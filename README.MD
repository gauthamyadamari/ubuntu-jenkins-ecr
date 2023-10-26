```
Push Docker image to AWS ECR using Jenkins pipeline
```
```
Prerequisites:
      (1)AWS Account with Admin Privileges
      (2)GitHub Account
```
Step #1:Configuring EC2 instance in AWS:
   --Go to the AWS dashboard and then to the EC2 services. create an instance

Step #2:Install Java on Ubuntu:
   --After the successful SSH connection, firstly update the Linux machine. And install java using 
     below commands:
                   (A)sudo apt update
                   (B)Now lets install java 17
                      sudo yum install java-17-amazon-corretto-devel.x86_64  -y
   --Lets check the version of java:
                   (A)java -version
Step #3:Install Jenkins on Ubuntu:
     (1)sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
     (2)https://pkg.jenkins.io/debian/jenkins.io-2023.key  
Then add a Jenkins apt repository entry:
    (1)echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
    (2)https://pkg.jenkins.io/debian binary/ | sudo tee \ 
    (3)/etc/apt/sources.list.d/jenkins.list > /dev/null
Update your local package index, then finally install Jenkins:
   (1) sudo apt-get update  
   (2) sudo yum install java-17-amazon-corretto-devel.x86_64  -y
   (3) sudo apt-get install jenkins

Step #4:Enable and start Jenkins on Ubuntu:
    (1)sudo systemctl enable jenkins
    (2)sudo systemctl start jenkins
    (3)sudo systemctl status jenkins

Step #5:Install git on Ubuntu:
   (1)sudo apt install git

Step #6:Access Jenkins on Browser
   (1)https//:<Instance_ip>:8080
   (2)Unlock Jenkins (Its one time)
   (3)Get the password from server and unlock
   (4)cat /var/lib/jenkins/intialadminPassword
   (5)Install suggested plugins
   (6)Create an initial admin user.

Step #7:Add AWS credentials in Jenkins
  (1)We may also set up AWS credentials in Jenkins so that it facilitates the Docker push to the 
     ECR repository.

  (2)GO to the Manage Jenkins>>Credentials>>system>>Global credentials


Step #8:Install Docker on Ubuntu:
  (1)sudo apt  install docker.io
  (2)sudo usermod -aG docker $USER
  (3)sudo chmod 666 /var/run/docker.sock
  (4)After installing docker lets Restart jenkins
    (A)sudo systemclt restart jenkins

Step #9:Installing plugins in Jenkins
 (1)Go to the manage Jenkins>>Plugins>>Available Plugin
    (A)Docker
    (B)Docker Pipeline
    (C)Amazon ECR plugin

Step #10:Creating ECR Repository in AWS
 (1)Lets Create AWS ECR repository to push this image so Go to AWS ECR repository and create

Step #11:Create AmazonEC2ContainerRegistryFullAccess IAM Role in AWS
  (1)Here in this step we need to create IAM role with below permission 
  (2)Attach permission policies : AmazonEC2ContainerRegistryFullAccess

Step #12:Install AWS CLI on Ubuntu:
  (1)You can go to the official site of AWS and Install

Step #13:Push Docker image to AWS ECR using Jenkins pipeline

   pipeline {
    agent any
    environment {
        AWS_ACCOUNT_ID="12345678"
        AWS_DEFAULT_REGION="us-east-1"
        IMAGE_REPO_NAME="ECRREPO-NAME"
        IMAGE_TAG="latest"
        REPOSITORY_URI = "ECR-REPO-URL-LINK"
    }
   
    stages {
        
         stage('Logging into AWS ECR') {
            steps {
                script {
                sh """aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"""
                }
                 
            }
        }
        
        stage('Cloning Git') {
            steps {
                git branch: 'main', credentialsId: 'jenkins-ecr', url: 'https://github.com/gauthamyadamari/ubuntu-jenkins-ecr.git'     
            }
        }
  
    // Building Docker images
    stage('Building image') {
      steps{
        script {
          dockerImage = docker.build "${IMAGE_REPO_NAME}:${IMAGE_TAG}"
        }
      }
    }
   
    // Uploading Docker images into AWS ECR
    stage('Pushing to ECR') {
     steps{  
         script {
                sh """docker tag ${IMAGE_REPO_NAME}:${IMAGE_TAG} ${REPOSITORY_URI}:$IMAGE_TAG"""
                sh """docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:${IMAGE_TAG}"""
         }
        }
      }
    }
}