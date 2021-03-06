import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:liver3rd/app/utils/const_settings.dart';
import 'package:liver3rd/app/widget/no_scaled_text.dart';

class EmptyWidget extends StatelessWidget {
  final String title;

  /// [type] ys 设置原神主题 其他崩坏主题
  final String type;
  final String subTitle;
  final Function onTap;

  const EmptyWidget({Key key, this.title, this.type, this.subTitle, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: type == 'ys'
            ? Stack(
                children: <Widget>[
                  Positioned(
                    top: 50,
                    left: 10,
                    child: Column(
                      children: <Widget>[
                        NoScaledText(
                          title == null ? '施工中' : title,
                          style: TextStyle(
                              fontSize: 22,
                              color: Colors.blue[200],
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        NoScaledText(
                          subTitle == null ? '敬请期待' : subTitle,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.amber,
                          ),
                        )
                      ],
                    ),
                  ),
                  CachedNetworkImage(
                    imageUrl: empty1Path,
                    width: 280,
                    fit: BoxFit.contain,
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 300,
                    width: 220,
                    child: Image.asset(emptyPath),
                  ),
                  NoScaledText(
                    title == null ? '未发现敌方目标' : title,
                    style: TextStyle(
                        fontSize: 22,
                        color: Colors.blue[200],
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  NoScaledText(
                    subTitle == null ? '布洛妮娅, 请求回收' : subTitle,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.amber,
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
