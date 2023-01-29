import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';

class OverlayCircleMenu extends StatefulWidget {
  @override
  State<OverlayCircleMenu> createState() => _OverlayCircleMenuState();
}

class _OverlayCircleMenuState extends State<OverlayCircleMenu>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  bool isExpanded = false;
  bool showCenterButton = true;
  late Animation<double> _animationToggle;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animationToggle = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller!, curve: Curves.easeOutBack));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: showCenterButton
          ? Stack(
              alignment: AlignmentDirectional.center,
              children: [
                AnimatedBuilder(
                    animation: _controller!,
                    builder: (context, child) {
                      return SizedBox(
                        height: 220 * _animationToggle.value == 0
                            ? 10
                            : 220 * _animationToggle.value,
                        width: 220 * _animationToggle.value == 0
                            ? 10
                            : 220 * _animationToggle.value,
                        child: CustomeFortuneSingle(
                          children: [
                            CircularMenuItem(
                                icon: Icons.add,
                                badgeLabel: "New Post",
                                isActive: false,
                                onTap: () {
                                  Navigator.pushNamed(context, "/addPost");
                                }),
                            CircularMenuItem(
                                icon: Icons.quickreply,
                                badgeLabel: "New Post",
                                isActive: false,
                                onTap: () async {}),
                            CircularMenuItem(
                              icon: Icons.group,
                              badgeLabel: "New Post",
                              isActive: false,
                              onTap: () {},
                            ),
                            CircularMenuItem(
                                icon: Icons.translate,
                                badgeLabel: "New Post",
                                isActive: false,
                                onTap: () async {}),
                            CircularMenuItem(
                                icon: Icons.location_on,
                                badgeLabel: "New Post",
                                isActive: false,
                                onTap: () {}),
                            CircularMenuItem(
                                icon: Icons.perm_identity,
                                badgeLabel: "New Post",
                                isActive: false,
                                onTap: () {}),
                          ],
                        ),
                      );
                    }),
                Container(
                  height: 60,
                  width: 60,
                  margin:isExpanded?EdgeInsets.zero: EdgeInsets.all(4) ,

                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[700],
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ]),
                  alignment: Alignment.center,
                  child: InkWell(
                    onTap: _runExpandCheck,
                    child: isExpanded
                        ? Icon(
                            Icons.close,
                            size: 30,
                            color: Colors.white,
                          )
                        : FlutterLogo(),
                  ),
                ),
              ],
            )
          : SizedBox(),
    );
  }

  void _runExpandCheck() async {
    print("run expanded $isExpanded");
    setState(() {
      showCenterButton = false;
    });

    if (!isExpanded) {
      double? w = await FlutterOverlayWindow.getWidthDevice();
      double? h = await FlutterOverlayWindow.getHeightDevice();

      await FlutterOverlayWindow.resizeOverlay(w!.toInt(), h!.toInt());
      _controller!.forward();

      // Future.delayed(const Duration(milliseconds: 30)).then((value) {
      //
      //
      // });
      await FlutterOverlayWindow.setDragging(false);
    } else {
      _controller!.reverse();
      await FlutterOverlayWindow.resizeOverlay(100, 100);
      await FlutterOverlayWindow.setDragging(true);
    }
    setState(() {
      isExpanded = !isExpanded;

      showCenterButton = true;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

class CustomeFortuneSingle extends StatefulWidget {
  final List<Widget> children;
  final double minAngleRotate;
  final double maxAngleRotate;
  final bool limitAngle;

  CustomeFortuneSingle(
      {required this.children,
      this.maxAngleRotate = 360,
      this.minAngleRotate = 0,
      this.limitAngle = false,
      Key? key})
      : super(key: key);

  @override
  _CustomeFortuneSingleState createState() => _CustomeFortuneSingleState();
}

class _CustomeFortuneSingleState extends State<CustomeFortuneSingle>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return FortuneWheel(
      rotationCount: 10,
      onAnimationEnd: () {
        print("hello");
      },
      onFling: () {
        print("controller ");
      },
      physics: NoPanPhysics(),
      indicators: [],
      animateFirst: false,
      styleStrategy: UniformStyleStrategy(),

      items: [
        ...List.generate(widget.children.length, (index) {
          return FortuneItem(
              style: FortuneItemStyle(
                  color: Colors.transparent, borderColor: Colors.transparent),
              child: widget.children[index]);
        })
      ],
    );
  }

  @override
  void initState() {
    super.initState();
  }
}

class CircularMenuItem extends StatelessWidget {
  final IconData? icon;
  final String? badgeLabel;
  final bool? isActive;
  final void Function()? onTap;

  CircularMenuItem({this.badgeLabel, this.icon, this.onTap, this.isActive});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: (pi / 2),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              InkWell(
                onTap: onTap,
                child: CustomPaint(
                  size: Size(90, 90 * 0.6179775280898876),
                  painter: MenuItemShapePainter(
                    color: isActive! ? Colors.grey[300] : Colors.white,
                  ),
                ),
              ),
              InkWell(
                onTap: onTap,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: Color(0xFF007C30),
                      size: 30,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MenuItemShapePainter extends CustomPainter {
  Color? color;

  MenuItemShapePainter({this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(size.width * 0.3282742, size.height * 0.9757636);
    path_0.cubicTo(
        size.width * 0.4390596,
        size.height * 0.9141745,
        size.width * 0.5617775,
        size.height * 0.9114218,
        size.width * 0.6769539,
        size.height * 0.9759436);
    path_0.cubicTo(
        size.width * 0.7187820,
        size.height * 0.9994018,
        size.width * 0.7650685,
        size.height * 0.9696364,
        size.width * 0.7872011,
        size.height * 0.9076055);
    path_0.lineTo(size.width * 0.9826528, size.height * 0.3597982);
    path_0.cubicTo(
        size.width * 1.010769,
        size.height * 0.2809945,
        size.width * 0.9899472,
        size.height * 0.1801476,
        size.width * 0.9382090,
        size.height * 0.1443075);
    path_0.cubicTo(
        size.width * 0.6526506,
        size.height * -0.05358018,
        size.width * 0.3375494,
        size.height * -0.04278018,
        size.width * 0.06567640,
        size.height * 0.1450504);
    path_0.cubicTo(
        size.width * 0.01428742,
        size.height * 0.1805713,
        size.width * -0.005900157,
        size.height * 0.2815818,
        size.width * 0.02202393,
        size.height * 0.3599600);
    path_0.lineTo(size.width * 0.2175607, size.height * 0.9078455);
    path_0.cubicTo(
        size.width * 0.2398090,
        size.height * 0.9702327,
        size.width * 0.2862831,
        size.height * 0.9991818,
        size.width * 0.3283494,
        size.height * 0.9758345);
    path_0.lineTo(size.width * 0.3282742, size.height * 0.9757636);
    path_0.close();
    Paint paint0Fill = Paint()..style = PaintingStyle.fill;
    paint0Fill.color = Color(0xffFFFFF).withOpacity(0.9);

    Paint paint_1_fill = Paint()..style = PaintingStyle.fill;
    paint_1_fill.color = Color(0xff000000).withOpacity(0.5);
    canvas.drawPath(path_0, paint_1_fill);

    canvas.drawPath(path_0, paint0Fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
