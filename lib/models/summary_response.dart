/// Summary block containing overview, action items, and decisions
class SummaryBlock {
  final String shortOverview;
  final List<String> actionItems;
  final List<String> decisions;

  SummaryBlock({
    required this.shortOverview,
    required this.actionItems,
    required this.decisions,
  });

  factory SummaryBlock.fromJson(Map<String, dynamic> json) {
    return SummaryBlock(
      shortOverview: json['short_overview'] as String,
      actionItems: (json['action_items'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      decisions: (json['decisions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }
}

/// Summary response from POST /summary endpoint
class SummaryResponse {
  final SummaryBlock summary;

  SummaryResponse({required this.summary});

  factory SummaryResponse.fromJson(Map<String, dynamic> json) {
    return SummaryResponse(
      summary: SummaryBlock.fromJson(json['summary'] as Map<String, dynamic>),
    );
  }
}

