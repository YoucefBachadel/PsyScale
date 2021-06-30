import 'package:flutter/material.dart';
import 'package:psyscale/classes/Trouble.dart';
import 'package:psyscale/services/troubleServices.dart';
import 'package:psyscale/shared/constants.dart';
import 'package:psyscale/shared/responsive.dart';
import 'package:psyscale/shared/widgets.dart';

class AddTroubles extends StatefulWidget {
  final Trouble trouble;

  const AddTroubles({Key key, this.trouble}) : super(key: key);

  @override
  _AddTroublesState createState() => _AddTroublesState();
}

class _AddTroublesState extends State<AddTroubles> {
  final _formKey = GlobalKey<FormState>();
  String _nameEn;
  String _nameFr;
  String _nameAr;
  String _imageUrl;
  String _descreptionEn;
  String _descreptionFr;
  String _descreptionAr;
  TroublesServices troublesServices = TroublesServices();
  bool isLoading = false;

  addTroubles() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      await troublesServices
          .addTroubleData(Trouble(
              nameEn: _nameEn,
              nameFr: _nameFr,
              nameAr: _nameAr,
              imageUrl: _imageUrl,
              questionnaresCount: 0,
              descreptionEn: _descreptionEn,
              descreptionFr: _descreptionFr,
              descreptionAr: _descreptionAr))
          .then((value) {
        if (value != null) {
          setState(() {
            isLoading = false;
          });
          Navigator.pop(context);
        }
      });
    }
  }

  updateTroubles() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      await troublesServices.updateTroubleData(Trouble(
          uid: widget.trouble.uid,
          nameEn: _nameEn == null ? widget.trouble.nameEn : _nameEn,
          nameFr: _nameFr == null ? widget.trouble.nameFr : _nameFr,
          nameAr: _nameAr == null ? widget.trouble.nameAr : _nameAr,
          imageUrl: _imageUrl == null ? widget.trouble.imageUrl : _imageUrl,
          questionnaresCount: widget.trouble.questionnaresCount,
          descreptionEn: _descreptionEn == null
              ? widget.trouble.descreptionEn
              : _descreptionEn,
          descreptionFr: _descreptionFr == null
              ? widget.trouble.descreptionFr
              : _descreptionFr,
          descreptionAr: _descreptionAr == null
              ? widget.trouble.descreptionAr
              : _descreptionAr));
      setState(() {
        isLoading = false;
      });
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    if (widget.trouble != null) {
      _nameEn = widget.trouble.nameEn;
      _nameFr = widget.trouble.nameFr;
      _nameAr = widget.trouble.nameAr;
      _imageUrl = widget.trouble.imageUrl;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: isLoading
          ? loading(context)
          : Container(
              color: Theme.of(context).backgroundColor,
              child: Column(
                children: [
                  Container(
                    height: 50.0,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    color: Constants.border,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.close_sharp,
                              color: Colors.white,
                              size: 30.0,
                            )),
                        Expanded(
                          child: Text(
                            widget.trouble == null
                                ? 'Add Trouble'
                                : 'Update Trouble',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headline5
                                .copyWith(color: Colors.white),
                          ),
                        ),
                        widget.trouble != null
                            ? Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: deleteButton(context, () {
                                  createDialog(context,
                                      delteTrouble(widget.trouble.uid), true);
                                },
                                    text: 'Delete',
                                    color: Colors.red,
                                    icon: Icons.delete),
                              )
                            : SizedBox(),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(children: [
                            SizedBox(height: 10.0),
                            TextFormField(
                              initialValue: widget.trouble == null
                                  ? ''
                                  : widget.trouble.nameEn,
                              validator: (value) =>
                                  value.isEmpty ? 'Enter the Name' : null,
                              decoration:
                                  textInputDecoration(context, 'English Name'),
                              onChanged: (value) => _nameEn = value,
                            ),
                            SizedBox(height: 10.0),
                            TextFormField(
                              initialValue: widget.trouble == null
                                  ? ''
                                  : widget.trouble.nameFr,
                              validator: (value) =>
                                  value.isEmpty ? 'Enter the Name' : null,
                              decoration:
                                  textInputDecoration(context, 'Frensh Name'),
                              onChanged: (value) => _nameFr = value,
                            ),
                            SizedBox(height: 10.0),
                            TextFormField(
                              initialValue: widget.trouble == null
                                  ? ''
                                  : widget.trouble.nameAr,
                              validator: (value) =>
                                  value.isEmpty ? 'Enter the Name' : null,
                              decoration:
                                  textInputDecoration(context, 'Arabic Name'),
                              onChanged: (value) => _nameAr = value,
                            ),
                            SizedBox(height: 10.0),
                            TextFormField(
                              initialValue: widget.trouble == null
                                  ? ''
                                  : widget.trouble.imageUrl,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              validator: (value) =>
                                  value.isEmpty ? 'Enter the image Url' : null,
                              decoration:
                                  textInputDecoration(context, 'Image Url'),
                              onChanged: (value) => _imageUrl = value,
                            ),
                            SizedBox(height: 10.0),
                            TextFormField(
                              initialValue: widget.trouble == null
                                  ? ''
                                  : widget.trouble.descreptionEn,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              validator: (value) => value.isEmpty
                                  ? 'Enter the Descreption'
                                  : null,
                              decoration: textInputDecoration(
                                  context, 'English Descreption'),
                              onChanged: (value) => _descreptionEn = value,
                            ),
                            SizedBox(height: 10.0),
                            TextFormField(
                              initialValue: widget.trouble == null
                                  ? ''
                                  : widget.trouble.descreptionFr,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              validator: (value) => value.isEmpty
                                  ? 'Enter the Descreption'
                                  : null,
                              decoration: textInputDecoration(
                                  context, 'Frensh Descreption'),
                              onChanged: (value) => _descreptionFr = value,
                            ),
                            SizedBox(height: 10.0),
                            TextFormField(
                              initialValue: widget.trouble == null
                                  ? ''
                                  : widget.trouble.descreptionAr,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              validator: (value) => value.isEmpty
                                  ? 'Enter the Descreption'
                                  : null,
                              decoration: textInputDecoration(
                                  context, 'Arabic Descreption'),
                              onChanged: (value) => _descreptionAr = value,
                            ),
                            SizedBox(height: 10.0),
                          ]),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        widget.trouble == null
                            ? addTroubles()
                            : updateTroubles();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 18.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).accentColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        alignment: Alignment.center,
                        width: Responsive.isMobile(context)
                            ? MediaQuery.of(context).size.width
                            : screenWidth * 0.2,
                        child: Text(
                          widget.trouble == null
                              ? 'Add Trouble'
                              : 'Update Trouble',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }

  Widget delteTrouble(String troubleUid) {
    return Container(
      padding: EdgeInsets.all(8.0),
      width: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12.0),
          Text(
            'Confirm Delete Trouble',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headline6
                .copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.0),
          Text(
            'Are you sure you want to delete this trouble?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.subtitle2,
          ),
          SizedBox(height: 12.0),
          Container(
            width: 100,
            child: InkWell(
              onTap: () {
                TroublesServices().deleteTrouble(troubleUid);
                Navigator.pop(context);
                Navigator.pop(context);
                snackBar(context, 'The trouble has been deleted successfully');
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(18.0),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Confirm',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
          SizedBox(height: 12.0),
        ],
      ),
    );
  }
}
