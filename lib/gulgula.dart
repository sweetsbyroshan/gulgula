import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

class Gulgula extends StatefulWidget {
  final String text, loading, success, errors;
  final Function onPressed;

  const Gulgula(
    this.text, {
    Key key,
    @required this.onPressed,
    this.loading = 'Loading',
    this.success = 'Success',
    this.errors = 'Error',
  }) : super(key: key);

  @override
  _GulgulaState createState() => _GulgulaState();
}

class _GulgulaState extends State<Gulgula> {
  Artboard _riveArtboard;
  Artboard _checkedArtBoard;
  RiveAnimationController _loadingController, _checkedController;
  @override
  void initState() {
    super.initState();
    rootBundle.load('assets/gulgula.riv').then(
      (data) async {
        final loadingFile = RiveFile.import(data);
        final loadingArtBoard = loadingFile.mainArtboard;
        _loadingController = SimpleAnimation('upload_anim');
        _loadingController.isActive = true;
        loadingArtBoard.addController(_loadingController);
        rootBundle.load('assets/gulgula_check.riv').then(
          (data) async {
            final checkedFile = RiveFile.import(data);
            _checkedArtBoard = checkedFile.mainArtboard;
            _checkedController = SimpleAnimation('check_anim');
            _checkedController.isActive = true;
            _checkedArtBoard.addController(_checkedController);
            // Listen for changes to the controller to know when an animation has
            // started or stopped playing
            _checkedController.isActiveChanged.addListener(() {
              if (_checkedController.isActive) {
                print('asdasd');
              } else {
                print('asdasda213123123123');
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Future.delayed(Duration(seconds: 1))
                      .then((value) => setState(() {
                            _riveArtboard = loadingArtBoard;
                            _uploading = false;
                            _temptext = widget.text;
                          }));
                });
              }
            });
            setState(() => _riveArtboard = loadingArtBoard);
          },
        );
      },
    );
  }

  bool _uploading = false;
  String _temptext;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          _uploading = true;
          _temptext == null
              ? _temptext = widget.loading
              : _temptext = widget.text;
          Future.delayed(Duration(seconds: 3)).then((value) {
            setState(() {
              _temptext = widget.success;
              _riveArtboard = _checkedArtBoard;
            });
          });
        });
      },
      borderRadius: BorderRadius.circular(8),
      splashColor: Colors.grey,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              flex: 1,
              child: Visibility(
                visible: _uploading,
                child: Container(
                  margin: EdgeInsets.only(right: 8),
                  child: _riveArtboard == null
                      ? const SizedBox()
                      : Rive(
                          artboard: _riveArtboard,
                          fit: BoxFit.cover,
                          useArtboardSize: true,
                        ),
                ),
              ),
            ),
            Flexible(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                    (_temptext != null || _temptext != widget.text)
                        ? _temptext ?? widget.text
                        : widget.loading,
                    style: DefaultTextStyle.of(context).style.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w200,
                        color: Theme.of(context).canvasColor)),
              ),
            ),
          ],
        ),
        constraints: BoxConstraints(minWidth: 64, maxHeight: 60),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).primaryColor),
      ),
    );
  }
}
