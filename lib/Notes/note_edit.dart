import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart' as prefix0;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:note_to_do_app/DataBase/ad_state.dart';
import '../DataBase/database.dart';
import '../Models/models.dart';

class EditNotePage extends StatefulWidget {
  Function() triggerRefetch;
  NotesModel existingNote;

  EditNotePage({Key key, Function() triggerRefetch, NotesModel existingNote})
      : super(key: key) {
    this.triggerRefetch = triggerRefetch;
    this.existingNote = existingNote;
  }

  @override
  _EditNotePageState createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  bool isDirty = false;
  bool isNoteNew = true;
  FocusNode titleFocus = FocusNode();
  FocusNode contentFocus = FocusNode();

  NotesModel currentNote;
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  InterstitialAd _interstitialAd;
  bool _isInterstitialAdReady = false;

  @override
  void initState() {
    _NoteState();
    _interstitialAd = InterstitialAd(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: AdRequest(),
      listener: AdListener(
        onAdClosed: (ad) {
          print("Closed Ad");
        },
        onAdOpened: (ad) {
          print("Opened Ad");
        },
      ),
    );
    _interstitialAd.load();
  }

  @override
  void _NoteState() {
    super.initState();
    if (widget.existingNote == null) {
      currentNote = NotesModel(
          content: '', title: '', date: DateTime.now(), isImportant: false);
      isNoteNew = true;
    } else {
      currentNote = widget.existingNote;
      isNoteNew = false;
    }
    titleController.text = currentNote.title;
    contentController.text = currentNote.content;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          ListView(
            children: <Widget>[
              SizedBox(
                height: 60,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextField(
                      focusNode: titleFocus,
                      autofocus: true,
                      controller: titleController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      onSubmitted: (text) {
                        titleFocus.unfocus();
                        FocusScope.of(context).requestFocus(contentFocus);
                      },
                      onChanged: (value) {
                        markTitleAsDirty(value);
                      },
                      textInputAction: TextInputAction.next,
                      style:
                          TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
                      decoration: InputDecoration.collapsed(
                        hintText: 'Enter A Title',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  focusNode: contentFocus,
                  controller: contentController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  onChanged: (value) {
                    markContentAsDirty(value);
                  },
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  decoration: InputDecoration.collapsed(
                    hintText: 'Start Typing...',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
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
                        onPressed: handleBack,
                      ),
                      Spacer(),
                      IconButton(
                        tooltip: 'Mark note as important',
                        icon: Icon(
                          currentNote.isImportant
                              ? Icons.flag
                              : Icons.outlined_flag,
                        ),
                        onPressed: titleController.text.trim().isNotEmpty &&
                                contentController.text.trim().isNotEmpty
                            ? markImportantAsDirty
                            : null,
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline),
                        onPressed: () {
                          handleDelete();
                        },
                      ),
                      AnimatedContainer(
                        margin: EdgeInsets.only(left: 10),
                        duration: Duration(milliseconds: 200),
                        width: isDirty ? 100 : 0,
                        height: 45,
                        curve: Curves.decelerate,
                        child: RaisedButton.icon(
                          color: Colors.blue,
                          textColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(100),
                              bottomLeft: Radius.circular(100),
                            ),
                          ),
                          icon: Icon(Icons.done),
                          label: Text(
                            'SAVE',
                            style: TextStyle(letterSpacing: 1),
                          ),
                          onPressed: () {
                            handleSave();
                            _interstitialAd.show();
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void handleSave() async {
    setState(() {
      currentNote.title = titleController.text;
      currentNote.content = contentController.text;
      print('Hey there ${currentNote.content}');
    });
    if (isNoteNew) {
      var latestNote = await NotesDatabaseService.db.addNoteInDB(currentNote);
      setState(() {
        currentNote = latestNote;
      });
    } else {
      await NotesDatabaseService.db.updateNoteInDB(currentNote);
    }
    setState(() {
      isNoteNew = false;
      isDirty = false;
    });
    widget.triggerRefetch();
    titleFocus.unfocus();
    contentFocus.unfocus();
  }

  void markTitleAsDirty(String title) {
    setState(() {
      isDirty = true;
    });
  }

  void markContentAsDirty(String content) {
    setState(() {
      isDirty = true;
    });
  }

  void markImportantAsDirty() {
    setState(() {
      currentNote.isImportant = !currentNote.isImportant;
    });
    handleSave();
  }

  void handleDelete() async {
    if (isNoteNew) {
      Navigator.pop(context);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Text('Delete Note'),
            content: Text('This note will be deleted permanently'),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'CANCEL',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text('DELETE',
                    style: prefix0.TextStyle(
                        color: Colors.red.shade300,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1)),
                onPressed: () async {
                  await NotesDatabaseService.db.deleteNoteInDB(currentNote);
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

  void handleBack() {
    Navigator.pop(context);
  }
}
