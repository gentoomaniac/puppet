node default {
  lookup('classes', Array[String], 'unique', []).include
  $ressources = lookup('ressources', Hash, 'deep', {})
  $ressources.each |$key, $value| {
    create_resources($key, $value)
  }
}
