# run "test_ec2_instance_creation" {
#   command = apply

#   # Check if the EC2 instance ID is not empty (meaning it was created)
#   assert {
#     condition     = length(aws_instance.public_instances[*].id) > 0
#     error_message = "No EC2 instances were created"
#   }

#   # Check that the EC2 instance has the correct Name tag
#   assert {
#     condition     = alltrue([for instance in aws_instance.public_instances : instance.tags["Name"] == "Public-Instance-FocalBoard"])
#     error_message = "EC2 instance 'Name' tag is incorrect"
#   }

#   # Check that the instance is of the correct type (t3.medium)
#   assert {
#     condition     = alltrue([for instance in aws_instance.public_instances : instance.instance_type == "t3.medium"])
#     error_message = "EC2 instance type is not t3.medium"
#   }
#   }



run "test_s3_bucket_creation" {
  command = apply

  # Check that the S3 bucket is created
  assert {
    condition     = length(aws_s3_bucket.static[*].id) > 0
    error_message = "S3 bucket was not created"
  }

  # Check that the bucket has the correct name
  assert {
    condition     = alltrue([for bucket in aws_s3_bucket.static : bucket.bucket == var.s3_name])
    error_message = "S3 bucket name does not match expected value"
  }

  # Check that index.html was uploaded
  assert {
    condition     = length(aws_s3_object.index_html[*].id) > 0
    error_message = "index.html was not uploaded to the S3 bucket"
  }
}
