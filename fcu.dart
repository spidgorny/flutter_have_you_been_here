import "dart:io";

import "package:yaml/yaml.dart";

main() {
  File file = new File('pubspec.yaml');
  String yamlString = file.readAsStringSync();
  Map yaml = loadYaml(yamlString);
  YamlMap dependencies = yaml['dependencies'];
//  print(dependencies);

  for (var key in dependencies.keys) {
    var version = dependencies[key];
    if (version is String) {
      print(key + ':' + version);
    }
  }
}
