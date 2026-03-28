node default {
  class { 'docker':
    manage_package             => false,
    acknowledge_unsupported_os => true,
  }

  lookup('classes', Array[String], 'unique', []).include
  $ressources = lookup('ressources', Hash, 'deep', {})
  $ressources.each |$key, $value| {
    create_resources($key, $value)
  }
}
