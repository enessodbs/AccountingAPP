class LeadModel {
  final String id;
  final String companyName;
  final String contactPerson;
  final String email;
  final String phone;
  final int status;
  final String statusName;
  final int source;
  final String sourceName;
  final double estimatedValue;
  final int score;
  final String? assignedToName;
  final DateTime createdAt;

  LeadModel({
    required this.id,
    required this.companyName,
    required this.contactPerson,
    required this.email,
    required this.phone,
    required this.status,
    required this.statusName,
    required this.source,
    required this.sourceName,
    required this.estimatedValue,
    required this.score,
    this.assignedToName,
    required this.createdAt,
  });

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    return LeadModel(
      id: json['id'] ?? '',
      companyName: json['companyName'] ?? '',
      contactPerson: json['contactPerson'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      status: json['status'] ?? 0,
      statusName: json['statusName'] ?? '',
      source: json['source'] ?? 0,
      sourceName: json['sourceName'] ?? '',
      estimatedValue: (json['estimatedValue'] ?? 0).toDouble(),
      score: json['score'] ?? 0,
      assignedToName: json['assignedToName'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyName': companyName,
      'contactPerson': contactPerson,
      'email': email,
      'phone': phone,
      'status': status,
      'statusName': statusName,
      'source': source,
      'sourceName': sourceName,
      'estimatedValue': estimatedValue,
      'score': score,
      'assignedToName': assignedToName,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class OpportunityModel {
  final String id;
  final String title;
  final String description;
  final double amount;
  final int probability;
  final double weightedAmount;
  final DateTime? expectedCloseDate;
  final DateTime? actualCloseDate;
  final bool isWon;
  final String lostReason;
  final String contactName;
  final String ownerName;
  final String stageName;
  final String stageColor;
  final int stageId;
  final String? sourceLeadCompany;
  final DateTime createdAt;

  OpportunityModel({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.probability,
    required this.weightedAmount,
    this.expectedCloseDate,
    this.actualCloseDate,
    required this.isWon,
    required this.lostReason,
    required this.contactName,
    required this.ownerName,
    required this.stageName,
    required this.stageColor,
    required this.stageId,
    this.sourceLeadCompany,
    required this.createdAt,
  });

  factory OpportunityModel.fromJson(Map<String, dynamic> json) {
    return OpportunityModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      probability: json['probability'] ?? 0,
      weightedAmount: (json['weightedAmount'] ?? 0).toDouble(),
      expectedCloseDate: json['expectedCloseDate'] != null
          ? DateTime.parse(json['expectedCloseDate'])
          : null,
      actualCloseDate: json['actualCloseDate'] != null
          ? DateTime.parse(json['actualCloseDate'])
          : null,
      isWon: json['isWon'] ?? false,
      lostReason: json['lostReason'] ?? '',
      contactName: json['contactName'] ?? '',
      ownerName: json['ownerName'] ?? '',
      stageName: json['stageName'] ?? '',
      stageColor: json['stageColor'] ?? '#607D8B',
      stageId: json['stageId'] ?? 0,
      sourceLeadCompany: json['sourceLeadCompany'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'probability': probability,
      'weightedAmount': weightedAmount,
      'expectedCloseDate': expectedCloseDate?.toIso8601String(),
      'actualCloseDate': actualCloseDate?.toIso8601String(),
      'isWon': isWon,
      'lostReason': lostReason,
      'contactName': contactName,
      'ownerName': ownerName,
      'stageName': stageName,
      'stageColor': stageColor,
      'stageId': stageId,
      'sourceLeadCompany': sourceLeadCompany,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class PipelineStageModel {
  final int id;
  final String name;
  final int order;
  final String color;
  final bool isDefault;
  final bool isClosedWon;
  final bool isClosedLost;
  final int opportunityCount;

  PipelineStageModel({
    required this.id,
    required this.name,
    required this.order,
    required this.color,
    required this.isDefault,
    required this.isClosedWon,
    required this.isClosedLost,
    required this.opportunityCount,
  });

  factory PipelineStageModel.fromJson(Map<String, dynamic> json) {
    return PipelineStageModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      order: json['order'] ?? 0,
      color: json['color'] ?? '#607D8B',
      isDefault: json['isDefault'] ?? false,
      isClosedWon: json['isClosedWon'] ?? false,
      isClosedLost: json['isClosedLost'] ?? false,
      opportunityCount: json['opportunityCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'order': order,
      'color': color,
      'isDefault': isDefault,
      'isClosedWon': isClosedWon,
      'isClosedLost': isClosedLost,
      'opportunityCount': opportunityCount,
    };
  }
}

class PipelineBoardColumn {
  final int stageId;
  final String stageName;
  final String stageColor;
  final int stageOrder;
  final List<OpportunityModel> opportunities;

  PipelineBoardColumn({
    required this.stageId,
    required this.stageName,
    required this.stageColor,
    required this.stageOrder,
    required this.opportunities,
  });

  factory PipelineBoardColumn.fromJson(Map<String, dynamic> json) {
    return PipelineBoardColumn(
      stageId: json['stageId'] ?? 0,
      stageName: json['stageName'] ?? '',
      stageColor: json['stageColor'] ?? '#607D8B',
      stageOrder: json['stageOrder'] ?? 0,
      opportunities: (json['opportunities'] as List<dynamic>?)
              ?.map((item) => OpportunityModel.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stageId': stageId,
      'stageName': stageName,
      'stageColor': stageColor,
      'stageOrder': stageOrder,
      'opportunities': opportunities.map((o) => o.toJson()).toList(),
    };
  }
}
