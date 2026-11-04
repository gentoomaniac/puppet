node default {
  lookup('classes', Array[String], 'unique', []).include
  $resources = lookup('resources', Hash, 'deep', {})
  $resources.each |$key, $value| {
    create_resources($key, $value)
  }
}
