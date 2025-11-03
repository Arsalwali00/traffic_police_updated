class DynamicFormResponse {
  final bool status;
  final List<DepartmentForm> forms;

  DynamicFormResponse({
    required this.status,
    required this.forms,
  });

  /// Convert JSON to `DynamicFormResponse`
  factory DynamicFormResponse.fromJson(Map<String, dynamic> json) {
    return DynamicFormResponse(
      status: json['status'] ?? false,
      forms: (json['data'] as List<dynamic>?)
          ?.map((form) => DepartmentForm.fromJson(form))
          .toList() ??
          [],
    );
  }

  /// Convert `DynamicFormResponse` to JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': forms.map((form) => form.toJson()).toList(),
    };
  }
}

class DepartmentForm {
  final int formId;
  final String departmentName;
  final String formName;
  final List<FormFieldAttribute> attributes;
  final List<FeeStructure> feeStructures;

  DepartmentForm({
    required this.formId,
    required this.departmentName,
    required this.formName,
    required this.attributes,
    required this.feeStructures,
  });

  /// Convert JSON to `DepartmentForm`
  factory DepartmentForm.fromJson(Map<String, dynamic> json) {
    return DepartmentForm(
      formId: json['form_id'] ?? 0,
      departmentName: json['department_name'] ?? "Unknown Department",
      formName: json['form_name'] ?? "Unnamed Form",
      attributes: (json['attributes'] as List<dynamic>?)
          ?.map((attr) => FormFieldAttribute.fromJson(attr))
          .toList() ??
          [],
      feeStructures: (json['fee_structures'] as List<dynamic>?)
          ?.map((fee) => FeeStructure.fromJson(fee))
          .toList() ??
          [],
    );
  }

  /// Convert `DepartmentForm` to JSON
  Map<String, dynamic> toJson() {
    return {
      'form_id': formId,
      'department_name': departmentName,
      'form_name': formName,
      'attributes': attributes.map((attr) => attr.toJson()).toList(),
      'fee_structures': feeStructures.map((fee) => fee.toJson()).toList(),
    };
  }
}

class FormFieldAttribute {
  final String attributeName;
  final String label;
  final String? urduLabel; // Added urduLabel field
  final String inputType;
  final String isRequired;
  final List<String> attributeList;
  final String? minLength; // Added minLength field
  final String? maxLength; // Added maxLength field
  final String? defaultValues; // Added defaultValues field

  FormFieldAttribute({
    required this.attributeName,
    required this.label,
    this.urduLabel,
    required this.inputType,
    required this.isRequired,
    required this.attributeList,
    this.minLength,
    this.maxLength,
    this.defaultValues,
  });

  /// Convert JSON to `FormFieldAttribute`
  factory FormFieldAttribute.fromJson(Map<String, dynamic> json) {
    List<String> parsedAttributeList = [];

    if (json['attribute_list'] is List) {
      parsedAttributeList = (json['attribute_list'] as List).map((e) {
        if (e is String) {
          return e;
        } else if (e is Map<String, dynamic> && e.containsKey('value')) {
          return e['value'].toString();
        }
        return '';
      }).where((e) => e.isNotEmpty).toList();
    }

    return FormFieldAttribute(
      attributeName: json['attribute_name'] ?? "",
      label: json['label'] ?? "",
      urduLabel: json['urdu_label'], // Parse urdu_label
      inputType: json['input_type'] ?? "Text",
      isRequired: json['is_required'] ?? "No",
      attributeList: parsedAttributeList,
      minLength: json['min_length']?.toString(), // Parse min_length as string
      maxLength: json['max_length']?.toString(), // Parse max_length as string
      defaultValues: json['default_values']?.toString(), // Parse default_values
    );
  }

  /// Convert `FormFieldAttribute` to JSON
  Map<String, dynamic> toJson() {
    return {
      'attribute_name': attributeName,
      'label': label,
      'urdu_label': urduLabel,
      'input_type': inputType,
      'is_required': isRequired,
      'attribute_list': attributeList.map((e) => {'value': e}).toList(),
      'min_length': minLength,
      'max_length': maxLength,
      'default_values': defaultValues,
    };
  }
}

class FeeStructure {
  final int feeStructureId;
  final String? title;
  final String? urduTitle;
  final String currency;
  final double amount;

  FeeStructure({
    required this.feeStructureId,
    required this.title,
    required this.urduTitle,
    required this.currency,
    required this.amount,
  });

  /// Convert JSON to `FeeStructure`
  factory FeeStructure.fromJson(Map<String, dynamic> json) {
    return FeeStructure(
      feeStructureId: json['fee_structure_id'] ?? 0,
      title: json['title'],
      urduTitle: json['urdu_title'],
      currency: json['currency'] ?? "",
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Convert `FeeStructure` to JSON
  Map<String, dynamic> toJson() {
    return {
      'fee_structure_id': feeStructureId,
      'title': title,
      'urdu_title': urduTitle,
      'currency': currency,
      'amount': amount,
    };
  }
}