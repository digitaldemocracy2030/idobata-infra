variable "project_id" {
  description = "The project ID"
  type        = string
}

variable "region" {
  description = "The region to deploy resources"
  type        = string
}

variable "zone" {
  description = "The zone to deploy resources"
  type        = string
}

variable "env" {
  description = "The environment to deploy resources (short)"
  type        = string
}

variable "db" {
  description = "The database variables"
  type        = any
}

variable "redis" {
  description = "The redis variables"
  type        = any
}

variable "network" {
  description = "The network variables"
  type        = any
}

variable "app" {
  description = "The application variables"
  type        = any
}
