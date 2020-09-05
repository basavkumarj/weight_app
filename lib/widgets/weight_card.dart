import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weight/bloc/dash_bloc.dart';
import 'package:weight/other/query_tags.dart';
import 'package:weight/other/utility.dart';

class WeightCard extends StatelessWidget {
  final DocumentSnapshot data;
  final DashboardBloc bloc;
  final BuildContext context;

  WeightCard(this.data, this.bloc, this.context);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Dismissible(
          key: ValueKey(data.documentID),
          background: Container(
            color: Colors.red,
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Icon(Icons.delete),
            ),
            alignment: Alignment.centerRight,
          ),
          direction: DismissDirection.endToStart,
          onDismissed: ((direction) {
            if (direction == DismissDirection.endToStart) {
              bloc.deleteData(data.documentID);
              bloc.updateList();
            }
          }),
          child: GestureDetector(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
              width: double.maxFinite,
              color: Colors.white,
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(data[QueryTags.qWeight].toString(),
                          style: GoogleFonts.dmSans(
                              textStyle: TextStyle(fontSize: 25.0))),
                      Text("kg",
                          style: GoogleFonts.dmSans(
                              color: Colors.black54,
                              textStyle: TextStyle(fontSize: 15.0))),
                    ],
                  ),
                  Text(
                      data[QueryTags.qDateTime] != null
                          ? Utility.firestoreDTFormat(data[QueryTags.qDateTime])
                          : "waiting to sync",
                      style: GoogleFonts.dmSans(
                          textStyle: TextStyle(
                              fontSize: 10.0, fontStyle: FontStyle.italic))),
                ],
              ),
            ),
            onDoubleTap: () {
              showDialog(
                  context: this.context,
                  builder: (BuildContext context) {
                    final _editFormKey = GlobalKey<FormState>();
                    double _newWeight;
                    return SimpleDialog(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16.0),
                          color: Colors.white,
                          child: Form(
                            key: _editFormKey,
                            child: Column(
                              children: [
                                Text("Edit Weight",
                                    style: GoogleFonts.dmSans(
                                        textStyle: TextStyle(fontSize: 18.0),
                                        color: Colors.black54)),
                                TextFormField(
                                  autofocus: true,
                                  inputFormatters: [
                                    new LengthLimitingTextInputFormatter(6),
                                  ],
                                  validator: (value) {
                                    if (value.length == 0) {
                                      return "Please enter your weight";
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.numberWithOptions(
                                      decimal: true),
                                  style: GoogleFonts.dmSans(),
                                  decoration: InputDecoration(
                                      hintText: "Enter today's weight",
                                      hintStyle: GoogleFonts.dmSans(),
                                      suffixText: " kg",
                                      suffixStyle: GoogleFonts.dmSans(),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.black38))),
                                  onSaved: (value) {
                                    _newWeight = double.parse(value);
                                  },
                                  initialValue:
                                  data[QueryTags.qWeight].toString(),
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                OutlineButton(
                                  onPressed: () {
                                    _editFormKey.currentState.validate();
                                    _editFormKey.currentState.save();
                                    bloc.editData(data.documentID, _newWeight);
                                    Navigator.of(context).pop();
                                    bloc.updateList();
                                  },
                                  child: new Text("Record"),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  });
            },
          ),
        ),
        Divider(
          color: Colors.black38,
          height: 0.0,
        )
      ],
    );
  }
}
