node default {
  lookup('classes', Array[String], 'unique').include
  $ressources = lookup('ressources', {})
  $ressources.each |$key, $value| {
    create_resources($key, $value)
  }
}
