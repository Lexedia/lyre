abstract mixin class ToMap {
  Map<String, Object?> toMap();
}

mixin ToJson on ToMap {
  Map<String, Object?> toJson() => toMap();
}
