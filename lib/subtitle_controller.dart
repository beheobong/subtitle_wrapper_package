import 'package:flutter/material.dart';
import 'package:subtitle_wrapper_package/bloc/subtitle/subtitle_bloc.dart';

class SubtitleController {
  String subtitlesContent;
  String subtitleUrl;
  bool showSubtitles;
  SubtitleDecoder subtitleDecoder;
  SubtitleType subtitleType;
  //
  bool _attached = false;
  SubtitleBloc _subtitleBloc;

  SubtitleController({
    this.subtitleUrl,
    this.subtitlesContent,
    this.showSubtitles = true,
    this.subtitleDecoder,
    this.subtitleType = SubtitleType.webvtt,
  });

  void attach(SubtitleBloc subtitleBloc) {
    _subtitleBloc = subtitleBloc;
    _attached = true;
  }

  void detach() {
    _attached = false;
    _subtitleBloc = null;
  }

  void updateSubtitleUrl({
    @required String url,
  }) {
    if (_attached) {
      subtitleUrl = url;
      _subtitleBloc.add(
        InitSubtitles(
          subtitleController: this,
        ),
      );
    } else {
      throw Exception('Seems that the controller is not correctly attached.');
    }
  }

  void toggleSubtitles(bool value) {
    if (value != null) {
      showSubtitles = value;
    }
  }

  void updateSubtitleContent({
    @required String content,
  }) {
    if (_attached) {
      subtitlesContent = content;
      _subtitleBloc.add(
        InitSubtitles(
          subtitleController: this,
        ),
      );
    } else {
      throw Exception('Seems that the controller is not correctly attached.');
    }
  }
}

enum SubtitleDecoder {
  utf8,
  latin1,
}

enum SubtitleType {
  webvtt,
  srt,
}
