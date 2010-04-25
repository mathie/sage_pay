# Changelog

## 0.2.4

* Generate the appropriate response.

## 0.2.3

* yield for the signature verification details if there's a block given in the
  notification.

## 0.2.2

* Incorporate additional fields I'd missed from the notification. That'll make
  it easier to find payments from the notification.

## 0.2.1

* [FIX] SagePay think it's OK to have curly braces in a URL query string.
  Ruby's URI library thinks otherwise. No matter who's right, one of these is
  easier to change than the other.

## 0.2.0

* Initial release. This should support the full workflow for making payments,
  but the notification side hasn't been tested again SagePay in the wild so
  you mileage probably will vary.
