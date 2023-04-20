provider "aws" {
  region = "us-west-1"
}

provider "aws" {
  alias  = "aqui"
  region = "us-east-1"
}

resource "aws_s3_bucket" "myoriginal" {
  provider = aws.aqui
  bucket = "my-origin-bucket-gail"
}

resource "aws_s3_bucket" "myreplicador" {
  bucket   = "my-destination-bucket-gail"
}

resource "aws_s3_bucket_versioning" "original-version" {
  provider = aws.aqui
  bucket = aws_s3_bucket.myoriginal.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_versioning" "replicar-version" {
  bucket = aws_s3_bucket.myreplicador.id
  versioning_configuration {
    status = "Enabled"
  }
}
#-------------------------------------
resource "aws_kms_key" "s3_replication_key" {
  description             = "Key for S3 bucket replication"
  deletion_window_in_days = 7
}
#-----------------------------------------

resource "aws_s3_bucket_replication_configuration" "configuracion" {
  provider = aws.aqui
  depends_on = [aws_s3_bucket_versioning.original-version]
  role   = aws_iam_role.s3-replicador-de-rol.arn
  bucket = aws_s3_bucket.myoriginal.id
  
  rule {
    id = "foobar"

    filter {
      prefix = ""
    }

    status = "Enabled"
    
    destination {
      bucket        = aws_s3_bucket.myreplicador.arn
      storage_class = "STANDARD"
       
     encryption_configuration {

        replica_kms_key_id   = aws_kms_key.s3_replication_key.arn
      }
    }
   
    
  }
}


