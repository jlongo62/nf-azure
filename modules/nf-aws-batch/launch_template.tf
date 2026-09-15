resource "aws_launch_template" "nextflow_batch" {
  name_prefix = "${var.name_prefix}-nextflow-"

  user_data = base64encode(<<-EOF
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==NEXTFLOW=="

--==NEXTFLOW==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
set -euxo pipefail

# Do not let this instance register with ECS until Nextflow's
# host-side AWS CLI is ready.
systemctl stop ecs || true

dnf install -y unzip curl

rm -rf /opt/nextflow
mkdir -p /opt/nextflow

curl -fsSL \
  https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip \
  -o /tmp/awscliv2.zip

rm -rf /tmp/aws
unzip -q /tmp/awscliv2.zip -d /tmp

/tmp/aws/install \
  --install-dir /opt/nextflow/aws-cli \
  --bin-dir /opt/nextflow/bin

/opt/nextflow/bin/aws --version

rm -rf /tmp/aws /tmp/awscliv2.zip

# Only advertise this instance to ECS/Batch after installation succeeds.
systemctl start ecs

--==NEXTFLOW==--
EOF
  )
}