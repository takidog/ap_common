import 'dart:io';

import 'package:ap_common/config/ApConstant.dart';
import 'package:ap_common/models/new_response.dart';
import 'package:ap_common/resources/ap_icon.dart';
import 'package:ap_common/resources/ap_theme.dart';
import 'package:ap_common/utils/ap_localizations.dart';
import 'package:ap_common/widgets/ap_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ap_common/widgets/hint_content.dart';
import 'package:ap_common/widgets/yes_no_dialog.dart';

enum HomeState { loading, finish, error, empty, offline }

class HomePageScaffold extends StatefulWidget {
  final HomeState state;
  final String title;
  final List<News> newsList;
  final List<Widget> actions;
  final List<BottomNavigationBarItem> bottomNavigationBarItems;

  final Function(int index) onTabTapped;
  final Function(News news) onImageTapped;

  final Widget drawer;

  final bool isLogin;

  const HomePageScaffold({
    Key key,
    @required this.state,
    @required this.newsList,
    @required this.isLogin,
    this.actions,
    this.onTabTapped,
    this.bottomNavigationBarItems,
    this.drawer,
    this.title,
    this.onImageTapped,
  }) : super(key: key);

  @override
  HomePageScaffoldState createState() => HomePageScaffoldState();
}

class HomePageScaffoldState extends State<HomePageScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ApLocalizations app;

  int _currentNewsIndex = 0;

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
    return WillPopScope(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(widget.title ?? ''),
          backgroundColor: ApTheme.of(context).blue,
          actions: widget.actions,
        ),
        drawer: widget.drawer,
        body: OrientationBuilder(
          builder: (_, orientation) {
            return Container(
              padding: EdgeInsets.symmetric(
                vertical: orientation == Orientation.portrait ? 32.0 : 4.0,
              ),
              alignment: Alignment.center,
              child: _homebody(orientation),
            );
          },
        ),
        bottomNavigationBar: (widget.bottomNavigationBarItems == null)
            ? null
            : BottomNavigationBar(
                elevation: 12.0,
                fixedColor: ApTheme.of(context).bottomNavigationSelect,
                unselectedItemColor: ApTheme.of(context).bottomNavigationSelect,
                type: BottomNavigationBarType.fixed,
                selectedFontSize: 12.0,
                unselectedFontSize: 12.0,
                selectedIconTheme: IconThemeData(size: 24.0),
                onTap: widget.onTabTapped,
                items: widget.bottomNavigationBarItems,
              ),
      ),
      onWillPop: () async {
        if (Platform.isAndroid) {
          _showLogoutDialog();
          return false;
        }
        return true;
      },
    );
  }

  Widget _newsImage(News news, Orientation orientation, bool active) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOutQuint,
      margin: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * (active ? 0.05 : 0.15),
          horizontal: MediaQuery.of(context).size.width * 0.02),
      child: GestureDetector(
        onTap: () {
          if (widget.onImageTapped != null) widget.onImageTapped(news);
        },
        child: Hero(
          tag: news.hashCode,
          child: ApNetworkImage(
            url: news.imageUrl,
          ),
        ),
      ),
    );
  }

  Widget _homebody(Orientation orientation) {
    double viewportFraction = 0.65;
    if (orientation == Orientation.portrait) {
      viewportFraction = 0.65;
    } else if (orientation == Orientation.landscape) {
      viewportFraction = 0.5;
    }
    final PageController pageController =
        PageController(viewportFraction: viewportFraction);
    pageController.addListener(() {
      int next = pageController.page.round();
      if (_currentNewsIndex != next) {
        setState(() {
          _currentNewsIndex = next;
        });
      }
    });
    switch (widget.state) {
      case HomeState.loading:
        return Center(
          child: CircularProgressIndicator(),
        );
      case HomeState.finish:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Hero(
              tag: ApConstants.TAG_NEWS_TITLE,
              child: Material(
                color: Colors.transparent,
                child: Text(
                  widget.newsList[_currentNewsIndex].title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20.0,
                      color: ApTheme.of(context).grey,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
            Hero(
              tag: ApConstants.TAG_NEWS_ICON,
              child: Icon(Icons.arrow_drop_down),
            ),
            Expanded(
              child: PageView.builder(
                controller: pageController,
                itemCount: widget.newsList.length,
                itemBuilder: (context, int currentIndex) {
                  bool active = (currentIndex == _currentNewsIndex);
                  return _newsImage(
                    widget.newsList[currentIndex],
                    orientation,
                    active,
                  );
                },
              ),
            ),
            SizedBox(height: orientation == Orientation.portrait ? 16.0 : 4.0),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style:
                    TextStyle(color: ApTheme.of(context).grey, fontSize: 24.0),
                children: [
                  TextSpan(
                      text:
                          '${widget.newsList.length >= 10 && _currentNewsIndex < 9 ? '0' : ''}'
                          '${_currentNewsIndex + 1}',
                      style: TextStyle(color: ApTheme.of(context).red)),
                  TextSpan(text: ' / ${widget.newsList.length}'),
                ],
              ),
            ),
            SizedBox(height: orientation == Orientation.portrait ? 24.0 : 0.0),
          ],
        );
      case HomeState.offline:
        return HintContent(
          icon: ApIcon.offlineBolt,
          content: app.offlineMode,
        );
      case HomeState.error:
      default:
        return HintContent(
          icon: ApIcon.offlineBolt,
          content: app.somethingError,
        );
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => YesNoDialog(
        title: app.closeAppTitle,
        contentWidget: Text(
          app.closeAppHint,
          textAlign: TextAlign.center,
          style: TextStyle(color: ApTheme.of(context).greyText),
        ),
        leftActionText: app.cancel,
        rightActionText: app.confirm,
        rightActionFunction: () {
          SystemNavigator.pop();
        },
      ),
    );
  }

  void hideSnackBar() {
    _scaffoldKey.currentState.hideCurrentSnackBar();
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar({
    @required String text,
    String actionText,
    Function onSnackBarTapped,
    Duration duration,
  }) {
    return _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(text),
        duration: duration ?? Duration(days: 1),
        action: actionText == null
            ? null
            : SnackBarAction(
                onPressed: onSnackBarTapped,
                label: actionText,
                textColor: ApTheme.of(context).snackBarActionTextColor,
              ),
      ),
    );
  }
}