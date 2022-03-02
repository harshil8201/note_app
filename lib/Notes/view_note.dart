import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:note_to_do_app/DataBase/ad_state.dart';
import 'package:share/share.dart';
import '../DataBase/database.dart';
import 'note_edit.dart';
import '../Models/models.dart';

class ViewNotePage extends StatefulWidget {
  Function() triggerRefetch;
  NotesModel currentNote;

  ViewNotePage({Key key, Function() triggerRefetch, NotesModel currentNote})
      : super(key: key) {
    this.triggerRefetch = triggerRefetch;
    this.currentNote = currentNote;
  }

  @override
  _ViewNotePageState createState() => _ViewNotePageState();
}

class _ViewNotePageState extends State<ViewNotePage> {

  RewardedAd _rewardedAd;
  bool _isRewardedAdReady = false;

  @override
  void initState() {
    _ShowHeader();
    _rewardedAd = RewardedAd(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: AdRequest(),
      listener: AdListener(
        onAdLoaded: (_) {
          setState(() {
            _isRewardedAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a rewarded ad: ${err.message}');
          _isRewardedAdReady = false;
          ad.dispose();
        },
        onAdClosed: (_) {
          setState(() {
            _isRewardedAdReady = false;
          });
          _rewardedAd.load();
        },
        // onRewardedAdUserEarnedReward: (_, reward) {
        //   QuizManager.instance.useHint();
        // },
      ),
    );
    _rewardedAd.load();
  }


  @override
  void _ShowHeader() {
    super.initState();
    showHeader();
  }

  void showHeader() async {
    Future.delayed(
      Duration(milliseconds: 100),
      () {
        setState(
          () {
            headerShouldShow = true;
          },
        );
      },
    );
  }

  bool headerShouldShow = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          ListView(
            physics: BouncingScrollPhysics(),
            children: <Widget>[
              SizedBox(
                height: 40,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 24.0,
                        right: 24.0,
                        top: 15.0,
                        bottom: 15.0,
                      ),
                      child: AnimatedOpacity(
                        opacity: headerShouldShow ? 1 : 0,
                        duration: Duration(milliseconds: 200),
                        curve: Curves.easeIn,
                        child: Text(
                          widget.currentNote.title.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 36,
                          ),
                          overflow: TextOverflow.visible,
                          softWrap: true,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                child: Row(
                  children: [
                    Spacer(),
                    AnimatedOpacity(
                      duration: Duration(milliseconds: 500),
                      opacity: headerShouldShow ? 1 : 0,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Text(
                          DateFormat.yMd()
                              .add_jm()
                              .format(widget.currentNote.date),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 24.0, top: 36, bottom: 24, right: 24),
                child: Text(
                  widget.currentNote.content,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            ],
          ),
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                height: 80,
                color: Theme.of(context).canvasColor.withOpacity(0.3),
                child: SafeArea(
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          handleBack();
                          _rewardedAd.show();
                        },
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(widget.currentNote.isImportant
                            ? Icons.flag
                            : Icons.outlined_flag),
                        onPressed: () {
                          markImportantAsDirty();
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline),
                        onPressed: handleDelete,
                      ),
                      IconButton(
                        icon: Icon(Icons.share),
                        onPressed: handleShare,
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          handleEdit();
                          _rewardedAd.show();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void handleSave() async {
    await NotesDatabaseService.db.updateNoteInDB(widget.currentNote);
    widget.triggerRefetch();
  }

  void markImportantAsDirty() {
    setState(
      () {
        widget.currentNote.isImportant = !widget.currentNote.isImportant;
      },
    );
    handleSave();
  }

  void handleEdit() {
    Navigator.pop(context);
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => EditNotePage(
          existingNote: widget.currentNote,
          triggerRefetch: widget.triggerRefetch,
        ),
      ),
    );
  }

  void handleShare() {
    Share.share(
        '${widget.currentNote.title.trim()}\n(On: ${widget.currentNote.date.toIso8601String().substring(0, 10)})\n\n${widget.currentNote.content}');
  }

  void handleBack() {
    Navigator.pop(context);
  }

  void handleDelete() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('Delete Note'),
          content: Text('This Note Will Be Deleted Permanently.'),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'CANCEL',
                style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text(
                'DELETE',
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1),
              ),
              onPressed: () async {
                await NotesDatabaseService.db
                    .deleteNoteInDB(widget.currentNote);
                widget.triggerRefetch();
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
