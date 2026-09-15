resource "aws_launch_template" "nextflow_batch" {
  name_prefix = "${var.name_prefix}-nextflow-"

  user_data = base64encode(<<-EOF
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==NEXTFLOW=="

--==NEXTFLOW==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
set -euxo pipefail

# curl is already provided by curl-minimal on ECS_AL2023.
dnf install -y unzip

mkdir -p /opt/nextflow/bin

curl -fsSL \
  https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip \
  -o /tmp/awscliv2.zip

rm -rf /tmp/aws
unzip -q /tmp/awscliv2.zip -d /tmp

/tmp/aws/install \
  --install-dir /opt/nextflow/aws-cli \
  --bin-dir /opt/nextflow/bin

# Verify installation before completing cloud-init.
/opt/nextflow/bin/aws --version

rm -rf /tmp/aws /tmp/awscliv2.zip

--==NEXTFLOW==--
EOF
  )

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nextflow-batch"
  })
}