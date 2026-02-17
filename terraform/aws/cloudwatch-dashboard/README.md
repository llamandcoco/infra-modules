# CloudWatch Dashboard Module

A Terraform module for creating customizable CloudWatch Dashboards with support for metrics, logs, alarms, and text widgets.

## Features

- Flexible Widget Configuration Support for metric, log, text, and alarm widgets
- Multiple Metric Sources AWS services, custom namespaces, and cross-account metrics
- Log Insights Integration CloudWatch Logs Insights query widgets
- Annotations & Thresholds Horizontal/vertical threshold lines with color-coded warnings
- Auto URL Generation Direct console links for easy access
- Widget Positioning Flexible grid layout (24 columns)

## Quick Start

```hcl
module "dashboard" {
  source = "github.com/llamandcoco/infra-modules//terraform/cloudwatch-dashboard?ref=<commit-sha>"

  dashboard_name = "my-application-dashboard"

  widgets = [
    {
      type = "metric"
      properties = {
        title  = "Lambda Invocations"
        region = "us-east-1"
        metrics = [
          ["AWS/Lambda", "Invocations", { stat = "Sum" }]
        ]
        view   = "timeSeries"
        period = 300
      }
      width  = 12
      height = 6
      x      = 0
      y      = 0
    }
  ]
}
```

## Examples

Complete, tested configurations in [`tests/`](tests/):

| Example | Directory | Description |
|---------|-----------|-------------|
| Basic | [`tests/basic/main.tf`](tests/basic/main.tf) | Simple Lambda metrics dashboard |
| Pipeline | [`tests/pipeline/main.tf`](tests/pipeline/main.tf) | Multi-component pipeline monitoring |
| Custom Metrics | [`tests/custom-metrics/main.tf`](tests/custom-metrics/main.tf) | Custom CloudWatch metrics |

**Usage:**
```bash
# View example
cat tests/basic/main.tf

# Copy and adapt
cp -r tests/basic/ my-project/
```

## Testing

```bash
cd tests/basic && terraform init && terraform plan
```

## Widget Types

### Metric Widget
Display CloudWatch metrics as time series, numbers, or gauges.

### Log Widget
Display CloudWatch Logs Insights query results.

### Text Widget
Display markdown-formatted text, links, and documentation.

### Alarm Widget
Display CloudWatch alarm status.

See [`tests/`](tests/) for complete examples of each widget type.

## Cost Considerations

- **First 3 dashboards**: Free
- **Additional dashboards**: $3/month per dashboard
- Custom metrics used in widgets are charged separately

<details>
<summary>Terraform Documentation</summary>

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.27.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_dashboard.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_dashboard) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dashboard_name"></a> [dashboard\_name](#input\_dashboard\_name) | Name of the CloudWatch dashboard. Must be unique within the AWS region. | `string` | n/a | yes |
| <a name="input_widgets"></a> [widgets](#input\_widgets) | List of widget configurations for the dashboard.<br/>Each widget must include: type, properties, width, height, x, y.<br/><br/>Widget types:<br/>- metric: Display CloudWatch metrics<br/>- log: Display CloudWatch Logs Insights queries<br/>- text: Display markdown text<br/>- alarm: Display CloudWatch alarms<br/><br/>Example:<pre>widgets = [<br/>  {<br/>    type = "metric"<br/>    properties = {<br/>      title = "Lambda Invocations"<br/>      region = "us-east-1"<br/>      metrics = [<br/>        ["AWS/Lambda", "Invocations", { stat = "Sum" }]<br/>      ]<br/>      view = "timeSeries"<br/>      period = 300<br/>    }<br/>    width = 12<br/>    height = 6<br/>    x = 0<br/>    y = 0<br/>  }<br/>]</pre> | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dashboard_arn"></a> [dashboard\_arn](#output\_dashboard\_arn) | ARN of the CloudWatch dashboard |
| <a name="output_dashboard_name"></a> [dashboard\_name](#output\_dashboard\_name) | Name of the CloudWatch dashboard |
| <a name="output_dashboard_url"></a> [dashboard\_url](#output\_dashboard\_url) | Direct URL to access the dashboard in AWS Console |
<!-- END_TF_DOCS -->

</details>
