output "asg" {
  value = "${aws_autoscaling_group.my_asg.id}"
}
