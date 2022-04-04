resource "random_id" "id" {
  byte_length = 8
}

resource "aws_wafv2_web_acl" "rate-limit" {
  name        = "appsync-rate-limiting-${random_id.id.hex}"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "rate-limit"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 6000
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "friendly-rule-metric-name"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "friendly-metric-name"
    sampled_requests_enabled   = false
  }
}

resource "aws_wafv2_web_acl_association" "appsync" {
  resource_arn = aws_appsync_graphql_api.appsync.arn
  web_acl_arn  = aws_wafv2_web_acl.rate-limit.arn
}
