output "lambda_role_id" {
  value = aws_iam_role.lambda_role.id
}

output "lambda_function_invoke_arn" {
  value = aws_lambda_function.lambda_function.invoke_arn
}

output "lambda_function_name" {
  value = aws_lambda_function.lambda_function.function_name
}