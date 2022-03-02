import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:note_to_do_app/DataBase/ad_state.dart';
import '../Notes/view_note.dart';
import 'list_home_note.dart';
import '../DataBase/database.dart';
import '../Notes/note_edit.dart';
import '../Models/animation_fade.dart';
import '../Models/models.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key key,
    this.title,
  }) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isFlagOn = false;
  bool headerShouldHide = false;
  List<NotesModel> notesList = [];
  TextEditingController searchController = TextEditingController();

  bool isSearchEmpty = true;

  BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    _DataBase();
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.banner,
      listener: AdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );
    _bannerAd.load();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  void _DataBase() {
    super.initState();
    NotesDatabaseService.db.init();
    setNotesFromDB();
  }

  setNotesFromDB() async {
    print("Entered setNotes");
    var fetchedNotes = await NotesDatabaseService.db.getNotesFromDB();
    setState(() {
      notesList = fetchedNotes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'NOTES',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 25,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 13, top: 6, bottom: 6),
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                color: Colors.white,
                borderRadius: BorderRadius.circular(10)
              ),
              child: Padding(
                  padding: EdgeInsets.only(right: 2, left: 2),
                  child: GestureDetector(
                    onTap: () {
                      gotoEditNote();
                    },
                    child: Icon(
                      Icons.add,
                      size: 35.0,
                      color: Colors.blue,
                    ),
                  )
              ),
            ),
          ),
        ],
      ),
     // // floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
     //  floatingActionButton: FloatingActionButton(
     //    backgroundColor: Colors.blue,
     //    shape: RoundedRectangleBorder(
     //      borderRadius: BorderRadius.all(Radius.circular(16.0)),
     //      side: BorderSide(color: Colors.black, width: 4.0),
     //    ),
     //    onPressed: () {
     //      gotoEditNote();
     //    },
     //    child: const Icon(
     //      Icons.add,
     //    ),
     //  ),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              child: ListView(
                physics: BouncingScrollPhysics(),
                children: <Widget>[
                  buildHeaderWidget(context),
                  SizedBox(height: 15),
                  buildButtonRow(),
                  buildImportantIndicatorText(),
                  SizedBox(height: 10),
                  ...buildNoteComponentsList(),
                  GestureDetector(
                    onTap: gotoEditNote,
                    child: AddNoteCardComponent(),
                  ),
                  SizedBox(height: 100)
                ],
              ),
              margin: EdgeInsets.only(top: 0.5),
              padding: EdgeInsets.only(left: 15, right: 15),
            ),
          ),
          if (_isBannerAdReady)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: _bannerAd.size.width.toDouble(),
                height: _bannerAd.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildButtonRow() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              setState(() {
                isFlagOn = !isFlagOn;
              });
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 160),
              height: 50,
              width: 50,
              curve: Curves.slowMiddle,
              child: Icon(
                isFlagOn ? Icons.flag : Icons.outlined_flag,
                color: isFlagOn ? Colors.white : Colors.blue,
              ),
              decoration: BoxDecoration(
                color: isFlagOn ? Colors.blue : Colors.transparent,
                border: Border.all(
                  width: isFlagOn ? 2 : 2,
                  color: isFlagOn ? Colors.blue : Colors.black,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(16),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(left: 8),
              padding: EdgeInsets.only(left: 16),
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      maxLines: 1,
                      onChanged: (value) {
                        handleSearch(value);
                      },
                      autofocus: false,
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration.collapsed(
                        hintText: 'Search',
                        hintStyle: TextStyle(
                          color: Colors.blue,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isSearchEmpty ? Icons.search : Icons.cancel,
                      color: Colors.blue,
                    ),
                    onPressed: cancelSearch,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildHeaderWidget(BuildContext context) {
    return Row(
      children: <Widget>[
        AnimatedContainer(
          duration: Duration(milliseconds: 200),
          curve: Curves.easeIn,
          margin: EdgeInsets.only(
            top: 15,
          ),
          width: headerShouldHide ? 0 : 200,
        ),
      ],
    );
  }

  Widget testListItem(Color color) {
    return new NoteCardComponent(
      noteData: NotesModel.random(),
    );
  }

  Widget buildImportantIndicatorText() {
    return AnimatedCrossFade(
      duration: Duration(milliseconds: 200),
      firstChild: Padding(
        padding: const EdgeInsets.only(top: 10, left: 10),
        child: Text(
          'important notes'.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            color: Colors.blue,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      secondChild: Container(
        height: 2,
      ),
      crossFadeState:
          isFlagOn ? CrossFadeState.showFirst : CrossFadeState.showSecond,
    );
  }

  List<Widget> buildNoteComponentsList() {
    List<Widget> noteComponentsList = [];
    notesList.sort((a, b) {
      return b.date.compareTo(a.date);
    });
    if (searchController.text.isNotEmpty) {
      notesList.forEach(
        (note) {
          if (note.title
                  .toLowerCase()
                  .contains(searchController.text.toLowerCase()) ||
              note.content
                  .toLowerCase()
                  .contains(searchController.text.toLowerCase()))
            noteComponentsList.add(
              NoteCardComponent(
                noteData: note,
                onTapAction: openNoteToRead,
              ),
            );
        },
      );
      return noteComponentsList;
    }
    if (isFlagOn) {
      notesList.forEach(
        (note) {
          if (note.isImportant)
            noteComponentsList.add(
              NoteCardComponent(
                noteData: note,
                onTapAction: openNoteToRead,
              ),
            );
        },
      );
    } else {
      notesList.forEach(
        (note) {
          noteComponentsList.add(
            NoteCardComponent(
              noteData: note,
              onTapAction: openNoteToRead,
            ),
          );
        },
      );
    }
    return noteComponentsList;
  }

  void handleSearch(String value) {
    if (value.isNotEmpty) {
      setState(
        () {
          isSearchEmpty = false;
        },
      );
    } else {
      setState(
        () {
          isSearchEmpty = true;
        },
      );
    }
  }

  void gotoEditNote() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => EditNotePage(triggerRefetch: refetchNotesFromDB),
      ),
    );
  }

  void refetchNotesFromDB() async {
    await setNotesFromDB();
    print("Refetched notes");
  }

  openNoteToRead(NotesModel noteData) async {
    setState(
      () {
        headerShouldHide = true;
      },
    );
    await Future.delayed(Duration(milliseconds: 230), () {});
    Navigator.push(
      context,
      FadeRoute(
        page: ViewNotePage(
            triggerRefetch: refetchNotesFromDB, currentNote: noteData),
      ),
    );
    await Future.delayed(Duration(milliseconds: 300), () {});

    setState(
      () {
        headerShouldHide = false;
      },
    );
  }

  void cancelSearch() {
    FocusScope.of(context).requestFocus(
      new FocusNode(),
    );
    setState(
      () {
        searchController.clear();
        isSearchEmpty = true;
      },
    );
  }
}
