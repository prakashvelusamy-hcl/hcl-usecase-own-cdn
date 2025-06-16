module "s3" {
    source = "./modules/terraform-aws-s3"
    s3_name = var.s3_name
    }

module "cloud_front" {
    source = "./modules/terraform-aws-cloudfront"
    s3_name = var.s3_name
    region = var.region
}