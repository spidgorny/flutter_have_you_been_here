import "dart:io";

import "package:yaml/yaml.dart";

main() {
  File file = new File('pubspec.yaml');
  String yamlString = file.readAsStringSync();
  Map yaml = loadYaml(yamlString);
  String version = yaml['version'];
  print(version);

  var parts = version.split('+');
  //print(parts);

  var verParts = parts[0].split('.');
  verParts[2] = (int.parse(verParts[2]) + 1).toString();
  parts[0] = verParts.join('.');

  parts[1] = (int.parse(parts[1]) + 1).toString();
  var versionPlus1 = parts.join('+');
  print(versionPlus1);

  yamlString = yamlString.replaceFirst(version, versionPlus1);
  //print(yamlString);

  file.writeAsStringSync(yamlString);
}
