class DynamicFormResponse {
  final bool status;
  final List<DepartmentForm> forms;

  DynamicFormResponse({
    required this.status,
    required this.forms,
  });

  /// ✅ Convert JSON to `DynamicFormResponse`
  factory DynamicFormResponse.fromJson(Map<String, dynamic> json) {
    return DynamicFormResponse(
      status: json['status'] ?? false,
      forms: (json['data'] as List<dynamic>?)
          ?.map((form) => DepartmentForm.fromJson(form))
          .toList() ??
          [],
    );
  }

  /// ✅ Convert `DynamicFormResponse` to JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': forms.map((form) => form.toJson()).toList(),
    };
  }
}

class DepartmentForm {
  final String departmentName;
  final String formName;
  final String status;
  final List<FormFieldAttribute> attributes;

  DepartmentForm({
    required this.departmentName,
    required this.formName,
    required this.status,
    required this.attributes,
  });

  /// ✅ Convert JSON to `DepartmentForm`
  factory DepartmentForm.fromJson(Map<String, dynamic> json) {
    return DepartmentForm(
      departmentName: json['department_name'] ?? "",
      formName: json['form_name'] ?? "",
      status: json['status'] ?? "",
      attributes: (json['attributes'] as List<dynamic>?)
          ?.map((attr) => FormFieldAttribute.fromJson(attr))
          .toList() ??
          [],
    );
  }

  /// ✅ Convert `DepartmentForm` to JSON
  Map<String, dynamic> toJson() {
    return {
      'department_name': departmentName,
      'form_name': formName,
      'status': status,
      'attributes': attributes.map((attr) => attr.toJson()).toList(),
    };
  }
}

class FormFieldAttribute {
  final String attributeName;
  final String label;
  final String inputType;
  final String size;
  final String margin;
  final String? defaultValue;
  final String isRequired;
  final String status;
  final List<dynamic> attributeList;

  FormFieldAttribute({
    required this.attributeName,
    required this.label,
    required this.inputType,
    required this.size,
    required this.margin,
    required this.defaultValue,
    required this.isRequired,
    required this.status,
    required this.attributeList,
  });

  /// ✅ Convert JSON to `FormFieldAttribute`
  factory FormFieldAttribute.fromJson(Map<String, dynamic> json) {
    return FormFieldAttribute(
      attributeName: json['attribute_name'] ?? "",
      label: json['label'] ?? "",
      inputType: json['input_type'] ?? "",
      size: json['size'] ?? "",
      margin: json['margin'] ?? "",
      defaultValue: json['default_values'],
      isRequired: json['is_required'] ?? "No",
      status: json['status'] ?? "Disabled",
      attributeList: json['attribute_list'] ?? [],
    );
  }

  /// ✅ Convert `FormFieldAttribute` to JSON
  Map<String, dynamic> toJson() {
    return {
      'attribute_name': attributeName,
      'label': label,
      'input_type': inputType,
      'size': size,
      'margin': margin,
      'default_values': defaultValue,
      'is_required': isRequired,
      'status': status,
      'attribute_list': attributeList,
    };
  }
}
