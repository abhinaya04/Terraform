#CloudFront distribution
This script will deploy Lambda Function and CloudFront Distribution(CDN) with existing domain.

#AWS authentication
Need to export AWS access and secret on base machine where we do terrafom deployment.

export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=

#Dependencies(Provide below in variable.tf)


User must have below permissions inorder to create custom role for Lambda fuction.
iam:CreatePolicy
iam:CreateRole
iam:attachRolePolicy
iam:CreateServiceLinkedRole
Need to provide code(index.js)as a zip file(Acheiving through local-exec on fly).
Need to provide runtime environment and handler.
Script looks for existing lambda fuction arn and latest published version.

Need to provide own http/https endpoint as origin.
CF acceps below are as Orgin endpoints...

Amazon S3 bucket – myawsbucket.s3.amazonaws.com
Amazon S3 bucket configured as a website – http://bucket-name.s3-website-us-west-2.amazonaws.com
MediaStore container – mymediastore.data.mediastore.us-west-1.amazonaws.com
MediaPackage endpoint – mymediapackage.mediapackage.us-west-1.amazon.com
Amazon EC2 instance – ec2-203-0-113-25.compute-1.amazonaws.com
Elastic Load Balancing load balancer – my-load-balancer-1234567890.us-west-2.elb.amazonaws.com
Your own web server – https://example.com

Provide meaningful origin id.


#Execution


Intializing terraform plugins based on provider and provisioners.
"terraform init"
Using "terraform plan" we can forecast deployment configuration.
Finally deploy with "terraform apply".


NOTE: CloudFront distribution deployemnt(Creation or Modification) take about 15 to 20 minutes.