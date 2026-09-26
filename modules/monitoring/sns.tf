resource "aws_sns_topic" "user_updates" {
  name = "user-updates"
}

resource "aws_sqs_queue" "user_updates_queue" {
  name   = "user-updates-queue"
  policy = data.aws_iam_policy_document.sqs_queue_policy.json
}

resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = aws_sns_topic.user_updates.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.user_updates_queue.arn
}

data "aws_iam_policy_document" "sqs_queue_policy" {
  policy_id = "arn:aws:sqs:${var.region}:${var.account_id}:user_updates_queue/SQSDefaultPolicy"

  statement {
    sid    = "user_updates_sqs_target"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    actions = [
      "SQS:SendMessage",
    ]

    resources = [
      "arn:aws:sqs:${var.region}:${var.account_id}:user-updates-queue",
    ]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"

      values = [
        aws_sns_topic.user_updates.arn,
      ]
    }
  }
}