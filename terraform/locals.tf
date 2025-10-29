locals {
  tags = merge(var.tags,{
    Name = var.project_name
  })
}