import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:subtitle_wrapper_package/subtitle_wrapper_package.dart';
import 'package:video_player/video_player.dart';

part 'subtitle_event.dart';
part 'subtitle_state.dart';

class SubtitleBloc extends Bloc<SubtitleEvent, SubtitleState> {
  final VideoPlayerController videoPlayerController;
  final SubtitleRepository subtitleRepository;
  final SubtitleController subtitleController;

  Subtitles subtitles;

  SubtitleBloc({
    @required this.videoPlayerController,
    @required this.subtitleRepository,
    @required this.subtitleController,
  }) : super(SubtitleInitial()) {
    subtitleController.attach(this);
  }

  @override
  Future<void> close() {
    subtitleController.detach();
    return super.close();
  }
  
  @override
  Stream<SubtitleState> mapEventToState(SubtitleEvent event) async*  {
    if (event is LoadSubtitle) {
      yield* loadSubtitle();
    } else if (event is InitSubtitles) {
      yield* initSubtitles();
    } else if (event is UpdateLoadedSubtitle) {
      yield LoadedSubtitle(event.subtitle);
    }else if(event is CompletedShowingSubtitles){
       yield CompletedSubtitle();
    }else if(event is UpdateLoadedSubtitle){
      yield LoadedSubtitle(event.subtitle);
    }
  }

   Stream<SubtitleState> initSubtitles() async* {
    yield SubtitleInitializing();
    subtitles = await subtitleRepository.getSubtitles();
    yield SubtitleInitialized();
  }

  Stream<SubtitleState> loadSubtitle() async* {
    yield LoadingSubtitle();
    videoPlayerController.addListener(
      () {
        final videoPlayerPosition = videoPlayerController.value.position;
        if (videoPlayerPosition.inMilliseconds >
            subtitles.subtitles.last.endTime.inMilliseconds) {
          add(CompletedShowingSubtitles());
        }
        for (final Subtitle subtitleItem in subtitles.subtitles) {
          final bool validStartTime = videoPlayerPosition.inMilliseconds >
              subtitleItem.startTime.inMilliseconds;
          final bool validEndTime = videoPlayerPosition.inMilliseconds <
              subtitleItem.endTime.inMilliseconds;
          if (validStartTime && validEndTime) {
            add(
              UpdateLoadedSubtitle(
                subtitle: subtitleItem,
              ),
            );
          }
        }
      },
    );
  }
}
