import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Models/models.dart';

List<Color> colorList = [
  Colors.blue,
];

class NoteCardComponent extends StatelessWidget {
  const NoteCardComponent({
    this.noteData,
    this.onTapAction,
    Key key,
  }) : super(key: key);

  final NotesModel noteData;
  final Function(NotesModel noteData) onTapAction;

  @override
  Widget build(BuildContext context) {
    String neatDate = DateFormat.yMd().add_jm().format(noteData.date);
    Color color = colorList.elementAt(noteData.title.length % colorList.length);
    return Container(
        margin: EdgeInsets.fromLTRB(10, 8, 10, 8),
        height: 115,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xff2196f3),
              const Color(0xff1976d2),
            ],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [buildBoxShadow(color, context)],
        ),
        child: Material(
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              onTapAction(noteData);
            },
            splashColor: color.withAlpha(20),
            highlightColor: color.withAlpha(10),
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: [
                      Text(
                        '${noteData.title.trim().toUpperCase().length <= 20 ? noteData.title.trim().toUpperCase() : noteData.title.trim().toUpperCase().substring(0, 20) + '...'}',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: noteData.isImportant
                              ? FontWeight.w800
                              : FontWeight.normal,
                        ),
                      ),
                      Spacer(),
                      Container(
                        child: Icon(
                          Icons.flag,
                          size: 25,
                          color: noteData.isImportant
                              ? Colors.white
                              : Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    child: Text(
                      '${noteData.content.trim().split('\n').first.length <= 30 ? noteData.content.trim().split('\n').first : noteData.content.trim().split('\n').first.substring(0, 30) + '...'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 14),
                    alignment: Alignment.centerRight,
                    child: Row(
                      children: <Widget>[
                        Spacer(),
                        Text(
                          '$neatDate',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }

  BoxShadow buildBoxShadow(Color color, BuildContext context) {
    return BoxShadow(
      color: noteData.isImportant == true
          ? color.withAlpha(150)
          : color.withAlpha(80),
      blurRadius: 8,
      offset: Offset(0, 10),
    );
  }
}

class AddNoteCardComponent extends StatelessWidget {
  const AddNoteCardComponent({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8, left: 70, right: 70, bottom: 10),
      height: 95,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColor, width: 2),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Material(
        borderRadius: BorderRadius.circular(25),
        clipBehavior: Clip.antiAlias,
        child: Container(
          padding: EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.add,
                      color: Theme.of(context).primaryColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Add Note',
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
