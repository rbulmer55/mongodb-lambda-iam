output "rest_api_id" {
  value = aws_api_gateway_rest_api.this.id
}

output "api_gateway_stage" {
  value = aws_api_gateway_stage.stage.stage_name
}
