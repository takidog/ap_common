import 'package:ap_common/config/ap_constants.dart';
import 'package:ap_common/models/user_info.dart';
import 'package:ap_common/resources/ap_theme.dart';
import 'package:ap_common/utils/ap_localizations.dart';
import 'package:barcode/barcode.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

enum _Status { loading, finish, error, empty }
enum BarCodeMode { code39, qrCode }

class UserInfoScaffold extends StatefulWidget {

  final UserInfo userInfo;
  final String heroTag;
  final List<Widget> actions;
  final Future<UserInfo> Function() onRefresh;
  final bool enableBarCode;

  const UserInfoScaffold({
    Key key,
    @required this.userInfo,
    this.heroTag,
    this.actions,
    this.onRefresh,
    this.enableBarCode = false,
  }) : super(key: key);

  @override
  UserInfoScaffoldState createState() => UserInfoScaffoldState();
}

class UserInfoScaffoldState extends State<UserInfoScaffold> {
  _Status state = _Status.finish;

  ApLocalizations app;

  BarCodeMode codeMode = BarCodeMode.qrCode;

  IconData get icon {
    switch (codeMode) {
      case BarCodeMode.code39:
        return MdiIcons.qrcode;
      case BarCodeMode.qrCode:
      default:
        return MdiIcons.barcode;
        break;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    app = ApLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(app.userInfo),
        backgroundColor: ApTheme.of(context).blue,
        actions: [
          ...widget.actions,
          if (widget.enableBarCode)
            IconButton(
              icon: Icon(icon),
              onPressed: () {
                setState(() => codeMode = BarCodeMode
                    .values[(codeMode.index + 1) % BarCodeMode.values.length]);
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (widget.onRefresh != null) await widget.onRefresh();
          return null;
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: <Widget>[
            SizedBox(height: 8.0),
            widget.userInfo.pictureBytes != null
                ? SizedBox(
                    height: 320,
                    child: AspectRatio(
                      aspectRatio: 2.0,
                      child: Hero(
                        tag: widget.heroTag ?? ApConstants.TAG_STUDENT_PICTURE,
                        child: Image.memory(
                          widget.userInfo.pictureBytes,
                        ),
                      ),
                    ),
                  )
                : SizedBox(height: 0.0),
            SizedBox(height: 8.0),
            UserInfoCard(
              userInfo: widget.userInfo,
              codeMode: codeMode,
              enableBarCode: widget.enableBarCode,
            ),
          ],
        ),
      ),
    );
  }
}

class UserInfoCard extends StatelessWidget {
  final UserInfo userInfo;
  final BarCodeMode codeMode;
  final bool enableBarCode;

  const UserInfoCard({
    Key key,
    this.userInfo,
    this.codeMode,
    this.enableBarCode = false,
  }) : super(key: key);

  Barcode get barcode {
    switch (codeMode) {
      case BarCodeMode.code39:
        return Barcode.code39();
      case BarCodeMode.qrCode:
      default:
        return Barcode.qrCode();
        break;
    }
  }

  double get barcodeHeight {
    switch (codeMode) {
      case BarCodeMode.code39:
        return 100.0;
      case BarCodeMode.qrCode:
      default:
        return 180.0;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            if (enableBarCode)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 4.0,
                ),
                child: BarcodeWidget(
                  barcode: barcode,
                  data: userInfo.id,
                  color: ApTheme.of(context).barCode,
                  height: barcodeHeight,
                ),
              ),
            ListTile(
              title: Text(ApLocalizations.of(context).studentNameCht),
              subtitle: Text(userInfo?.name ?? ''),
            ),
            Divider(height: 1.0),
            if (userInfo?.educationSystem != null) ...[
              ListTile(
                title: Text(ApLocalizations.of(context).educationSystem),
                subtitle: Text(userInfo?.educationSystem ?? ''),
              ),
              Divider(height: 1.0),
            ],
            if (userInfo?.email != null) ...[
              ListTile(
                title: Text(ApLocalizations.of(context).email),
                subtitle: Text(userInfo?.email ?? ''),
              ),
              Divider(height: 1.0),
            ],
            ListTile(
              title: Text(ApLocalizations.of(context).department),
              subtitle: Text(userInfo?.department ?? ''),
            ),
            Divider(height: 1.0),
            ListTile(
              title: Text(ApLocalizations.of(context).studentClass),
              subtitle: Text(userInfo?.className ?? ''),
            ),
            Divider(height: 1.0),
            ListTile(
              title: Text(ApLocalizations.of(context).studentId),
              subtitle: Text(userInfo?.id ?? ''),
            ),
            Divider(height: 1.0),
          ],
        ),
      ),
    );
  }
}
