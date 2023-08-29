/*
resource "aws_route53_zone" "issue_tracker" {
  name = "www.trackitall.org"


}

resource "aws_route53_record" "issue_tracker_A_record" {
  name    = "www.trackitall.org"
  type    = "A"
  zone_id = aws_route53_zone.issue_tracker.zone_id

  alias {
    name                   = aws_lb.issue_tracker_lb.dns_name
    zone_id                = aws_lb.issue_tracker_lb.zone_id
    evaluate_target_health = true
  }
}
*/
