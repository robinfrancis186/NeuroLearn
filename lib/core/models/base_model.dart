abstract class BaseModel {
  Map<String, dynamic> toJson();
  
  @override
  String toString() {
    return toJson().toString();
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaseModel && toString() == other.toString();
  }
  
  @override
  int get hashCode => toString().hashCode;
} 