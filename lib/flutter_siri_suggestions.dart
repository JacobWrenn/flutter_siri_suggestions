import 'dart:async';
import 'package:flutter/services.dart';

typedef Future<dynamic> MessageHandler(Map<String, dynamic> message);

class FlutterSiriActivity {
  const FlutterSiriActivity(
    this.title, {
    this.contentDescription,
    this.isEligibleForSearch = true,
    this.isEligibleForPrediction = true,
    this.suggestedInvocationPhrase,
    this.persistentIdentifier,
    this.userInfo,
  })  : assert(title != null),
        super();

  final String title;
  final String contentDescription;
  final bool isEligibleForSearch;
  final bool isEligibleForPrediction;
  final String suggestedInvocationPhrase;
  final String persistentIdentifier;
  final Map userInfo;
}

class FlutterSiriSuggestions {
  FlutterSiriSuggestions._();

  /// Singleton of [FlutterSiriSuggestions].
  static final FlutterSiriSuggestions instance = FlutterSiriSuggestions._();

  // FlutterSiriShortcuts(this.title,
  //     {this.contentDescription,
  //     this.isEligibleForSearch = true,
  //     this.isEligibleForPrediction = true,
  //     this.suggestedInvocationPhrase})
  //     : assert(title != null),
  //       super();

  MessageHandler _onLaunch;
  Map<String, dynamic> mostRecentLaunch;

  static const MethodChannel _channel =
      const MethodChannel('flutter_siri_suggestions');

  void buildActivity(FlutterSiriActivity activity) async {
    await _channel.invokeMethod('becomeCurrent', <String, Object>{
      'title': activity.title,
      'contentDescription': activity.contentDescription,
      'isEligibleForSearch': activity.isEligibleForSearch,
      'isEligibleForPrediction': activity.isEligibleForPrediction,
      'suggestedInvocationPhrase': activity.suggestedInvocationPhrase ?? "",
      'persistentIdentifier': activity.persistentIdentifier ?? activity.title,
      'userInfo': activity.userInfo ?? {},
    });
  }

  void configure({MessageHandler onLaunch}) {
    _onLaunch = onLaunch;
    _channel.setMethodCallHandler(_handleMethod);
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "onLaunch":
        mostRecentLaunch = call.arguments.cast<String, dynamic>();
        return _onLaunch(call.arguments.cast<String, dynamic>());
      default:
        throw UnsupportedError("Unrecognized JSON message");
    }
  }
}
